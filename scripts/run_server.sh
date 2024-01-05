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
PYTHONCMD=""

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

# pass dev as third param to use settings_base
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

${PYTHONCMD} manage.py runserver ${HOST}:${PORT} --settings=temph.${DEV}