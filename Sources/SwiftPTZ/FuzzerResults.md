Output of the Fuzzer command, for more details on the fuzzed ranges, see the command itself.

Marks:

- `√`: the command is known and has been implemented
- `1`: the command was extensively tested, but setting it to different values never revealed any visible changes in behaviour or output
- `2`: the command was tested, but no setter is available or easily testable, and it was not obvious what the values from the getter correspond to
- `3`: the command was tested but the setter always returns a `mode condition` error. playing with all other known setters to try and put the camera in better conditions did not help and the setter was never run successfully
- ` `: means the command is still being explored

Commands that weren't found, but i wouldn't be suprised to see there:

- time since turned on / total usage time
- number of faces visible
- movement currently in progress
- time remaining before auto standby
- action to immediately move to a preset position


Getters
-------

| Request  | Status | Reply & notes                                            |
|----------|--------|----------------------------------------------------------|
| 8x 01 00 |   √    | PowerMode(on)
| 8x 01 01 |   √    | AutoSleep(off)
| 8x 01 02 |   1    | Unknown(83 41 02 00)
| 8x 01 0B |   √    | DevMode(on)
| 8x 01 10 |   √    | MireMode(off)
| 8x 01 13 |   √    | VideoOutputMode(1080p60)
| 8x 01 14 |   2    | Unknown(83 41 14 00) // sometimes replies 01 when requested in between random requests, no pattern found
| 8x 01 21 |   √    | LedMode(blue, on)
| 8x 01 23 |   1    | Unknown(83 41 23 00)
| 8x 01 24 |   1    | Unknown(83 41 24 00)
| 8x 01 25 |   √    | LedIntensity(R=8, G=8, B=8)
| 8x 01 31 |   √    | GainMode(auto)
| 8x 01 32 |   √    | Contrast(10)
| 8x 01 33 |   √    | Brightness(11)
| 8x 01 34 |   √    | WideDynamicRange(on)
| 8x 01 3A |   √    | Colors(on)
| 8x 01 3B |   √    | SensorSmoothing(on)
| 8x 01 3C |   √    | NoiseReduction(on)
| 8x 01 3D |   √    | VignetteCorrection(on)
| 8x 01 3E |   √    | InvertedMode(off)
| 8x 01 41 |   2    | Unknown(88 41 41 00 00 00 00 00 00)
| 8x 01 42 |   √    | DrunkTestPhase(Never launched)
| 8x 01 43 |   1    | Unknown(83 41 43 01)
| 8x 01 44 |   2    | Unknown(8F 0F 41 44 3A 00 1B 04 1B 1B 1B 24 04 00 0A 1B) > Changes very often, see ScratchPad-01-44 for an example output
| 8x 01 50 |   √    | Position(1000, 250, 64)
| 8x 01 59 |   √    | MotorStats(Unknown=3036676096, None=0)
| 8x 01 5A |   √    | MotorStats(Focus=3750110, Zoom=6725)
| 8x 01 5B |   √    | MotorStats(None=0, Iris=25966)
| 8x 01 5C |   √    | MotorStats(Pan=90035, Tilt=67062)
| 8x 01 5D |   √    | Clock 1 (t=4130829)
| 8x 01 5E |   √    | Clock 2 (t=3767572)
| 8x 01 60 |   √    | Preset(one: 0, 0, 0)
| 8x 01 61 |   √    | Preset(two: 0, 0, 0)
| 8x 01 62 |   √    | Preset(three: 0, 0, 0)
| 8x 01 63 |   √    | Preset(four: 770, 30466, 0)
| 8x 01 64 |   √    | Preset(five: 766, 7, 0)
| 8x 01 65 |   √    | Preset(six: 2690, 2306, 0)
| 8x 01 66 |   √    | Preset(seven: 597, 318, 0)
| 8x 01 67 |   √    | Preset(eight: 11265, 7681, 0)
| 8x 01 71 |   2    | Unknown(83 41 71 00) // Couldn't make it reply anything else than 00
| 8x 01 72 |   1    | Unknown(83 41 72 00)


Getters
-------

| Request  | Status | Reply & notes              |
|----------|--------|----------------------------|
| 8x 02 09 |   √    | AutoFocus(off)
| 8x 02 11 |   √    | AutoExposure(on)
| 8x 02 12 |   √    | WhiteBalance(auto)
| 8x 02 14 |   √    | ShutterSpeed(auto)
| 8x 02 15 |   √    | BacklightCompensation(off)
| 8x 02 22 |   1    | Unknown(83 42 22 01)


Getters
-------

