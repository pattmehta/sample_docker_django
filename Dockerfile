FROM python

RUN apt-get update && apt-get install -y vim net-tools
WORKDIR /app
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt

COPY . .
RUN chmod +x ./scripts/init_docker.sh && cp -r dst/ env/ && rm -rf dst/