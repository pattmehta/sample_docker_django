DOCKERCMD=`which docker`
IMGNAME=$1

if [ -z "${DOCKERCMD}" ]; then
    echo "could not find docker"
    exit 1
fi

if [ -z "${IMGNAME}" ]; then
    echo "please enter image-name as first param"
    exit 1
fi

echo "stopping and removing all containers"
docker stop $(docker container ls -aq) && docker rm $(docker container ls -aq)
echo "removing image ${IMGNAME}"
docker image rm ${IMGNAME}