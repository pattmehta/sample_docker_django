# note: run from root folder as `bash ./scripts/...`
python ./scripts/host/build_env.py
docker build -t $1 .