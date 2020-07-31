#!/bin/bash

echo "updating infovip-stack"

pull=false

while [[ $# -gt 0 ]]; do
	case "$1" in
		-p|--pull)
			pull=true
			;;
		*)
			echo "unknown flag $1, ignoring it"
			;;
	esac
	shift
done

if [[ $pull == true ]]; then
	echo "doing git pull as well"
fi

cd ../infovip_workbench
if [[ $pull == true ]]; then git pull; fi
docker build -t infovip-workbench .

cd ../infovip_service
if [[ $pull == true ]]; then git pull; fi
docker build -t infovip-service .

cd ../infovip_database
if [[ $pull == true ]]; then git pull; fi
docker build -t infovip-database .

cd ../infovip_ether
if [[ $pull == true ]]; then git pull; fi
docker build -t infovip-ether .

cd ../infovip_drugsatfda
if [[ $pull == true ]]; then git pull; fi
docker build -t infovip-drugsatfda .

cd ../infovip_dailymed
if [[ $pull == true ]]; then git pull; fi
docker build -t infovip-dailymed .

cd ../infovip_classification
if [[ $pull = true ]]; then git pull; fi
docker build -t infovip-classification .

cd ../infovip_stack
if [[ $pull == true ]]; then git pull; fi

stacks=`docker stack ls`
if [[ $stacks == *"infovip-stack"* ]]; then
        echo "infovip-stack is running, force updating each service"
        docker service update --force infovip-stack_infovip-database
        docker service update --force infovip-stack_infovip-drugsatfda
        docker service update --force infovip-stack_infovip-ether
        docker service update --force infovip-stack_infovip-service
        docker service update --force infovip-stack_infovip-workbench
        docker service update --force infovip-stack_infovip-dailymed
        docker service update --force infovip-stack_infovip-classification
else
        echo "infovip-stack not running, doing fresh 'docker stack deploy'"
        docker stack deploy -c docker-compose.yml infovip-stack
fi
