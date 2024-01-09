# note: run from root folder as `bash scripts/...`
# e.g. bash scripts/cloud/setup-aws.sh pathtopem username hostname portfordjangoserver

PATHTOPEMFILE=$1
ECUSERNAME=$2
ECHOST=$3 # e.g. public ip address like 50.17.123.456
PORT=$4 # e.g. 8192

if [ -z "${PATHTOPEMFILE}" ]; then
    echo "please enter path-to-pem-file as first param"
    exit 1
fi

if [ -z "${ECUSERNAME}" ]; then
    echo "please enter ec-username as second param"
    exit 1
fi

if [ -z "${ECHOST}" ]; then
    echo "please enter ec-host as third param"
    exit 1
fi

if [ -z "${PORT}" ]; then
    echo "please enter port for django server (e.g. 8192) as fourth param"
    exit 1
fi

chmod 400 "${PATHTOPEMFILE}"
DSTDIR=tmp/scripts

mkdir -p "${DSTDIR}"

## backup script generation

CURRENTFILEPATH=`realpath $0`
PARENTFOLDER=`dirname $CURRENTFILEPATH`
BACKUPFILEPATH=$PARENTFOLDER"/backup.sh"
touch $BACKUPFILEPATH
chmod +x $BACKUPFILEPATH
cat > $BACKUPFILEPATH << EOL
CONTAINERNAME=\$1

if [ -z "\${CONTAINERNAME}" ]; then
    echo "please enter container-name as first param"
    exit 1
fi

TIMESTAMP=\$(date +'%Y-%m-%d-%H-%M')
TIMESTAMPSTR="\${TIMESTAMP//:/_}" # generate unique backup folder name

PARENTFOLDERPATH=`dirname \$PWD`
BACKUPFOLDERPATHDST=\${PARENTFOLDERPATH}"/backup"
BACKUPFOLDERPATHSRC="~/backup/"\${TIMESTAMPSTR}

# ssh to remote and create a named backup folder and docker copy
REMOTECMD="mkdir -p \${BACKUPFOLDERPATHSRC} && chmod 755 \${BACKUPFOLDERPATHSRC} && ~/scripts/docker_copy.sh \${CONTAINERNAME} \${BACKUPFOLDERPATHSRC}"
ssh -i "${PATHTOPEMFILE}" "${ECUSERNAME}"@"${ECHOST}" "\${REMOTECMD}"
mkdir -p \${BACKUPFOLDERPATHDST} # create a local backup folder if it does not exist
# scp named backup folder to local backup folder
scp -i "${PATHTOPEMFILE}" -r "${ECUSERNAME}"@"${ECHOST}":"\${BACKUPFOLDERPATHSRC}" "\${BACKUPFOLDERPATHDST}"
EOL

## cloud files generation

AWSFILENAME="${DSTDIR}"/aws.sh
AWSIMGTAGNAME="amd"
touch $AWSFILENAME
chmod +x $AWSFILENAME
cat > $AWSFILENAME << EOL
IMGNAME=\$1
HASYUM=\`which yum\`

if [ -z "\${IMGNAME}" ]; then
    echo -e "please enter image-name (without tag) as first param"
    echo -e "\n(note: tag ${AWSIMGTAGNAME} will be auto-selected on aws)\n"
    exit 1
fi

if [ -z "\${HASYUM}" ]; then
    echo "please install a pkg manager"
    exit 1
fi

sudo yum install -y docker
# sudo is optional after usermod append
# might require terminal restart
sudo usermod -aG docker ${ECUSERNAME}
sudo service docker start
sudo docker pull \${IMGNAME}:${AWSIMGTAGNAME}

USERADDED=\`less /etc/group | grep docker\`
if [[ "\${USERADDED}" =~ ^.*${ECUSERNAME}\$ ]]; then
    sudo docker image ls
    # pass blank value, i.e. - for PORTMAP, and 1 for ISCLOUD
    sudo scripts/build_container.sh \${IMGNAME}:${AWSIMGTAGNAME} - 1
    sudo docker container ls -a
else
    echo "user not added to docker group, cannot run docker"
    exit 1
fi
EOL

RUNFILENAME="${DSTDIR}"/run_server.sh
touch $RUNFILENAME
chmod +x $RUNFILENAME
cat > $RUNFILENAME << EOL
CONTAINERNAME=\$1
DEV=\$2

if [ -z "\${CONTAINERNAME}" ]; then
    echo "please enter container-name as first param"
    exit 1
fi

if [ -z "\${DEV}" ]; then
    echo "please enter 'dev' as second param (to use dev settings) or '-' (to use prod settings)"
    exit 1
fi

sudo docker exec -it \${CONTAINERNAME} bash -c "scripts/run_server.sh ${PORT} - \${DEV} 1 ${ECHOST}"
EOL

cp scripts/host/build_container.sh "${DSTDIR}"
cp scripts/host/docker_copy.sh "${DSTDIR}"

## copy files to cloud

scp -i "${PATHTOPEMFILE}" -r "${DSTDIR}" "${ECUSERNAME}"@"${ECHOST}":/home/"${ECUSERNAME}"

sleep 5
rm "${DSTDIR}"/*
