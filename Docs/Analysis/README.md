# Analysis

## Play with API through Telnet

Parts of the documentation in the [integrator ref](Docs/rpgs-integrator-reference-guide.pdf)

```sh
telnet POLCYOM_IP 24
# or
ssh admin@POLYCOM_IP
# using password set for admin account on the device

# cf integrator ref:
# camera <near|far> move <left|right|up|down|zoom+|zoom-|stop>
> camera near move left
> camera near zoom+
```

## Camera info

[Eagle Eye IV HDCI](https://www.poly.com/fr/fr/products/video-conferencing/eagleeye/eagleeye-iv)

```sh
ssh admin@polycom

-> camerainput 1 get
camerainput 1 hdmi
```

## Opening up the RealPresence box

> [Video link](https://www.youtube.com/watch?v=4mT5giWe2UI&t=179s)

Open only the side with the sticker "Polycom" (front). You will get access to the SD card.

## Backup

```sh
sudo cp if=/dev/rdiskN of=polycom.dd bs=8M

# mount on linux for fun
losetup --partscan --find --show polycom.dd
# doesn't seem needed, but why not
mount /dev/loop0p1 /mnt
# to unmount everything
losetup -d /dev/loop0
```

## Enable ADB

From linux :

```sh
sudo vim SD_CARD_ROOT_PART/init.rc
# 1. find "service adbd"
# 2. comment disabled and oneshot
# 3. find "setprop net.tcp.buffersize.default" etc
# 4. add line "setprop service.adb.tcp.port 5555"
# 5. (maybe also add "setprop adb.tcp.port 5555")
```

Also take a look at `SD_CARD_ROOT_PART/system/build.prop` for fun.

Put back the SD card, turn on the system.

On a computer :

```sh
adb connect POLYCOM_IP:5555
adb shell
```

## Board info

Obtained using [link](https://www.geekersdigest.com/how-to-identify-cpu-information-type-and-model-on-android/)

```sh
adb shell getprop | egrep "(ro.board|ro.product.cpu|arm.variant)"

[ro.board.platform]: [omap3]
[ro.product.cpu.abi2]: [armeabi]
[ro.product.cpu.abi]: [armeabi-v7a]

```

CPU:

```sh
adb shell cat /proc/cpuinfo

Processor   : ARMv7 Processor rev 2 (v7l)
BogoMIPS    : 983.04
Features    : swp half thumb fastmult vfp edsp neon vfpv3
CPU implementer : 0x41
CPU architecture: 7
CPU variant : 0x3
CPU part    : 0xc08
CPU revision    : 2

Hardware    : ti8168evm
Revision    : 0000
Serial      : 0000000000000000
```

[List of debians supported board](https://wiki.debian.org/InstallingDebianOn)
[And their boot status](https://wiki.debian.org/U-boot/Status)

## Reverse engineering PTZ protocol

To reverse engineer, a script is availble in [Logs/trace.sh](Logs/trace.sh)

Useful links:
- [strace idea](https://unix.stackexchange.com/a/12367)
- [found -f flag](https://stackoverflow.com/a/42127964/1439489)
- [manual logging to logcat](https://android.stackexchange.com/questions/230067/creating-a-log-entry-in-logcat-via-adb))

## Cable info

Details:

- Name : [HDCI](https://en.wikipedia.org/wiki/HDCI)
- Board edge connector: LFX60
- Camera edge connector: [DH40-37S](https://www.digikey.fr/en/products/detail/DH40-37S/H11934-ND/2642701?curr=usd&utm_campaign=buynow&utm_medium=aggregator&utm_source=octopart)

Cable wires:

- in main shield:
    - 4x shields, for HDMI
    - 12V pin 14: blue
    - 12V pin 15: pink
    - 12V pin 33: brown
    - 12V pin 34: green
    - GND pin  6: red
    - GND pin  8: white
    - GND pin 10: grey
    - GND pin 12: black
    - CEC pin 24: yellow
    - 232RX pin 23: orange
    - 232TX pin  5: purple
    - HDMI TMDS Clock+ 26: green
    - HDMI TMDS Data0+ 28: blue
    - HDMI TMDS Data1+ 30: red
    - HDMI TMDS Data2+ 32: brown
