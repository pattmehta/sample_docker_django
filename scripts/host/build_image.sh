# note: run from root folder as `bash ./scripts/...`

P3PATH=`which python3`
if [ -z ${P3PATH} ]; then
    python ./scripts/host/build_env.py
else
    python3 ./scripts/host/build_env.py
fi

docker build -t $1 .