#!/bin/bash
set -e
PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

hitchrun() {
    podman run --privileged -it --rm \
        -v $PROJECT_DIR:/src \
        -v strictyaml-hitch-container:/gen \
        -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
        -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
        --workdir /src \
        strictyaml-hitch \
        $1
}


case "$1" in
    "clean")
        if podman volume exists strictyaml-hitch-container; then
            podman volume rm strictyaml-hitch-container
        fi
        if podman image exists strictyaml-hitch; then
            podman image rm -f strictyaml-hitch
        fi
        ;;
    "make")
        echo "building ci container..."
        if ! podman volume exists strictyaml-hitch-container; then
            podman volume create strictyaml-hitch-container
        fi
        podman build -f hitch/Dockerfile-hitch -t strictyaml-hitch $PROJECT_DIR
        hitchrun "/venv/bin/python hitch/key.py make"
        ;;
    "bash")
        hitchrun "bash"
        ;;
    "--help")
        echo "Commands:"
        echo "./run.sh make     - build docker containers."
        ;;
    *)
        hitchrun "/venv/bin/python hitch/key.py $1 $2 $3 $4 $5 $6 $7 $8 $9"
        ;; 
esac

exit
