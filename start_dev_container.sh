#!/bin/bash

docker run -d -it --rm --name pico --mount type=bind,source=${PWD},target=/workspace cssdata/pico-dev
