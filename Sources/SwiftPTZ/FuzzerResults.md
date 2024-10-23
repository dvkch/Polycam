Running all possible commands from 00 00 to 0A 7F, then from 40 00 to 4A 7F, with one argument in (none, 00, 01), all replies are filtered to ignore : Fail, Reset, Command not defined, Syntax error.

Here are the detected commands, a cross next to it confirms we know it and implement it.

Marks:

- `X` means the command is known
- `/` means we gave up on undertsanding it (reason should be written after the reply string)
- ` ` means the command is still being explored


Getters
-------
8x 01 00                  | X | StandbyMode(unknown 1 (0x00))
8x 01 01                  |   | Unknown(83 41 01 00)
8x 01 02                  |   | Unknown(83 41 02 00)
8x 01 0B                  | X | DevMode(on)
8x 01 10                  | X | MireMode(off)
8x 01 13                  | X | VideoOutputMode(1080p)
8x 01 14                  | / | Unknown(83 41 14 00) -> No corresponding setter, sometimes replies 01 when requested in between random requests, no pattern found
8x 01 21                  | X | LedMode(blue, on)
8x 01 23                  |   | Unknown(83 41 23 00)
8x 01 24                  |   | Unknown(83 41 24 00)
8x 01 25                  | X | Volume(default)
8x 01 31                  | X | GainMode(auto)
8x 01 32                  | X | Contrast(20)
8x 01 33                  | X | Brightness(11)
8x 01 34                  |   | Unknown(83 41 34 01)
8x 01 3A                  | X | Colors(on)
8x 01 3B                  | X | SensorSmoothing(on)
8x 01 3C                  | X | NoiseReduction(on)
8x 01 3D                  | X | VignetteCorrection(on)
8x 01 3E                  | X | InvertedMode(off)
8x 01 41                  |   | Unknown(88 41 41 00 00 00 00 00 00)
8x 01 42                  | X | DrunkTestPhase(Never launched)
8x 01 43                  |   | Unknown(83 41 43 7E)
8x 01 44                  | / | Unknown(8F 0F 41 44 7A 00 4C 04 4C 4C 4C 78 04 44 08 4C) > Randomness? value changes every time we read it, and it is not settable (syntax error)
8x 01 50                  | X | Position(1000, 250, 64)
8x 01 59                  |   | Unknown(8D 41 59 01 35 00 00 00 00 00 00 00 00 00)
8x 01 5A                  |   | Unknown(8D 41 5A 08 00 32 42 11 00 00 17 01 52 00)
8x 01 5B                  |   | Unknown(8D 41 5B 00 00 00 00 00 00 00 5E 00 3B 00)
8x 01 5C                  |   | Unknown(8D 41 5C 08 00 01 02 36 00 00 35 01 0D 00)
8x 01 5D                  | X | Clock 1 (t=3515819)
8x 01 5E                  | X | Clock 2 (t=3513582)
8x 01 60                  | X | Preset(one: 0, 0, 0)
8x 01 61                  | X | Preset(two: 0, 0, 0)
8x 01 62                  | X | Preset(three: 0, 0, 0)
8x 01 63                  | X | Preset(four: 770, 30466, 0)
8x 01 64                  | X | Preset(five: 766, 7, 0)
8x 01 65                  | X | Preset(six: 2690, 2306, 0)
8x 01 66                  | X | Preset(seven: 597, 318, 0)
8x 01 67                  | X | Preset(eight: 11265, 7681, 0)
8x 01 71                  | / | Unknown(83 41 71 00) -> No corresponding setter, couldn't make it reply anything else than 00
8x 01 72                  |   | Unknown(83 41 72 00)


Getters
-------
8x 02 09                  | X | AutoFocus(off)
8x 02 11                  | X | AutoExposure(on)
8x 02 12                  | X | WhiteBalance(auto)
8x 02 14                  | X | ShutterSpeed(auto)
8x 02 15                  | X | BacklightCompensation(off)
8x 02 22                  |   | Unknown(83 42 22 01)


