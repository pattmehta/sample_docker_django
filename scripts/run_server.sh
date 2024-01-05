# with localhost:
# - runs only on localhost
# - bash scripts/run_server.sh port_num host dev
# without localhost:
# - binds to all ips on the machine
# - bash scripts/run_server.sh port_num - dev

P3PATH=`which python3`
PORT=$1
HOST=$2
DEV=$3
ISCLOUD=$4
CLOUDPUBLICHOST=$5
PYTHONCMD=""

echo "(note: allows extra params for cloud host)"

if [ -z "${PORT}" ]; then
    echo "please enter port-num as first param"
    exit 1
fi

if [ -z "${HOST}" ]; then
    echo "please enter 'host' as second param (to run as localhost) or '-' (to run as 0.0.0.0)"
    exit 1
fi

if [ -z "${DEV}" ]; then
    echo "please enter 'dev' as third param (to use dev settings) or '-' (to use prod settings)"
    exit 1
fi

# pass host as second param to use 127.0.0.1 ip
if [ "${HOST}" == "host" ]; then
    HOST="127.0.0.1"
else
    HOST="0.0.0.0"
fi

if ([ "${HOST}" != "host" ] && [ "${ISCLOUD}" == "1" ] && [ -z "${CLOUDPUBLICHOST}" ]); then
    echo "please enter cloud-public-host as fifth param"
    exit 1
fi

if [ "${DEV}" == "dev" ]; then
    DEV="settings_base"
else
    DEV="settings_prod"
fi

if [ -z "${P3PATH}" ]; then
    PYTHONCMD="python"
else
    PYTHONCMD="python3"
fi

if ([ "${HOST}" != "host" ] && [ "${ISCLOUD}" == "1" ]); then
    ${PYTHONCMD} manage.py init_server --settings=temph.${DEV} ${CLOUDPUBLICHOST}
fi

${PYTHONCMD} manage.py runserver ${HOST}:${PORT} --settings=temph.${DEV}