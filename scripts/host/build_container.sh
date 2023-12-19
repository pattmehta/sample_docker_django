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

docker run -id --name ${IMGNAME}_other ${IMGNAME}
docker run -id --name ${IMGNAME}_service -p ${PORTMAP} ${IMGNAME}