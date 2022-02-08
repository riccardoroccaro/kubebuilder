#!/bin/bash

while getopts 'a:u:' OPTION; do
  case "$OPTION" in
    a)
        APP=$OPTARG
        echo "APP=$APP"
        ;;

    u)
        USR=$OPTARG
        echo "USER=$USR"
        ;;
    ?)
      echo "Please run as './kubebuilder -a <app-name/directory> -u <dockerhub-username>'."
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

#Check that all the variables have been set
if [ -z ${APP+x} ]; then 
    echo "APP is unset. Please run as './kubebuilder -a <app-name/directory> -u <dockerhub-username>'."
    exit 1
fi
if [ -z ${USR+x} ]; then 
    echo "USER is unset. Please run as './kubebuilder -a <app-name/directory> -u <dockerhub-username>'."
    exit 1
fi

#Running the docker container
echo "Running Kubebuilder by mounting $(pwd)/Projects/$APP directory into /go/src/$APP"
docker run -it --rm --name app-kubebuilder \
    -v $(pwd)/Projects/$APP:/go/src/$APP:rw \
    -v $(pwd)/config:/root/.kube/config:ro \
    -v $(pwd)/docker.pwd:/root/docker.pwd:ro \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -w /go/src/$APP \
    -e USER=$USR \
    --network='k3d-kubebuilder' \
    r0cc4rd0/kubebuilder

exit 0
