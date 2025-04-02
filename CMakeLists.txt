cmake_minimum_required(VERSION 3.12)

include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(blink C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(blink
    blink.c
)
pico_enable_stdio_usb(blink 1)

pico_add_extra_outputs(blink)

target_link_libraries(blink pico_stdlib)

# Write the path of the executable to a text file
file(WRITE ${CMAKE_BINARY_DIR}/project_elf.txt "${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.elf\n")

# Change this if you openocd is not running on your local machine
# Use "host.docker.internal:3333" which resolves to your docker host port 3333
file(WRITE ${CMAKE_BINARY_DIR}/openocd_target.txt "host.docker.internal:3333\n")