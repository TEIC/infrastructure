# script for restarting TEI services by name, e.g.
# `./docker-update roma` will stop the service,
# pull the (updated) image(s) and then restart
# the service again. 
#!/bin/bash

IMAGES=()
CONTAINERS=()
COMPOSE_FILE=""
SERVICE=$1

case $SERVICE in
    romaantiqua)
    IMAGES=("teic/xquery4roma" "teic/roma")
    CONTAINERS=("xquery4roma" "romaantiqua")
    COMPOSE_FILE=docker-compose_romaantiqua.yml
    ;;
    roma)
    IMAGES=("teic/romajs")
    CONTAINERS=("roma")
    COMPOSE_FILE=docker-compose_roma.yml
    ;;
    oxgarage)
    IMAGES=("teic/oxgarage")
    CONTAINERS=("oxgarage")
    COMPOSE_FILE=docker-compose_oxgarage.yml
    ;;
    teigarage)
    IMAGES=("teic/teigarage")
    CONTAINERS=("teigarage")
    COMPOSE_FILE=docker-compose_teigarage.yml
    ;;
    *)
    echo ERROR: unknown service \"$SERVICE\"
    exit 1
    ;;
esac

echo "*************************"
echo pulling updated images
for image in ${IMAGES[@]} ; do docker pull $image ; done

echo "*************************"
echo stopping service $SERVICE
#for container in ${CONTAINERS[@]} ; do docker kill $container ; done
docker-compose -f $COMPOSE_FILE down

echo "*************************"
echo do some cleaning
docker container prune -f && docker volume prune -f && docker image prune -f

echo "*************************"
echo restarting service $SERVICE
docker-compose -f $COMPOSE_FILE up -d
