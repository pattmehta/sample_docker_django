CONTAINERNAME=$1
DSTPATH=$2
CONTAINERSTORAGE="/app/storage"
CONTAINERSTORAGECOPYPATH=${CONTAINERNAME}:${CONTAINERSTORAGE}

if [ -z "${CONTAINERNAME}" ]; then
    echo "please enter container-name as first param"
    exit 1
fi

if [ -z "${DSTPATH}" ]; then
    echo "please enter destination-path as second param"
    exit 1
fi

echo "copying from source ${CONTAINERSTORAGECOPYPATH} to destination ${DSTPATH}"

sudo docker cp ${CONTAINERSTORAGECOPYPATH} ${DSTPATH}