# sample_docker_django
docker image with sample django app

### env

template for `.env`
- DBNAME=app
- DBHOST=localhost
- CACHELOCATION=server_url

template for `.env.secret`
- DBUSER=app_user
- DBPASS=app_password
- SECRET_KEY='longstring'
- JWT_SIGNING_KEY='longstring'

### docker

- > bash scripts/docker_clean.sh
- > bash scripts/host/build_image.sh djapp
- > bash scripts/host/build_container.sh pm1992outlook/djapp 80:8092

#### running containers

> docker run --name djapp_service -id -p 80:8083 djapp

##### requests

with container named `djapp_service`, requests made from `host`, `djapp_other` (container), `local` (container `djapp_service`)

- host
    - curl -G 127.0.0.1/api/
    - > 192.168.65.1 (host ip)

- djapp_other
    - curl -G 172.17.0.2:port_number/api/
    - > 172.17.0.3 (djapp_other ip)

- local
    - curl -G localhost:port_number/api/
    - > 127.0.0.1 (local ip)
    - > localhost or 127.0.0.1

### cloud

- currently contains script to bootstrap django app image on aws
    - the app execution is configurable via a script, see example below
    - > docker exec -itd containername bash `-c "scripts/init_server.sh optiona optionb optionc"`
- bootstrapping simply does a docker setup
    - installing docker with a package manager
    - starting the docker service as a superuser
    - pulling the latest image
    - adding user to the docker group (optional)

### troubleshoot

- sending request from container `a` to `b`

    - getting error `Failed to connect to ip`, e.g. ip `172.17.0.2`
        - if server is only bound to `127.0.0.1` i.e. `localhost` change to `0.0.0.0` which will bind server to all ip addresses on this network (e.g. `python manage.py runserver 0.0.0.0:port_number`)

    - getting `400` status code
        - `Bad Request (400)`
        - check if `ALLOWED_HOSTS` has the container ip which is running the server
        - e.g. `ALLOWED_HOSTS = ['127.0.0.1','localhost','0.0.0.0','172.17.0.2']`
        - if list has container ip, then server throws error e.g. due to [DisallowedHost](https://docs.djangoproject.com/en/5.0/ref/exceptions/#suspiciousoperation)

- sending request from host to container `b`

    - getting `operation timed out` error
        - check if `runserver` ip is `0.0.0.0`
        - check if `ALLOWED_HOSTS` is properly configured
        - if above is fixed, check if port mapping is enabled on the container
        - create/run a new container with port mapping `docker run -id -p 80:8083 djapp`
        - > note: use port `8083` in `runserver 0.0.0.0:8083` for the server created above