| Request  | Status | Reply & notes                      |
|----------|--------|------------------------------------|
| 8x 03 00 |   √    | IrisLevel(219)
| 8x 03 02 |   √    | Zoom(64)
| 8x 03 03 |   √    | Focus(768)
| 8x 03 04 |   √    | Pan(1000)
| 8x 03 05 |   √    | Tilt(250)
| 8x 03 26 |   √    | EffectiveGain(13dB)
| 8x 03 3D |   √    | Sharpness(6)
| 8x 03 3E |   √    | Saturation(6)
| 8x 03 3F |   √    | WhiteLevel(90%)
| 8x 03 40 |   √    | WBTint(128)
| 8x 03 41 |   √    | WBTemp(104)
| 8x 03 42 |   √    | RedGain(35)
| 8x 03 43 |   √    | BlueGain(35)
| 8x 03 50 |   √    | CalibrationHue(red, 128)
| 8x 03 51 |   √    | CalibrationHue(orange, 128)
| 8x 03 52 |   √    | CalibrationHue(green, 128)
| 8x 03 53 |   √    | CalibrationHue(cyan, 128)
| 8x 03 54 |   √    | CalibrationHue(blue, 128)
| 8x 03 55 |   √    | CalibrationHue(purple, 128)
| 8x 03 56 |   √    | CalibrationLuminance(red, 128)
| 8x 03 57 |   √    | CalibrationLuminance(orange, 128)
| 8x 03 58 |   √    | CalibrationLuminance(green, 128)
| 8x 03 59 |   √    | CalibrationLuminance(cyan, 128)
| 8x 03 5A |   √    | CalibrationLuminance(blue, 128)
| 8x 03 5B |   √    | CalibrationLuminance(purple, 128)
| 8x 03 5C |   √    | CalibrationSaturation(red, 128)
| 8x 03 5D |   √    | CalibrationSaturation(orange, 128)
| 8x 03 5E |   √    | CalibrationSaturation(green, 128)
| 8x 03 5F |   √    | CalibrationSaturation(cyan, 128)
| 8x 03 60 |   √    | CalibrationSaturation(blue, 128)
| 8x 03 61 |   √    | CalibrationSaturation(purple, 128)


Hello
-----

| Request  | Status | Reply & notes                                                                                          |
|----------|--------|--------------------------------------------------------------------------------------------------------|
| 8x 06 77 |   √    | MPTZ 11(sysVer=01000057 camVer=01010052 backVer=01000021 bootVer=01000006 splVer=2950 pkgVer=01010048)


Setters
-------

| Request                | Status | Reply & notes                     |
|------------------------|--------|-----------------------------------|
| 8x 41 00               |   √    | Skipped: Power mode
| 8x 41 01 (00 -> 30)    |   √    | Executed: AutoSleep(off)
| 8x 41 02 (00 -> 02)    |   1    | Executed 
| 8x 41 0B (00 -> 01)    |   √    | Executed: DevMode(off)
| 8x 41 0C 01 (00 -> 01) |   1    | Executed // in Dev mode there is a whole subrange of boolean registers, from 01 0C 00 to 01 0C 2B. Couldn't find their use
| 8x 41 10               |   √    | Skipped: Mire mode
| 8x 41 13               |   √    | Skipped: Video output
| 8x 41 21               |   √    | Skipped: LED mode
| 8x 41 23 (00 -> 10)    |   1    | Executed
| 8x 41 24 (00 -> 01)    |   1    | Executed
| 8x 41 31 (00 -> 05)    |   √    | Executed: GainMode(0dB)
| 8x 41 32 (76 -> 01 0A) |   √    | Executed: Contrast(0)
| 8x 41 33 (76 -> 01 0A) |   √    | Executed: Brightness(1)
| 8x 41 34 (00 -> 01)    |   √    | Executed: WideDynamicRange(off)
| 8x 41 3A (00 -> 01)    |   √    | Executed: Colors(off)
| 8x 41 3B (00 -> 01)    |   √    | Executed: SensorSmoothing(off)
| 8x 41 3C (00 -> 01)    |   √    | Executed: NoiseReduction(off)
| 8x 41 3D (00 -> 01)    |   √    | Executed: VignetteCorrection(off)
| 8x 41 3E (00 -> 01)    |   √    | Executed: InvertedMode(off)
| 8x 41 43 (01 -> 7F)    |   1    | Executed
| 8x 41 70               |   √    | Skipped: Unknown
| 8x 41 72 (00 -> 01)    |   1    | Executed


Setters
-------

| Request             | Status | Reply & notes                                   |
|---------------------|--------|-------------------------------------------------|
| 8x 42 09 (00 -> 01) |   √    | Executed: AutoFocus(off)
| 8x 42 11 (00 -> 01) |   √    | Not executed: Mode condition: AutoExposure(off)
| 8x 42 12 01         |   √    | Executed: WhiteBalance(auto)
| 8x 42 12 (04 -> 0A) |   √    | Executed: WhiteBalance(manual)
| 8x 42 14 (00 -> 08) |   √    | Executed: ShutterSpeed(auto)
| 8x 42 15 (00 -> 04) |   √    | Executed: BacklightCompensation(off)
| 8x 42 22 (00 -> 01) |   1    | Executed


