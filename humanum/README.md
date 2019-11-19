# Service descriptions for the HumaNum server

The files within this directory are [Docker Compose](https://docs.docker.com/compose/) configuration files.
Each file defines a service, e.g. `docker-compose_oxgarage.yml` holds all the configuration needed for runnning [OxGarage](https://github.com/TEIC/oxgarage) at https://oxgarage-humanum.tei-c.org.

There is one special service: `docker-compose_nginx-proxy.yml` provides a central [nginx proxy](https://github.com/jwilder/nginx-proxy) with a [letsencrypt-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion). All TEI services need to register with this service via the  `VIRTUAL_HOST`, `LETSENCRYPT_HOST`, and `VIRTUAL_PORT` (if necessary) environment variables to be accessible from the outside via https.

## starting a service

```bash
# docker-compose -f $filename.yml$ up -d
```

## stopping a service

```bash
# docker-compose -f $filename.yml$ down
```

## docker-update.sh

… is a little helper script that will will stop the named service,
pull the (updated) image(s), do some cleanup, and then restart the service again. Invoke it like

```bash
# ./docker-update.sh roma
```
