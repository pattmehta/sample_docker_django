HOST=$1
PORT=$2

if ([ -z "${HOST}" ] || [ -z "${PORT}" ]); then
    echo "please enter host as first param, and port as second param"
    exit 1
fi

DST=$HOST:$PORT
CURLFILENAME="./scripts/curl/requests/requests.txt"
touch $CURLFILENAME
cat > $CURLFILENAME << EOL
curl -X POST $DST/api/token/ -d "username=user_first&password=pwd"

curl -G $DST/api/history/?count=2

curl -X POST -d "username=user_first" $DST/api/reset_lockout/
EOL

DATA=`curl -X POST $DST/api/token/ -d "username=user_first&password=pwd"`
DATAKEY="data"
ACCESSKEY="access"
CMD="python -c 'response=$DATA;print(response[\"$DATAKEY\"][\"$ACCESSKEY\"]);'"
ACCESSTOKEN=$(eval $CMD)

if [ $? != "1" ]; then
    # evaluated command returned without any error
    eval "./scripts/curl/build_auth_requests.sh $DST $ACCESSTOKEN"
fi