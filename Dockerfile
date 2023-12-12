FROM python

RUN apt-get update && apt-get install -y vim
WORKDIR /app
COPY requirements.txt ./requirements.txt
RUN python -m pip install -r requirements.txt

COPY . .
RUN chmod +x ./scripts/init_docker.sh
ADD dst/ env/