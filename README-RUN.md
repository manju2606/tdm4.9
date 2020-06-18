# Running TDM in Docker

## Preparing the environment

Create data directory for TDM Services. For example:
```
mkdir -p /opt/tdm
```
Copy the required docker-compose files into the directory, for example
```
cp docker-compose*.yml /opt/tdm
```
Create local directories for docker volumes mounts.
For TDM Messaging Service:
```
cd /opt/tdm
mkdir -p jdbcdrivers maskingEngineLogs maskingServiceLogs
```
For TDM Masking Service:
```
cd /opt/tdm
mkdir -p rabbitmqdb
```

## Customising docker-compose files
Before running TDM in docker you must customise the docker-compose files according to your requirements.

The following items should be provided:
 * GTREP database connection properties in docker-compose.yml, only if an external database is provided.
 * Port numbers and passwords can also be changed, if required.
 * Host names of the remote services (services running on different machines) must be provided instead of the default ones. For example, when running remote masking service, the **MESSAGING_SERVER** in docker-compose-masking.yml must be updated accordingly. 

Dependencies between TDM Docker services should be defined according to actual environment. They are described by the following docker-compose file snippet that can be combined with other docker-compose files: 

```
version: '3.5'

services:
  tdmweb:
    depends_on:
      - orientdb
      - database
      - messaging
  masking:
    depends_on:
      - messaging
```

Refer to product documentation for details.

## Running in different deployment scenarios

Note refer to README-INSTALL.md for docker image deployment instructions for the below scenarios.

### TDM in one Docker instance/machine

Running with an external GTREP database:
```
docker-compose -f docker-compose.yml -f docker-compose-messaging.yml -f docker-compose-masking.yml up -d
```

Running with tdm/officialoracle-gtrep Docker database:
```
docker-compose -f docker-compose.yml -f docker-compose-ora.yml -f docker-compose-messaging.yml -f docker-compose-masking.yml up -d
```

### TDM in Docker with distributed masking services
Please note that like in the previous scenario external or docker GTREP can be used by adding or not the docker-compose-ora.yml file.

On the main Docker instance run:
```
docker-compose -f docker-compose.yml -f docker-compose-messaging.yml up -d
```

On any number of distributed Docker instances run:
```
docker-compose docker-compose-masking.yml up -d
```

### TDM on Windows with distributed masking services
In that scenario core TDM Web components are installed on Windows outside Docker environment.
TDM Messaging Service and TDM Masking service can be run on a separate Docker instance/machine with:
```
docker-compose -f docker-compose-messaging.yml -f docker-compose-masking.yml up -d
```

Additionally, on any number of distributed Docker instances, run:
```
docker-compose docker-compose-masking.yml up -d
```
, if required.

## Scaling masking services in a Docker instance

To run multiple masking services in a single docker instance the _--scale_ option of _docker-compose up_ command can be used.
For example, the following command will deploy 3 masking services:
```
docker-compose -f docker-compose-masking.yml up -d --scale masking=3
```

When more masking services need to be added to already running environment, the _--no-recreate_ option can be used. For example:
```
docker-compose -f docker-compose-masking.yml up -d --scale masking=5 --no-recreate
```