Getters
-------
8x 03 00                  | X | IrisLevel(155)
8x 03 02                  | X | Zoom(64)
8x 03 03                  | X | Focus(391)
8x 03 04                  | X | Pan(1000)
8x 03 05                  | X | Tilt(250)
8x 03 26                  | X | EffectiveGain(0dB)
8x 03 3D                  | X | Sharpness(6)
8x 03 3E                  | X | Saturation(6)
8x 03 3F                  | X | WhiteLevel(90%)
8x 03 40                  | X | WBTint(149)
8x 03 41                  | X | WBTemp(127)
8x 03 42                  | X | RedGain(35)
8x 03 43                  | X | BlueGain(35)
8x 03 50                  | X | CalibrationHue(red, 128)
8x 03 51                  | X | CalibrationHue(orange, 128)
8x 03 52                  | X | CalibrationHue(green, 128)
8x 03 53                  | X | CalibrationHue(cyan, 128)
8x 03 54                  | X | CalibrationHue(blue, 128)
8x 03 55                  | X | CalibrationHue(purple, 128)
8x 03 56                  | X | CalibrationLuminance(red, 128)
8x 03 57                  | X | CalibrationLuminance(orange, 128)
8x 03 58                  | X | CalibrationLuminance(green, 128)
8x 03 59                  | X | CalibrationLuminance(cyan, 128)
8x 03 5A                  | X | CalibrationLuminance(blue, 128)
8x 03 5B                  | X | CalibrationLuminance(purple, 128)
8x 03 5C                  | X | CalibrationSaturation(red, 128)
8x 03 5D                  | X | CalibrationSaturation(orange, 128)
8x 03 5E                  | X | CalibrationSaturation(green, 128)
8x 03 5F                  | X | CalibrationSaturation(cyan, 128)
8x 03 60                  | X | CalibrationSaturation(blue, 128)
8x 03 61                  | X | CalibrationSaturation(purple, 128)


Hello
-----
8x 06 77                  | X | MPTZ 11(sysVer=01000057 camVer=01010052 backVer=01000021 bootVer=01000006 splVer=2950 pkgVer=01010048)


Setters
-------
8x 41 00                  | X | Skipped: Standby mode
8x 41 01 (00 -> 30)       |   | Executed
8x 41 02 (00 -> 02)       |   | Executed
8x 41 0B (00 -> 01)       | X | Executed: DevMode(off)
8x 41 0C 01 (00 -> 01)    | / | Executed -> in Dev mode there is a whole subrange of boolean registers, from 01 0C 00 to 01 0C 2B. Couldn't find their use
8x 41 10                  | X | Skipped: Mire mode
8x 41 13                  | X | Skipped: Video output
8x 41 21                  | X | Skipped: LED mode
8x 41 23 (00 -> 10)       |   | Executed
8x 41 24 (00 -> 01)       |   | Executed
8x 41 31 (00 -> 05)       | X | Executed: GainMode(0dB)
8x 41 32 (76 -> 01 0A)    | X | Executed: Contrast(0)
8x 41 33 (76 -> 01 0A)    | X | Executed: Brightness(1)
8x 41 34 (00 -> 01)       |   | Executed
8x 41 3A (00 -> 01)       | X | Executed: Colors(off)
8x 41 3B (00 -> 01)       | X | Executed: SensorSmoothing(off)
8x 41 3C (00 -> 01)       | X | Executed: NoiseReduction(off)
8x 41 3D (00 -> 01)       | X | Executed: VignetteCorrection(off)
8x 41 3E (00 -> 01)       | X | Executed: InvertedMode(off)
8x 41 43 (01 -> 7F)       |   | Executed
8x 41 70                  | X | Skipped: Unknown
8x 41 72 (00 -> 01)       |   | Executed


Setters
-------
8x 42 09 (00 -> 01)       | X | Executed: AutoFocus(off)
8x 42 11 (00 -> 01)       | X | Not executed: Mode condition: AutoExposure(off)
8x 42 12 01               | X | Executed: WhiteBalance(auto)
8x 42 12 (04 -> 0A)       | X | Executed: WhiteBalance(manual)
8x 42 14 (00 -> 08)       | X | Executed: ShutterSpeed(auto)
8x 42 15 (00 -> 04)       | X | Executed: BacklightCompensation(off)
8x 42 22 (00 -> 01)       |   | Executed


