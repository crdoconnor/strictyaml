#!/bin/bash
set -e
PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
PROJECT_NAME=$(cat $PROJECT_DIR/PROJECT_NAME | tr -d '\n')
if [ -z "$PROJECT_NAME" ]; then
    echo "PROJECT_NAME file must be set with project name."
    exit 1
fi
FOLDER_HASH=$(echo $PROJECT_DIR | md5sum | cut -c 1-5)
GEN_VOLUME_NAME=hitch-vol-${PROJECT_NAME}-${FOLDER_HASH}
IMAGE_NAME=hitch-${FOLDER_HASH}-${PROJECT_NAME}

hitchrun() {
    podman run --privileged -it --rm \
        -v $PROJECT_DIR:/src \
        -v $GEN_VOLUME_NAME:/gen \
        -v ~/.ssh/id_rsa:/root/.ssh/id_rsa \
        -v ~/.ssh/id_rsa.pub:/root/.ssh/id_rsa.pub \
        -p 5555:5555 \
        --secret pypitoken,type=env,target=PYPITOKEN \
        --workdir /src \
        $IMAGE_NAME \
        $1
}


case "$1" in
    "clean")
        case "$2" in
            "all")
                if podman image exists $IMAGE_NAME; then
                    podman image rm -f $IMAGE_NAME
                fi
                if podman volume exists $GEN_VOLUME_NAME; then
                    podman volume rm -f $GEN_VOLUME_NAME
                fi
                ;;
            "gen")
                if podman volume exists $GEN_VOLUME_NAME; then
                    podman volume rm -f $GEN_VOLUME_NAME
                fi
                podman volume create $GEN_VOLUME_NAME
                ;;
            "pyenv")
                hitchrun "rm -rf /gen/pyenv/"
                ;;
            "devenv")
                hitchrun "rm /gen/pyenv/versions/devvenv"
                ;;
            *)
                echo "Invalid clean target. ./key.sh clean [all]"
                exit 1
                ;;
        esac
        ;;
    "make")
        case "$2" in
            "")
                echo "building ci container..."
                if ! podman volume exists $GEN_VOLUME_NAME; then
                    podman volume create $GEN_VOLUME_NAME
                fi
                podman build -f hitch/Dockerfile-hitch -t $IMAGE_NAME $PROJECT_DIR
                hitchrun "virtualenv --python=python3 /gen/venv"
                hitchrun "/gen/venv/bin/pip install setuptools-rust"
                hitchrun "/gen/venv/bin/pip install -r /src/hitch/hitchreqs.txt"
                hitchrun "/gen/venv/bin/python hitch/key.py build"
                ;;
            "gen")
                hitchrun "virtualenv --python=python3 /gen/venv"
                hitchrun "/gen/venv/bin/pip install setuptools-rust"
                hitchrun "/gen/venv/bin/pip install -r /src/hitch/hitchreqs.txt"
                hitchrun "/gen/venv/bin/python hitch/key.py build"
                ;;
            "pylibrarytoolkit")
                hitchrun "/gen/venv/bin/pip uninstall hitchpylibrarytoolkit -y"
                hitchrun "/gen/venv/bin/pip install --no-deps -e /src/hitchpylibrarytoolkit"
                ;;
            *)
                echo "Invalid make target. ./key.sh make [all|gen|pylibrarytoolkit]"
                exit 1
                ;;
            esac
        ;;
    "bash")
        hitchrun "bash"
        ;;
    *)
        hitchrun "/gen/venv/bin/python hitch/key.py $1 $2 $3 $4 $5 $6 $7 $8 $9"
        ;; 
esac

exit
