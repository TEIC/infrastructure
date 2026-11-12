# Mirroring TEI services

This document describes how to run a mirror of TEI services on your own host 
and is aimed at sysadmin people.
Services that can be mirrored include:
- TEI Vault
- TEI Roma
- TEI Website
- TEIGarage

> [!IMPORTANT]
> The TEI Vault is the archive of the TEI Consortium and served from two    
> locations: as a subfolder of the TEI website (`tei-c.org/Vault`) and as a 
> standalone service (`vault.tei-c.org`).

If you want to run a mirror of (all or some) TEI services please get in 
touch with the TEI Consortium infrastructure group at 
[infrastructuregroup@tei-c.org.](mailto:infrastructuregroup@tei-c.org).

## Prerequisites
- Docker and Docker Compose installed on the host
- A domain name (confirmed by the infrastructure group) and DNS records set up 
  for the mirror (see section "DNS entries" below)
- SSL certificates for the domain (see section "SSL certificates" below)

### Compute requirements
Roma, the TEI vault, and the TEI website are webservers serving static content 
that can be run on a relatively small server—depending on the expected traffic.
TEIGarage is a JAVA based web application that is more resource intensive
and requires a server with more CPU and RAM.

### Storage requirements
For mirroring the TEI Vault you'll need ~100GB of storage space.
The other TEI services have smaller storage requirements that can be 
estimated by the size of the Docker images.
That said, you should plan for additional space for logs that can grow over 
time, especially when your mirror receives a lot of traffic.

## DNS entries
DNS entries for the mirror will be created by the infrastructure group of 
the TEI Consortium and follow the pattern:
- `mirror1.tei-c.org` for the TEI website and the TEI vault at 
  `mirror1.tei-c.org/Vault`
- `teigarage2.tei-c.org` for the TEIGarage mirror
- `roma2.tei-c.org` for the Roma mirror

## SSL certificates
SSL certificates are required for the services to be reachable via HTTPS and 
are to be managed by the institution running the mirror.
The recommended way to obtain SSL certificates is to use the 
`acme-companion` service that is part of the TEI core stack.

## Running services
There are Docker Compose files (which are written in YAML) in the 
[humanum directory](./humanum) at the root level of this repository. 
Those files should be used as templates to run the desired services on your 
own host.
You will need to adapt the `VIRTUAL_HOST`, `LETSENCRYPT_HOST`, and 
`LETSENCRYPT_EMAIL` environment variables in the compose files to match 
your mirror's domain names.
Also, when volumes are used to persist data (e.g. for the TEI Vault), you will 
need to adapt the volume paths to match your host's filesystem.

## Updating the mirror
The TEI core stack includes the `watchtower` service that automatically updates
running containers when new images are available.