Setters
-------

| Request                 | Status | Reply & notes                                |
|-------------------------|--------|----------------------------------------------|
| 8x 43 00 (00 -> 01 10+) |   √    | Not executed: Mode condition: IrisLevel(0)
| 8x 43 02                |   √    | Skipped: Zoom
| 8x 43 03 (00 -> 01 10+) |   √    | Not executed: Syntax error: Focus(0)
| 8x 43 04                |   √    | Skipped: Pan
| 8x 43 05 (00 -> 03 74)  |   √    | Executed: Tilt(0)
| 8x 43 3D (7B -> 01 05)  |   √    | Executed: Sharpness(1)
| 8x 43 3E (7B -> 01 05)  |   √    | Executed: Saturation(1)
| 8x 43 3F 5A             |   √    | Executed: WhiteLevel(90%)
| 8x 43 3F 64             |   √    | Executed: WhiteLevel(100%)
| 8x 43 40 (60 -> 71+)    |   √    | Not executed: Mode condition: WBTint(96)
| 8x 43 41 (60 -> 71+)    |   √    | Not executed: Mode condition: WBTemp(96)
| 8x 43 42 (60 -> 01 1F)  |   √    | Executed: RedGain(1)
| 8x 43 43 (60 -> 01 1F)  |   √    | Executed: BlueGain(1)
| 8x 43 50 (7B -> 01 05)  |   √    | Executed: CalibrationHue(red, 123)
| 8x 43 51 (7B -> 01 05)  |   √    | Executed: CalibrationHue(orange, 123)
| 8x 43 52 (7B -> 01 05)  |   √    | Executed: CalibrationHue(green, 123)
| 8x 43 53 (7B -> 01 05)  |   √    | Executed: CalibrationHue(cyan, 123)
| 8x 43 54 (7B -> 01 05)  |   √    | Executed: CalibrationHue(blue, 123)
| 8x 43 55 (7B -> 01 05)  |   √    | Executed: CalibrationHue(purple, 123)
| 8x 43 56 (76 -> 01 0A)  |   √    | Executed: CalibrationLuminance(red, 118)
| 8x 43 57 (76 -> 01 0A)  |   √    | Executed: CalibrationLuminance(orange, 118)
| 8x 43 58 (76 -> 01 0A)  |   √    | Executed: CalibrationLuminance(green, 118)
| 8x 43 59 (76 -> 01 0A)  |   √    | Executed: CalibrationLuminance(cyan, 118)
| 8x 43 5A (76 -> 01 0A)  |   √    | Executed: CalibrationLuminance(blue, 118)
| 8x 43 5B (76 -> 01 0A)  |   √    | Executed: CalibrationLuminance(purple, 118)
| 8x 43 5C (76 -> 01 0A)  |   √    | Executed: CalibrationSaturation(red, 118)
| 8x 43 5D (76 -> 01 0A)  |   √    | Executed: CalibrationSaturation(orange, 118)
| 8x 43 5E (76 -> 01 0A)  |   √    | Executed: CalibrationSaturation(green, 118)
| 8x 43 5F (76 -> 01 0A)  |   √    | Executed: CalibrationSaturation(cyan, 118)
| 8x 43 60 (76 -> 01 0A)  |   √    | Executed: CalibrationSaturation(blue, 118)
| 8x 43 61 (76 -> 01 0A)  |   √    | Executed: CalibrationSaturation(purple, 118)


Actions
-------

| Request             | Status | Reply & notes                                                        |
|---------------------|--------|----------------------------------------------------------------------|
| 8x 45 00 (10 -> 1F) |   √    | Executed: Move pan right
| 8x 45 01 (10 -> 1F) |   √    | Executed: Move pan left
| 8x 45 02            |   √    | Executed: Move pan stop
| 8x 45 03 (10 -> 1F) |   √    | Executed: Move tilt up
| 8x 45 04 (10 -> 1F) |   √    | Executed: Move tilt down
| 8x 45 05            |   √    | Executed: Move tilt stop
| 8x 45 09 (00 -> 03) |   √    | Executed: Move focus far
| 8x 45 0A (00 -> 03) |   √    | Executed: Move focus near
| 8x 45 0B            |   √    | Executed: Move focus stop
| 8x 45 0C (00 -> 03) |   √    | Executed: Move zoom+
| 8x 45 0D (00 -> 03) |   √    | Executed: Move zoom-
| 8x 45 0E            |   √    | Executed: Move zoom stop
| 8x 45 13            |   √    | Executed: Start focus
| 8x 45 14            |   √    | Skipped: DrunkTest
| 8x 45 17            |   √    | Not executed: Mode condition: Start manual white balance calibration
| 8x 45 32            |   √    | Skipped: Reset
| 8x 45 71            |   3    | Not executed: Mode condition


Stats
-----

| Name          | Value |
|---------------|-------|
| Duration      | 261   |
| Requests sent | 12262 |
