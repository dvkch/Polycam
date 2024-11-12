<img src="Docs/Icon/README-AppIcon.png" width=64 />

# Polycam

Controlling a Polycom EagleEye IV camera through its original HDCI cable, or <i>A reverse engineering rabbit hole</i>

To be able to connect to the camera using its original cable, here are roughly the steps :

- cut your cable
- identify all cables, according to [this document](Docs/Analysis/README.md)
- connect the HDMI cables to a breakout HDMI plug, like [this one](https://www.amazon.fr/SIENOC-Bornier-Breakout-Connecteur-Black/dp/B07FYGPFR5) and a
- acquire the HDMI signal using a simple USB-HDMI capture card, like [this one](https://www.amazon.fr/Adaptateur-Portable-Streaming-Enregistrement-Diffusion/dp/B0B7DSPPNX)
- connect the serial cables to a RS423 adapter like [this amazing one by CircuitSurgery](https://www.circuitsurgery.com/bbcrs423adapt.html) (thanks again for saving this project!)
- get a 12V charger for the camera itself, while it can be powered through its HDCI cable, powering it through the power plug it also has seems safer
- build `ptz` using `swift build`
- you should now be able to `ptz` commands and access your camera feed via `/dev/video0` !

Wanna go further ? This repository contains some tools to turn your camera into an ONVIF compatible camera, supporting PTZ requests.

- building:
  - via docker : `docker compose up --build`
  - locally : `./onvif.sh`
- accessing:
  - [IPCams](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://ipcams.app/&ved=2ahUKEwjE5f226NeJAxX4Q6QEHbWoAtwQFnoECA4QAQ&usg=AOvVaw0MhM--gDy4lm8oofamOkCa)
  - [Synology](https://www.synology.com/en-global/compatibility/camera/29211)

Wanna see more details about the reverse engineering steps? [Read my notes here](Docs/Analysis/README.md)

Nota:

- the `onvif.sh` script *will* mess up your lighttpd configuration! running via docker is safer, but will be slower as well.
- this has only be tested on a RaspberryPi 4 with a disposable install.
- while manual focus is supported by `ptz`, it is not yet supported by [onvif_simple_server](https://github.com/roleoroleo/onvif_simple_server), and will not be available over ONVIF.

## Swift packages

### PTZ

This is the CLI executable. It supports the following commands:

- `ptz interactive`: runs a TUI to control the camera with the keyboard. not all configurations are possible in this interface to keep it simple
- `ptz read`: allows reading the current state of the camera, for instance: `ptz read all` or `ptz read brightness position preset(4) contrast clock(t1)`
- `ptz write`: update the state of the camera, for instance: `ptz movePan(left)=50 pause=2 movePan(stop)=0` or `ptz boot videoOutput=720p60 whiteBalance=5200K`
- `ptz preset`: allows the creation, listing and deletion of named presets. The presets are stored in a configuration file. While the camera itself can store presets, they cannot have names and cannot be easily manipulated (removing index 3 would make no sense for instance, but it is requried by ONVIF)
- `ptz advanced benchmark`: benchmarks the communication speed between the camera and the computer. helpful while writing the code, probably not a lot today
- `ptz advanced fuzzer`: runs all possible commands on the camera and outputs potentially functional commands. Careful with this, might be dangerous and leave your camera in a weird state (`ptz write reset=settings` might help there)
- `ptz advanced tester`: often-rewritten command to help me analyse newly discovered commands

Full list of supported commands and their arguments is available by running the tool itself.

### PTZCamera

This is the library package, defining all possible configurations and actions supported by the EagleEye IV. A lot of work has been put into this over the last two years, while I cannot garantee that all commands are safe, I feel pretty confident in my understanding and implementation for all of them.

Full list of supported camera commands is visible in the [fuzzer report](Docs/FuzzerResults.md).

### PTZCameraMacros

Defines a simple macro to generate getters and setters for all states inside the `Camera` model defined by `PTZCamera`.

### PTZMessaging

This package creates the building blocks for the PTZ communication over serial. The message format is deduced by days and months of reverse engineering and except for the `hello` reply I feel pretty confident that this implements the JCCP protocol used by the EagleEye IV.
