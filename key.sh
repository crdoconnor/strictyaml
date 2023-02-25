#!/bin/bash
set -e
PROJECT_NAME=strictyaml

PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
CONTAINER_NAME=${PROJECT_NAME}-hitch-container
IMAGE_NAME=${PROJECT_NAME}-hitch

hitchrun() {
    podman run --privileged -it --rm \
        -v $PROJECT_DIR:/src \
        -v $CONTAINER_NAME:/gen \
        -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
        -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
        --workdir /src \
        $IMAGE_NAME \
        $1
}


case "$1" in
    "clean")
        if podman volume exists $CONTAINER_NAME; then
            podman volume rm $CONTAINER_NAME
        fi
        if podman image exists $IMAGE_NAME; then
            podman image rm -f $IMAGE_NAME
        fi
        ;;
    "make")
        echo "building ci container..."
        if ! podman volume exists $CONTAINER_NAME; then
            podman volume create $CONTAINER_NAME
        fi
        podman build -f hitch/Dockerfile-hitch -t $IMAGE_NAME $PROJECT_DIR
        hitchrun "/venv/bin/python hitch/key.py build"
        ;;
    "bash")
        hitchrun "bash"
        ;;
    *)
        hitchrun "/venv/bin/python hitch/key.py $1 $2 $3 $4 $5 $6 $7 $8 $9"
        ;; 
esac

exit
