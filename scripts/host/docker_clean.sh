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

CONTAINERPREFIX="${IMGNAME//\//_}" # replace escaped slash '/' with '_'

echo "stopping and removing all containers"
array=( ${CONTAINERPREFIX}_service ${CONTAINERPREFIX}_other )
for container in "${array[@]}"
do
    docker stop "${container}"
    docker rm "${container}"
done

echo "removing image ${IMGNAME}"
docker image rm ${IMGNAME}