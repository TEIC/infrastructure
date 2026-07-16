# TEI Infrastructure

Scripts and tools for running the TEI infrastructure.

## Infrastructure setup overview

The directory `humanum` contains Docker Compose files for TEI services 
running on the Huma-Num host.  
Most public services attach to the shared external network `tei_net` and 
are exposed through a central reverse proxy.

### Core stack (`docker-compose_tei-core-services.yml`)

The core compose file provides shared infrastructure used by all other 
service stacks:

- **`nginx-proxy`**  
  Central reverse proxy (ports `80` and `443` on the host).  
  It discovers backend containers via Docker metadata  and routes requests 
  by `VIRTUAL_HOST` / `VIRTUAL_PORT`.

- **`acme-companion`**  
  Manages Let’s Encrypt certificates for hosts declared with `LETSENCRYPT_HOST`.  
  Shares certificate/html volumes with `nginx-proxy`.

- **`autoheal`**  
  Restarts containers marked with label `autoheal=true` when they become 
  unhealthy.  
  It is **not** on `tei_net` (`network_mode: none`) and works via 
  `/var/run/docker.sock`.
> [!IMPORTANT]  
> Services need a [Docker healthcheck instruction](https://dockerbuild.com/reference/healthcheck)
> for the autoheal feature to work.

- **`watchtower`**  
  Polls for newer container images every 30 minutes 
  (`WATCHTOWER_POLL_INTERVAL=1800`) and updates running containers 
  automatically. 
  It also uses `/var/run/docker.sock` and is configured with cleanup enabled 
  to remove stopped containers and unused images.

### How request routing works

1. Public DNS points hostnames (e.g. `tei-c.org`, `journal.tei-c.org`) to this server.
2. Incoming HTTP(S) traffic reaches `nginx-proxy` on host ports `80/443`.
3. `nginx-proxy` forwards requests to the target container on `tei_net` based on `VIRTUAL_HOST`.
4. Certificates are provisioned/renewed by `acme-companion`.

### Requirements for a public service compose file

To be reachable from the internet, a service should:

- join network `tei_net`
- set `VIRTUAL_HOST=<hostname[,hostname2,...]>`
- set `LETSENCRYPT_HOST=<hostname[,hostname2,...]>`
- set `VIRTUAL_PORT=<internal-port>` when not using container port `80`

Optional resilience:

- add label `autoheal: "true"` so `autoheal` can restart unhealthy containers
- if you want to disable the automated update of containers by watchtower 
  you have to explicitly opt out by adding your container to the 
  `WATCHTOWER_DISABLE_CONTAINERS` env variable.

## Architectural overview

```mermaid
graph TB
    subgraph Internet["🌐 Internet (HTTPS)"]
        Users["Users/Clients"]
    end

    subgraph Host["Host Machine"]
        DockerDaemon["🐳 Docker Daemon<br/>/var/run/docker.sock"]
        NP["<b>nginx-proxy</b><br/>172.20.0.22<br/>Gateway &<br/>SSL Termination"]
        ports["Port 80:443"]
    end

    subgraph TEI_NET["🔗 tei_net Network (172.20.0.0/24)"]
        ACME["<b>acme-companion</b><br/>SSL Certificate Mgmt"]
        
        subgraph Website_Svc["Website Service"]
            WS["<b>website</b><br/>Apache"]
        end

        subgraph Wiki_Svc["Wiki Service"]
            WIKI["<b>teiwiki</b><br/>MediaWiki"]
        end

        subgraph Roma_Svc["Roma Service"]
            ROMA["<b>roma</b><br/>RomaJS"]
        end

        subgraph Garage_Svc["TEIGarage Service"]
            TG["<b>teigarage</b><br/>OxGarage"]
        end

        subgraph OJS_Svc["OJS Service"]
            OJS["<b>journal</b><br/>PKP-OJS"]
        end

        subgraph VAULT_Svc["Vault Service"]
            VAULT["<b>vault</b><br/>TEI Vault"]
        end

        subgraph DEBIAN_Svc["Debian Packages Service"]
            DEBIAN["<b>deb</b><br/>Debian Packages"]
        end
    end

    subgraph Isolated["🔒 Isolated Networks<br/>Internal Only"]
        OJSDB["<b>ojsdb</b><br/>MariaDB"]
        WIKIDB["<b>teiwikidb</b><br/>MariaDB"]
    end

    subgraph Management["Management (Docker Socket)"]
        WH["watchtower<br/>Image Updates"]
        AH["autoheal<br/>Health Monitoring"]
    end

    %% Request flow
    Users -->|HTTPS| ports
    ports -->|internal| NP
    NP -->|HTTP/80| WS
    NP -->|HTTP/80| WIKI
    NP -->|HTTP/80| ROMA
    NP -->|HTTP/8081| TG
    NP -->|HTTP/80| OJS
    NP -->|HTTP/80| VAULT
    NP -->|HTTP/80| DEBIAN
    NP -.->|communicate| ACME

    %% Internal connections
    WIKI -->|DB Query| WIKIDB
    OJS -->|DB Query| OJSDB

    %% Docker socket management
    WH -.->|/var/run/docker.sock| DockerDaemon
    AH -.->|/var/run/docker.sock| DockerDaemon
    DockerDaemon -.->|manages| NP

    classDef internet fill:#FFE6CC,stroke:#FF6B6B,stroke-width:2px
    classDef gateway fill:#B8E0F0,stroke:#0056b3,stroke-width:3px
    classDef service fill:#C8E6C9,stroke:#2E7D32,stroke-width:2px
    classDef database fill:#FFD4D4,stroke:#C62828,stroke-width:2px
    classDef management fill:#F3E5F5,stroke:#6A1B9A,stroke-width:2px
    classDef daemon fill:#FFECB3,stroke:#F57F17,stroke-width:2px

    class Users internet
    class NP gateway
    class WS,WIKI,ROMA,TG,OJS,ACME,VAULT,DEBIAN service
    class OJSDB,WIKIDB database
    class WH,AH management
    class DockerDaemon daemon
```
