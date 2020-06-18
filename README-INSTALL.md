# Installation of TDM Docker Images

After extracting the TDM_Portal_docker-4.9.38.0.tgz into a directory run the following command from withing that location to deploy docker images.

## Installing Core TDMWeb Images
```
gunzip -c ./TDM_images/orientdb/orientdb-2.2.33.tgz | docker load
gunzip -c ./TDM_images/tdmtools/tdmtools-4.9.38.0.tgz | docker load
gunzip -c ./TDM_images/tdmweb/tdmweb-4.9.38.0.tgz | docker load
gunzip -c ./TDM_images/action-service/action-service-4.9.38.0.tgz | docker load
````

## Installing TDM Messaging Image
```
gunzip -c ./TDM_images/messaging/messaging-4.9.38.0.tgz | docker load
````

## Installing TDM Masking Image
```
gunzip -c ./TDM_images/masking/masking-4.9.38.0.tgz | docker load
````

## Installing TDM officialoracle-gtrep Database Image
GTREP database is not provided as a ready to use Docker image. If you require that, you need to build the image from TDM_Portal_docker_src-4.9.38.0.tgz. Please refer to README-BUILD.md for details.


# Installing for different TDM Deployment Scenarios

## TDM in one Docker instance/machine
Install Core TDMWeb images, TDM Messaging image, TDM Masking image and optionally TDM officialoracle-gtrep Database image, if you don't have external GTREP database.

## TDM in Docker with distributed masking services
Install Core TDMWeb images, TDM Messaging image and optionally TDM Masking image and TDM officialoracle-gtrep Database image on one Docker instance/machine.
Install TDM Masking image on any number of additional Docker instances/machines.


## TDM on Windows with distributed masking services
In that scenario core TDM Web components are installed on Windows outside Docker environment.
It is still possible to use scalable masking deploying TDM Messaging and TDM Masking images to separate docker instance(s)/machine(s).
Install TDM Messaging image and optionally TDM Masking image on separate Docker instance/machine.
If required, install TDM Masking image on any number of additional Docker instances/machines.
