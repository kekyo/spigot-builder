#!/bin/sh

podman build -t spigot_runner:1 .

#podman tag spigot_runner kekyo/spigot_runner:latest
#podman login docker.io
#podman push kekyo/spigot_runner:latest