Setters
-------
8x 43 00 (00 -> 02 00+)   | X | Not executed: Mode condition: IrisLevel(0)
8x 43 02 (40 -> 11 35)    | X | Executed: Zoom(64)
8x 43 03 (01 70 -> 06 00) | X | Executed: Focus(240)
8x 43 04 (00 -> 0F 50)    | X | Executed: Pan(0)
8x 43 05 (00 -> 03 74)    | X | Executed: Tilt(0)
8x 43 3D (7B -> 01 05)    | X | Executed: Sharpness(1)
8x 43 3E (7B -> 01 05)    | X | Executed: Saturation(1)
8x 43 3F 5A               | X | Executed: WhiteLevel(90%)
8x 43 3F 64               | X | Executed: WhiteLevel(100%)
8x 43 40 (60 -> 01 01+)   | X | Not executed: Mode condition: WBTint(96)
8x 43 41 (60 -> 01 01+)   | X | Not executed: Mode condition: WBTemp(96)
8x 43 42 (60 -> 01 1F)    | X | Executed: RedGain(1)
8x 43 43 (60 -> 01 1F)    | X | Executed: BlueGain(1)
8x 43 50 (7B -> 01 05)    | X | Executed: CalibrationHue(red, 123)
8x 43 51 (7B -> 01 05)    | X | Executed: CalibrationHue(orange, 123)
8x 43 52 (7B -> 01 05)    | X | Executed: CalibrationHue(green, 123)
8x 43 53 (7B -> 01 05)    | X | Executed: CalibrationHue(cyan, 123)
8x 43 54 (7B -> 01 05)    | X | Executed: CalibrationHue(blue, 123)
8x 43 55 (7B -> 01 05)    | X | Executed: CalibrationHue(purple, 123)
8x 43 56 (76 -> 01 0A)    | X | Executed: CalibrationLuminance(red, 118)
8x 43 57 (76 -> 01 0A)    | X | Executed: CalibrationLuminance(orange, 118)
8x 43 58 (76 -> 01 0A)    | X | Executed: CalibrationLuminance(green, 118)
8x 43 59 (76 -> 01 0A)    | X | Executed: CalibrationLuminance(cyan, 118)
8x 43 5A (76 -> 01 0A)    | X | Executed: CalibrationLuminance(blue, 118)
8x 43 5B (76 -> 01 0A)    | X | Executed: CalibrationLuminance(purple, 118)
8x 43 5C (76 -> 01 0A)    | X | Executed: CalibrationSaturation(red, 118)
8x 43 5D (76 -> 01 0A)    | X | Executed: CalibrationSaturation(orange, 118)
8x 43 5E (76 -> 01 0A)    | X | Executed: CalibrationSaturation(green, 118)
8x 43 5F (76 -> 01 0A)    | X | Executed: CalibrationSaturation(cyan, 118)
8x 43 60 (76 -> 01 0A)    | X | Executed: CalibrationSaturation(blue, 118)
8x 43 61 (76 -> 01 0A)    | X | Executed: CalibrationSaturation(purple, 118)


Actions
-------
8x 45 00 (10 -> 1F)       | X | Executed: Move pan right
8x 45 01 (10 -> 1F)       | X | Executed: Move pan left
8x 45 02                  | X | Executed: Move pan stop
8x 45 03 (10 -> 1F)       | X | Executed: Move tilt up
8x 45 04 (10 -> 1F)       | X | Executed: Move tilt down
8x 45 05                  | X | Executed: Move tilt stop
8x 45 09 (00 -> 03)       | X | Executed: Move focus far
8x 45 0A (00 -> 03)       | X | Executed: Move focus near
8x 45 0B                  | X | Executed: Move focus stop
8x 45 0C (00 -> 03)       | X | Executed: Move zoom+
8x 45 0D (00 -> 03)       | X | Executed: Move zoom-
8x 45 0E                  | X | Executed: Move zoom stop
8x 45 13                  | X | Executed: Start focus
8x 45 14                  | X | Skipped: DrunkTest
8x 45 17                  | X | Not executed: Mode condition: Start manual white balance calibration
8x 45 32                  | X | Skipped: Reset
8x 45 71                  | / | Not executed: Mode condition > couldn't find a request to run before this one to handle the "mode condition"


Stats
-----
Duration: 605 seconds
