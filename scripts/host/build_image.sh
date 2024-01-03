# note: run from root folder as `bash scripts/...`
IMGNAME=$1
P3PATH=`which python3`
PYTHONCMD=""

if [ -z "${IMGNAME}" ]; then
    echo "please enter image-name as first param"
    exit 1
fi

if [ -z "${P3PATH}" ]; then
    PYTHONCMD="python"
else
    PYTHONCMD="python3"
fi

${PYTHONCMD} ./scripts/host/build_env.py
docker build -t ${IMGNAME} .