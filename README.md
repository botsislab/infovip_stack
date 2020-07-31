# InfoViP (Information Visualization Platform)

This Readme describes the InfoViP development environment, as collected here in several git repositories.
It also discusses how to get up and running locally by using Docker.

## First Time Setup

- Clone all the needed git repositories from the GitLab instance on the server.

- Install Docker. For Windows or MacOS, we recommend [Docker Desktop](https://www.docker.com/products/docker-desktop)


- Prepare Docker environment.
We need to start a single-computer swarm instance for running the stacks, and also create a network that the two stacks can use to communicate.

```
docker swarm init
docker network create -d overlay --attachable public
```

## Repeatable Setup: Build Images

We need to build the Docker image for each of the projects.
Note that the infovip_stack project is not meant to be a Docker image and doesn't have a Dockerfile.
Go into each directory and issue the `docker build` command with the appropriate tag to assign.

```
cd auth_server/
docker build -t auth-server-service .
```

```
cd infovip_database/
docker build -t infovip-database .
```

```
cd infovip_ether/
docker build -t infovip-ether .
```

```
cd infovip_service/
docker build -t infovip-service .
```

```
cd infovip_workbench/
docker build -t infovip-workbench .
```

Each build may take several minutes to complete.
Docker will first download the base image from DockerHub, and then start to execute the commands in the Dockerfile.
This typically involves downloading updates and required dependencies into the image.

When all the images are ready, you can check the list of existing images in your local environemnt with `docker image ls`

You will need to repeat the build process for any project where the code is updated in the future.

## Deploy InfoViP

After all the images have been built locally, you can launch the entire InfoViP platform with a few commands.
These commands need to point to the two docker-compose files for the authentication server and for the infovip stack.
Either go into the *auth_server* and *infovip_stack* directories individually and run the deploy commands,
or reference the full paths to the correct docker-compose files.

```
docker stack deploy -c auth_server/docker-compose.yml auth
docker stack deploy -c infovip_stack/docker-compose.yml infovip
```

## InfoViP is Running

While running, the Docker stacks give you external access to several parts of InfoViP.
Most importantly, you can load up the workbench UI in your browser by going to <http://localhost/>.
The login name and password are both *infovip* for now, and individual user accounts are not yet supported.

You can use the workbench to upload a FAERS data file and create a case list.  It should also process the cases with ETHER.

The MySQL database should also be visible to your local computer on port 3306 (the default MySQL port).
That means you can use other tools, like the MySQL Workbench to connect to the database and browse data or make changes.

## Tear Down InfoViP

While the stacks are deployed, Docker will try to keep active containers of each image running all the time, even if you restart the computer.
If the stack seems to not be working, or if you just want to stop the processes, you need to tell Docker to stop the two stacks.

```
docker stack rm infovip
docker stack rm auth
```

This stops the stacks, and Docker will wind down and destroy the containers it is running, which usually takes 10-15 seconds.
Sometimes an extra container will be left over (not deleted) after the stack has been stopped.  I'm not sure why.
You can check for any loose containers with `docker container ls -a`
and remove one with `docker container rm <container_id>` where *container_id* will be a 12-character hexadecimal identifier.
