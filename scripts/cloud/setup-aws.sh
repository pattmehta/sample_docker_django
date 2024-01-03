# note: run from root folder as `bash ./scripts/...`
# e.g. bash scripts/cloud/setup.sh pathtopem username hostname

PATHTOPEMFILE=$1
ECUSERNAME=$2
ECHOST=$3 # e.g. public ip address like 50.17.123.456
PORTMAP=$4 # e.g. 80:8092

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

if [ -z "${PORTMAP}" ]; then
    echo "please enter port-mapping (e.g. 80:8092) as fourth param"
    exit 1
fi

chmod 400 "${PATHTOPEMFILE}"
DSTDIR=tmp/scripts

mkdir -p "${DSTDIR}"

AWSFILENAME="${DSTDIR}"/aws.sh
touch $AWSFILENAME
chmod +x $AWSFILENAME
cat > $AWSFILENAME << EOL
IMGNAME=\$1
HASYUM=\`which yum\`

if [ -z "\${IMGNAME}" ]; then
    echo "please enter image-name as first param"
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
sudo docker pull \${IMGNAME}:latest

USERADDED=\`less /etc/group | grep docker\`
if [[ "\${USERADDED}" =~ ^.*${ECUSERNAME}\$ ]]; then
    sudo docker image ls
    "${DSTDIR}"/build_container.sh \${IMGNAME}:latest ${PORTMAP}
    sudo docker container ls
else
    echo "user not added to docker group, cannot run docker"
    exit 1
fi
EOL

RUNFILENAME="${DSTDIR}"/run_container.sh
PORT=`echo ${PORTMAP} | cut -d ":" -f 2`
touch $RUNFILENAME
chmod +x $RUNFILENAME
cat > $RUNFILENAME << EOL
CONTAINERNAME=\$1

if [ -z "\${CONTAINERNAME}" ]; then
    echo "please enter container-name as first param"
    exit 1
fi

sudo docker exec -itd \${CONTAINERNAME} bash -c "scripts/init_server.sh ${PORT} - -"
EOL

cp scripts/host/build_container.sh "${DSTDIR}"

scp -i "${PATHTOPEMFILE}" -r "${DSTDIR}" "${ECUSERNAME}"@"${ECHOST}":/home/"${ECUSERNAME}"

sleep 5
rm "${DSTDIR}"/*
