# with localhost:
# - runs only on localhost
# - bash scripts/init_server.sh port_num host dev
# without localhost:
# - binds to all ips on the machine
# - bash scripts/init_server.sh port_num - dev

P3PATH=`which python3`
HOST=$2
DEV=$3

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

if [ -z ${P3PATH} ]; then
    python manage.py runserver $HOST:$1 --settings=temph.$DEV
else
    python3 manage.py runserver $HOST:$1 --settings=temph.$DEV
fi