DST=$1
ACCESSTOKEN=$2

if ([ -z "${DST}" ] || [ -z "${ACCESSTOKEN}" ]); then
    echo "please enter destination-addr as first param, and access-token as second param"
    exit 1
fi

CURLFILENAME="./scripts/curl/requests/auth_requests.txt"
touch $CURLFILENAME
cat > $CURLFILENAME << EOL
curl -X POST $DST/api/token/ -d "username=user_first&password=pwd"

curl -X POST -d "count=5" -H "Authorization: Bearer $ACCESSTOKEN" $DST/route/

curl -G $DST/api/history/?count=2

curl -X POST -d "count=1&username=user_first" -H "Authorization: Bearer badtoken" $DST/api/user_history/

curl -X POST -d "count=1&username=user_first" -H "Authorization: Bearer $ACCESSTOKEN" $DST/api/user_history/

note: following curl request for upload_image was erroneous, using other clients was successful
curl -X POST -d "username=user_first&img_data=data:image/png;base64,longdatauristring" -H "Authorization: Bearer $ACCESSTOKEN" $DST/api/upload_image/
EOL