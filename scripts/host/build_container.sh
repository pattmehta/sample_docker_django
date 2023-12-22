IMGNAME=$1
PORTMAP=$2

if [ -z "${IMGNAME}" ]; then
    echo "please enter image-name as first param"
    exit 1
fi

if [ -z "${PORTMAP}" ]; then
    echo "please enter port-mapping (e.g. 80:8092) as second param"
    exit 1
fi

CONTAINERPREFIX="${IMGNAME//\//_}" # replace escaped slash '/' with '_'

docker run -id --name ${CONTAINERPREFIX}_other ${IMGNAME}
docker run -id --name ${CONTAINERPREFIX}_service -p ${PORTMAP} ${IMGNAME}