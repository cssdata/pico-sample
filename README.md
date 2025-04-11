# Sample project for use with a "pico-dev" container

## Setting up the build environment

1. You have to build a **_"pico-dev"_** container first. (See: https://github.com/cssdata/pico-dev)

To run and test this project
do the following:

1. start the container and mount this directory to /workspace. Assuming your
   current working directory is this directory, just type:

```bash
docker run -d -it --rm --name pico --mount type=bind,source=${PWD},target=/workspace pico-sdk
```

There is a small shell script which does exactely that, so that you can instead just type:

```
./start_dev_container.sh
```

This will start a conainer from the pico-dev image and name it **_"pico"_**.

**NOTE: You have to start the container from within your project directories so that the project(s) are mounted to /workspace.**

2. Attach to the running container

```bash
docker exec -it pico /bin/bash
```

3. Then, within the container, configure and build the project:

```bash
# create a build directory and 'cd' to it
mkdir build
cd build
# configure the project (e.g.: configure for debug)
cmake -DCMAKE_BUILD_TYPE=Debug ..
# ... and finaly build the project
make
```

This will leave you with a bunch of files (elf, uf2, bin, hex, etc...):

```
root@5559b5f0afa3:/workspace/build# ls -ls
total 1336
 28 -rw-r--r-- 1 1000 staff  24855 Mar 31 09:10 CMakeCache.txt
  0 drwxr-xr-x 1 1000 staff    476 Mar 31 09:12 CMakeFiles
136 -rw-r--r-- 1 1000 staff 137045 Mar 31 09:10 Makefile
 20 -rwxr-xr-x 1 1000 staff  17172 Mar 31 09:12 blink.bin
276 -rw-r--r-- 1 1000 staff 281082 Mar 31 09:12 blink.dis
328 -rwxr-xr-x 1 1000 staff 332548 Mar 31 09:12 blink.elf
456 -rw-r--r-- 1 1000 staff 466379 Mar 31 09:12 blink.elf.map
 48 -rw-r--r-- 1 1000 staff  48362 Mar 31 09:12 blink.hex
 36 -rw-r--r-- 1 1000 staff  34816 Mar 31 09:12 blink.uf2
  4 -rw-r--r-- 1 1000 staff   1631 Mar 31 09:10 cmake_install.cmake
  0 drwxr-xr-x 1 1000 staff    102 Mar 31 06:45 generated
  0 drwxr-xr-x 1 1000 staff    272 Mar 31 09:10 pico-sdk
  4 -rw-r--r-- 1 1000 staff     60 Mar 31 06:45 pico_flash_region.ld
  0 drwxr-xr-x 1 1000 staff     68 Mar 31 06:45 pioasm
  0 drwxr-xr-x 1 1000 staff     68 Mar 31 06:45 pioasm-install
root@5559b5f0afa3:/workspace/build#
```

You may copy the _.uf2_ file directly on a pico in **_"boot mode"_**.

## Debugging with openocd and gdb from within the container

To debug directly on a target device you need a running remote **_"openocd"_**
and connect from _gdb_, running within the container, to the _openocd_ outside the container.
Because _gdb_ and _openocd_ talk to each other via TCP/IP, you can run _openocd_
even on a different host anywhere on your network (e.g. a raspberry pi).

1. On the target-host connect your **_pico-probe_** and do all the wireing from
   the probe to the target device (see: https://www.raspberrypi.com/documentation/microcontrollers/debug-probe.html)

2. You can either connect ext. power to the target-device or connect the device-usb
   port to any host if you want to use the devices's usb port for debuging output
   (that's why pico\*enable\*stdio\*usb() was enabled in the CMakeLists.txt). You can
   run whatever in-output you want via usb-serial. If you connect the target to a
   Raspberry-Pi or any other linux like os, **_minicom_** is your friend.

3. When everything is connected, start openocd on the target host:

```bash
/path_to_your/openocd -f interface/cmsis-dap.cfg -f target/rp2040.cfg -c 'bindto 0.0.0.0' -c 'adapter speed 5000' -c 'init'
```

.. and you will see something like

```
xPack Open On-Chip Debugger 0.12.0+dev-01850-geb6f2745b-dirty (2025-02-07-12:14)
Licensed under GNU GPL v2
For bug reports, read
	http://openocd.org/doc/doxygen/bugs.html
Info : Hardware thread awareness created
Info : Hardware thread awareness created
adapter speed: 5000 kHz
Info : Using CMSIS-DAPv2 interface with VID:PID=0x2e8a:0x000c, serial=E663B03597743D26
Info : CMSIS-DAP: SWD supported
Info : CMSIS-DAP: Atomic commands supported
Info : CMSIS-DAP: Test domain timer supported
Info : CMSIS-DAP: FW Version = 2.0.0
Info : CMSIS-DAP: Interface Initialised (SWD)
Info : SWCLK/TCK = 0 SWDIO/TMS = 0 TDI = 0 TDO = 0 nTRST = 0 nRESET = 0
Info : CMSIS-DAP: Interface ready
Info : clock speed 5000 kHz
Info : SWD DPIDR 0x0bc12477, DLPIDR 0x00000001
Info : SWD DPIDR 0x0bc12477, DLPIDR 0x10000001
Info : [rp2040.core0] Cortex-M0+ r0p1 processor detected
Info : [rp2040.core0] target has 4 breakpoints, 2 watchpoints
Info : [rp2040.core0] Examination succeed
Info : [rp2040.core1] Cortex-M0+ r0p1 processor detected
Info : [rp2040.core1] target has 4 breakpoints, 2 watchpoints
Info : [rp2040.core1] Examination succeed
Info : [rp2040.core0] starting gdb server on 3333
Info : Listening on port 3333 for gdb connections
Info : Listening on port 6666 for tcl connections
Info : Listening on port 4444 for telnet connections
```

4. Then from within the container in your build directory, start a gdb-session:

```
root@5559b5f0afa3:/workspace/build# gdb-multiarch blink.elf
GNU gdb (Debian 10.1-1.7) 10.1.90.20210103-git
....
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from blink.elf...
(gdb)
(gdb) target extended-remote myhostname:3333
(gdb) monitor reset halt
[rp2040.core0] halted due to breakpoint, current mode: Thread
xPSR: 0xf1000000 pc: 0x000000ea msp: 0x20041f00
[rp2040.core1] halted due to debug-request, current mode: Thread
xPSR: 0xf1000000 pc: 0x000000ea msp: 0x20041f00
(gdb) load
Loading section .boot2, size 0x100 lma 0x10000000
Loading section .text, size 0x34ec lma 0x10000100
Loading section .rodata, size 0xa08 lma 0x100035f0
Loading section .binary_info, size 0x24 lma 0x10003ff8
Loading section .data, size 0x2f8 lma 0x1000401c
Start address 0x100001e8, load size 17168
Transfer rate: 16 KB/sec, 3433 bytes/write.
(gdb) break main
Breakpoint 1 at 0x10000320: file /workspace/blink.c, line 6.
Note: automatically using hardware breakpoints for read-only addresses.
(gdb) c
6	int main() {
(gdb) n
11	    gpio_init(LED_PIN);
(gdb)
12	    gpio_set_dir(LED_PIN, GPIO_OUT);
(gdb)
14	        gpio_put(LED_PIN, 0);
(gdb)
15	        sleep_ms(250);
(gdb)
16	        gpio_put(LED_PIN, 1);
(gdb)
17	        sleep_ms(1000);
(gdb)
14	        gpio_put(LED_PIN, 0);
(gdb)
15	        sleep_ms(250);
(gdb)
```

You get the idea .... NOTE: _gdb_ is called **_gdb-multiarch_**

## Loading and running the target on the device using gdb and openocd

There is a small script **_"run_on_target.sh"_** that uses _gdb_ and a remote running
_openocd_ to load a **_".elf"_** file onto the target-device and start it.
When you are in the buld directory run:

```bash
../run_on_target.sh blink.elf
```

... and you see something like this:

```
root@5559b5f0afa3:/workspace/build# root@5559b5f0afa3:/workspace/build# ../run_on_target.sh blink.elf >/dev/null
warning: multi-threaded target stopped without sending a thread-id, using first non-exited thread
[rp2040.core0] halted due to debug-request, current mode: Thread
xPSR: 0x61000000 pc: 0x10000bc2 msp: 0x20041fb0
[rp2040.core1] halted due to debug-request, current mode: Thread
xPSR: 0x01000000 pc: 0x00000138 msp: 0x20041f00
[rp2040.core0] halted due to debug-request, current mode: Thread
xPSR: 0xf1000000 pc: 0x000000ea msp: 0x20041f00
[rp2040.core1] halted due to debug-request, current mode: Thread
xPSR: 0xf1000000 pc: 0x000000ea msp: 0x20041f00
[rp2040.core0] halted due to breakpoint, current mode: Thread
xPSR: 0xf1000000 pc: 0x000000ea msp: 0x20041f00
[rp2040.core1] halted due to debug-request, current mode: Thread
xPSR: 0xf1000000 pc: 0x000000ea msp: 0x20041f00
```

# Doing it the easy way with the vscode dev-container plugin

There is a ready-to-use vscode devcontainer setup and vscode launch configuration.

So, if you are working with vscode and have **_"Dev Containers"_** installed:

- click on your _"Open a Remote Window"_ icon (left bottom corner)
- select _"Reopen in Container"_

You can also use vscode debugging via gdb and openocd. Just build your project for debug and click on the debug icon in vscode.
