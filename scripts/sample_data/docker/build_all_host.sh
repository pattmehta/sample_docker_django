# note:
# - run from root folder as `bash scripts/sample_data/docker/build_all_host.sh WORKDIR`
# - docker WORKDIR is /app
# - PWD is Pathname of the current Working Directory
# - ensure DBFOLDERABS is inside an ignored folder
# - scripts/sample_data/docker/ is added to dockerignore

IMGNAME="sample_data"
WORKDIR=$1
DBFOLDER=$2

if [ -z "${WORKDIR}" ]; then
    echo "please enter docker workdir ('WORKDIR /app') as first param"
    exit 1
fi

if [ -z "${DBFOLDER}" ]; then
    DBFOLDER="dbsample"
fi

CONTAINERPREFIX="${IMGNAME//\//_}" # replace escaped slash '/' with '_'
CONTAINERNAME=${CONTAINERPREFIX}_service
CONTAINERMOUNT="${WORKDIR}/${DBFOLDER}"

DBFOLDERABS=$PWD/`dirname $0`"/${DBFOLDER}"
echo "create db folder if not exist:"
echo $DBFOLDERABS
mkdir -p ${DBFOLDERABS}


#### Utils
DIRABS=$PWD/`dirname $0`
CLEANSCRIPTABS=$DIRABS"/docker_clean.sh"
COPYSCRIPTABS=$PWD/"scripts/sample_data/copy_db.sh"

echo -e "\ncreate docker_clean\n"
sleep 1
rm $CLEANSCRIPTABS
touch $CLEANSCRIPTABS
chmod +x $CLEANSCRIPTABS
cat > $CLEANSCRIPTABS << EOL
echo "stopping and removing container $CONTAINERNAME"
docker stop $CONTAINERNAME && docker rm $CONTAINERNAME
echo "removing image ${IMGNAME}"
docker image rm ${IMGNAME}
rm ${COPYSCRIPTABS}
rm ${CLEANSCRIPTABS}
EOL

echo -e "\ncreate copy_db\n"
sleep 1
rm $COPYSCRIPTABS
touch $COPYSCRIPTABS
chmod +x $COPYSCRIPTABS
cat > $COPYSCRIPTABS << EOL
cp "${WORKDIR}/db.sqlite3" ${CONTAINERMOUNT}
EOL


#### Image/Container/Execute
echo -e "\nbuild image\n"
sleep 1
docker build -t ${IMGNAME} .

echo -e "\nbuild container\n"
sleep 1
docker run -id --name $CONTAINERNAME -v ${DBFOLDERABS}:${CONTAINERMOUNT} ${IMGNAME}


echo -e "\ncompleted build_all_host!\n"