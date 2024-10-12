#! /bin/bash
ARCH=$(arch | sed s/arm64/aarch64/)
docker run \
    --rm \
    -it \
    --name builder \
    --privileged \
    -v .:/data \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    "ghcr.io/home-assistant/${ARCH}-builder:latest" \
        -t /data \
        --all \
        --test \
        -i tidbyt-assistant-addon-{arch} \
        -d local
