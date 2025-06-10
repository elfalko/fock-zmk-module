#!/bin/bash

# docker volume create --driver local -o o=bind -o type=none \
#   -o device="$(pwd)" zmk-config
cd ../zmk
devcontainer up --workspace-folder "$(pwd)"
