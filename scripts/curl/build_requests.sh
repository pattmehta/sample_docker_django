HOST=$1
PORT=$2
USERNAME=$3
PASSWORD=$4

if ([ -z "${HOST}" ] || [ -z "${PORT}" ]); then
    echo "please enter host as first param, and port as second param"
    exit 1
fi

if ([ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ]); then
    echo "please enter username as third param, and password as fourth param"
    exit 1
fi

DST=$HOST:$PORT
CURLFILENAME="./scripts/curl/requests/requests.txt"
touch $CURLFILENAME
cat > $CURLFILENAME << EOL
curl -X POST $DST/api/token/ -d "username=${USERNAME}&password=${PASSWORD}"

curl -G $DST/api/history/?count=2

curl -X POST -d "username=${USERNAME}" $DST/api/reset_lockout/

# example url for uploaded image on cloud
# http://${DST}/api/media/images/${USERNAME}_img.png
EOL

DATA=`curl -X POST $DST/api/token/ -d "username=${USERNAME}&password=${PASSWORD}"`
DATAKEY="data"
ACCESSKEY="access"
CMD="python -c 'response=$DATA;print(response[\"$DATAKEY\"][\"$ACCESSKEY\"]);'"
ACCESSTOKEN=$(eval $CMD)

if [ $? != "1" ]; then
    # evaluated command returned without any error
    eval "./scripts/curl/build_auth_requests.sh $DST $ACCESSTOKEN $USERNAME $PASSWORD"
fi