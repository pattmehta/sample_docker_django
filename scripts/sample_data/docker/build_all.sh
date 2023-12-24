# note:
# - run from root folder as `bash ./scripts/...`
# - docker WORKDIR is /app
# - PWD is Pathname of the current Working Directory
# - ensure DBFOLDERABS is inside an ignored folder
# - scripts/sample_data/docker/ is added to dockerignore


IMGNAME="sample_data"
DBFOLDER=$1
WORKDIR="/app"

if [ -z "${DBFOLDER}" ]; then
    DBFOLDER="dbsample"
fi

DBFOLDERABS=$PWD/`dirname $0`"/${DBFOLDER}"
echo "create db folder if not exist:"
echo $DBFOLDERABS
mkdir -p ${DBFOLDERABS}

echo -e "\nbuild image\n"
sleep 1
docker build -t ${IMGNAME} .

CONTAINERPREFIX="${IMGNAME//\//_}" # replace escaped slash '/' with '_'

echo -e "\nbuild container\n"
sleep 1
CONTAINERNAME=${CONTAINERPREFIX}_service
docker run -id --name $CONTAINERNAME -v $(pwd):${DBFOLDERABS} ${IMGNAME}

DIRABS=$PWD/`dirname $0`
CLEANSCRIPTABS=$DIRABS"/docker_clean.sh"
rm $CLEANSCRIPTABS
touch $CLEANSCRIPTABS
chmod +x $CLEANSCRIPTABS

cat > $CLEANSCRIPTABS << EOL
echo "stopping and removing container $CONTAINERNAME"
docker stop $CONTAINERNAME && docker rm $CONTAINERNAME
echo "removing image ${IMGNAME}"
docker image rm ${IMGNAME}
EOL