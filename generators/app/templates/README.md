Oporty
=======

B2b social network

### Requirements

  * [Docker](http://docs.docker.com/installation)
  * [Docker-compose](https://github.com/docker/compose)

### Deploy

First build frontend application.

Admin:
```bash
cd path/to/root/project
cd static/admin

npm install -g bower --allow-root

npm install
bower install

ember build
```

Opporty:
```bash
```

Second build nginx image

```bash
cd path/to/root/project
# docker build -t oporty/nginx -v $(pwd)/static/admin:/oporty-admin -f ./Dockerfile-nginx .
docker build -t oporty/nginx -f ./Dockerfile-nginx .
```
