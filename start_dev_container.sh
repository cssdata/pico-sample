#!/bin/bash

docker run -d -it --rm --name pico --mount type=bind,source=${PWD},target=/workspace pico-sdk
