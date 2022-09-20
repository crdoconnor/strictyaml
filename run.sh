set -e
PROJECT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

mykey() {
    podman run --privileged -it --rm \
               -v $PROJECT_DIR:/src \
               -v strictyaml-hitch-container:/gen \
               -e NONINTERACTIVE=$NONINTERACTIVE
               --workdir /src \
               strictyaml-hitch /venv/bin/python
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
        ;;
    "key")
        #mykey "/venv/bin/python $2"
        #key "/venv/bin/python hitch/key.py $2 $3 $4"

        podman run --privileged -it --rm -v $PROJECT_DIR:/src -v strictyaml-hitch-container:/gen --workdir /src strictyaml-hitch /venv/bin/python hitch/key.py $2 $3 $4 $5 $6
        ;;
    "--help")
        echo "Commands:"
        echo "./run.sh make     - build docker containers."
        ;;
    *)
        echo "Unknown command. Run ./run.sh --help for help."
        ;; 
esac

exit