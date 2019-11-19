# script for restarting TEI services by name, e.g.
# `./docker-update roma` will stop the service,
# pull the (updated) image(s) and then restart
# the service again. 
#!/bin/bash

IMAGES=()
COMPOSE_FILE=""
SERVICE=$1

case $SERVICE in
    roma)
    IMAGES=("teic/xquery4roma" "teic/roma")
    COMPOSE_FILE=docker-compose_roma.yml
    ;;
    romabeta)
    IMAGES=("teic/romajs")
    COMPOSE_FILE=docker-compose_romabeta.yml
    ;;
    oxgarage)
    IMAGES=("teic/oxgarage")
    COMPOSE_FILE=docker-compose_oxgarage.yml
    ;;
    *)
    echo ERROR: unknown service \"$SERVICE\"
    exit 1
    ;;
esac

echo "*************************"
echo stopping service $SERVICE
docker-compose -f $COMPOSE_FILE down

echo "*************************"
echo pulling images
for image in ${IMAGES[@]} ; do docker pull $image ; done

echo "*************************"
echo do some cleaning
docker container prune -f && docker volume prune -f && docker image prune -f

echo "*************************"
echo restarting service $SERVICE
docker-compose -f $COMPOSE_FILE up -d
