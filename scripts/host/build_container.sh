IMGNAME=$1
PORTMAP=$2
ISCLOUD=$3

if [ -z "${IMGNAME}" ]; then
    echo "please enter image-name as first param"
    exit 1
fi

if ([ -z "${PORTMAP}" ] && [ "${ISCLOUD}" != "1" ]); then

    echo "please enter port-mapping for django server (e.g. 80:8092) as second param"
    exit 1
fi

# example remote image with tag repoprofilename/somerepo:sometag
CONTAINERPREFIX="${IMGNAME//\//_}" # replace escaped slash '/' with '_'
CONTAINERPREFIX="${CONTAINERPREFIX//\:/_}" # replace escaped colon ':' with '_'

echo -e "\ncreate and run container(s)\n"
if [[ "${ISCLOUD}" == "1" ]]; then
    BACKUPFOLDERPATH="./backup"
    mkdir ${BACKUPFOLDERPATH}
    CONTAINERSTORAGE="/app/storage"
    echo -e "adds mount with (host) source ${BACKUPFOLDERPATH} and (container) target ${CONTAINERSTORAGE}\n"
    docker run -id --name ${CONTAINERPREFIX}_service --net="host" -v ${BACKUPFOLDERPATH}:${CONTAINERSTORAGE} ${IMGNAME}
else
    # on the local machine
    docker run -id --name ${CONTAINERPREFIX}_service -p ${PORTMAP} ${IMGNAME}
    docker run -id --name ${CONTAINERPREFIX}_other ${IMGNAME}
fi
