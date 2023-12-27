# note:
# - run from root folder as `bash scripts/sample_data/build_db.sh`

APPMODULE=$1
DBSCRIPT=$2
P3PATH=`which python3`
PYTHONCMD=""
DOCKER=$3

if [ -z "${APPMODULE}" ]; then
    echo "please enter settings-module as first param e.g. temph.settings_base"
    exit 1
fi

if [ -z "${DBSCRIPT}" ]; then
    echo "please enter path to folder with init_db/copy_db scripts as second param e.g. (scripts/sample_data)"
    exit 1
fi

if [ -z "${P3PATH}" ]; then
    PYTHONCMD="python"
else
    PYTHONCMD="python3"
fi

DBSCRIPT=`${PYTHONCMD} -c "print('/'.join([s for s in \"${DBSCRIPT}\".split('/') if len(s) > 0]))"` # remove extra forward slashes

SLEEPSCND=2
export DJANGO_SETTINGS_MODULE=${APPMODULE}
echo -e "\nmakemigrations:\n"
${PYTHONCMD} manage.py makemigrations

sleep $SLEEPSCND
echo -e "\nmigrate:\n"
${PYTHONCMD} manage.py migrate

sleep $SLEEPSCND
echo -e "\ninit_db:\n"
${PYTHONCMD} manage.py init_db ${DBSCRIPT}

sleep $SLEEPSCND
echo -e "\ncreate_sample_data:\n"
${PYTHONCMD} manage.py create_sample_data

if [ "${DOCKER}" != "docker" ]; then
    echo -e "\nskipping copy_db stage as third param ('docker') is missing\n"
else
    sleep $SLEEPSCND
    echo -e "\ncopy_db:\n"
    COPYSCRIPTABS=$PWD/"${DBSCRIPT}/copy_db.sh"
    bash $COPYSCRIPTABS
fi

echo -e "\ncompleted build_db!\n"