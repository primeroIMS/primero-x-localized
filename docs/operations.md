# Daily Operations

This document describes some basic operations that a local team can perform on their local production instance of Primero.

## Access to the Server

Daily operational access to the **Production Server** via an SSH shell should go through a local management **Bastion Server**. Optionally, it can employ the same high privilege system user that is used by the Primero X Tier 4 pipelines to maintain and provision the server.

One way to ensure this access:

  - On the **Bastion Server** the operator should generate a strong SSH key without a password:
  ```
  # Elliptical keys are preferred
  ssh-keygen -t ed25519 -a 100 -C "Primero Bastion"

  # Alternatively, you may use a strong RSA key, but this will be slower
  ssh-keygen -t rsa -b 4096 -a 100 -C "Primero Bastion"
  ```
  - The public key will be in `~/.ssh/id_ed25519.pub` or `~/.ssh/id_rsa.pub` on the **Bastion**.
  - The operator should append this key to the file  `~/.ssh/authorized_keys` located on the **Production Server**
  - Ensure that SSH is correctly configured (password access is disabled, permitted IP addresses are whitelisted, etc) according to the [security guidance](security.md).
  - Each individual who is to be granted access to production should generate on their machine an strong SSH key. See instructions above. Replace the `"Primero Bastion"` with the user's email.
  - The individual should share the contents of the file `~/.ssh/id_ed25519.pub` or `~/.ssh/id_rsa.pub` with the system operator who has access to **Bastion Server**. The public key can be shared over email or a chat service without any encryption.
  - The system operator should append the contents of that key to the file `~/.ssh/authorized_keys` on the **Bastion Server**. This file contains the keys of all individuals who may be granted back end access to Primero. Make sure that the list contains only the keys of permitted individuals!

Note that SSH security settings will quickly expire idle SSH sessions. Users will need to log back in if their session locks up.

## Verifying the server

Primero runs on the **Production Server** via Docker containers. Your system user must either be in the user group `docker` or be a sudoer. To check that Primero is up:
```
docker ps
```
This will list all currently running Primero processes. You will see the following containers:
 - `primero-application-1`: This is the core application container that runs the Primero API server.
 - `primero-nginx-1`: This is the Nginx Primero web server container that proxies requests to the API, hosts static resources, and maintains the TLS endpoints.
 - `primero-worker-1`: This is the queue worker process in charge of executing batch jobs, asynchronous processes, file exports, sending email etc.
 - `primero-solr-1`: This is the search service index, responsible for record search, phonetic search, duplicate detection
 - `primero-postgres-1`: (Optional) This is the Primero database. Note that it is not recommended to run a local Tier 4 deployment with a Docker-managed database. Instead, if possible, you should leverage an external managed service.

If any of the containers above do not show up when running `docker ps` Primero is not functioning properly. The list of necessary containers may change in the future. This documentation will be updated to reflect any changes.

The Docker tag on the container image will indicate the exact Primero version and build. All containers must use the same Primero version. For example the system below is running Primero v2.5.7.3 and has been up for 27 hours
```
$ docker ps
...
d11267d2a948   primeroims/application:v2.5.7.3   "/entrypoint.sh prim…"   2 days ago   Up 27 hours    primero-application-1
...
```

## System Resource Usage

The following commands can be run to check the health and usage of system resources. If the system is running on a cloud platform like Azure or AWS, these statistics are available in the cloud console.

 - **System Performance and running processes**: `top` or `htop`
 - **Memory**: A low volume instance of Primero uses roughly 2 Gb of memory. Memory use will grow with data growth, more usage, large data exports.
 ```
 free -mh
 ```
 - **Disk**: To check disk usage of the mounted volumes.
 ```
 df -kh
 ```
 Primero will use disk space if the database is running on the same **Production Server**, if the primero attachment storage (photos, PDFs) is located on the same server, or there are old, unused Primero Docker images.

 To check for unused Docker images, list the images and look for images with tag versions different than the current running version:
 ```
 docker image ls
 ```
 To clean up, first ensure Primero is up and running. Do not execute these commands if Primero is not running.
 ```
 docker container prune -f
 docker image prune -af
 ```

## Restarting services

To restart the Docker containers:
```
docker restart primero-nginx-1 primero-application-1 primero-worker-1 primero-solr-1 primero-postgres-1
```
Note that `primero-postgres-1` should be omitted if the database is not running locally via Docker.

## Viewing Log Files

You can view the logs of the currently running containers:
```
docker logs <container-name>
```
To view the logs in real time use the `-f` parameter. For example:
```
docker logs -f primero-application-1
```

The default Docker logger driver is `journald`. To view all logs from the last 3 months:
```
journalctl -u docker.service
```