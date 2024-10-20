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
8x 01 32                  |   | Unknown(84 41 32 01 00)
8x 01 33                  | X | Brightness(11)
8x 01 34                  |   | Unknown(83 41 34 01)
8x 01 3A                  |   | Unknown(83 41 3A 01)
8x 01 3B                  |   | Unknown(83 41 3B 01)
8x 01 3C                  |   | Unknown(83 41 3C 01)
8x 01 3D                  |   | Unknown(83 41 3D 01)
8x 01 3E                  | X | InvertedMode(off)
8x 01 41                  |   | Unknown(88 41 41 00 00 00 00 00 00)
8x 01 42                  | X | DrunkTestPhase(Never launched)
8x 01 43                  |   | Unknown(83 41 43 01)
8x 01 44                  | / | Unknown(8F 0F 41 44 7A 00 4C 04 4C 4C 4C 78 04 44 08 4C) > Randomness? value changes every time we read it, and it is not settable (syntax error)
8x 01 50                  | X | Position(1000, 250, 64)
8x 01 59                  |   | Unknown(8D 41 59 01 35 00 00 00 00 00 00 00 00 00)
8x 01 5A                  |   | Unknown(8D 41 5A 0C 00 31 14 53 00 00 17 01 27 00)
8x 01 5B                  |   | Unknown(8D 41 5B 00 00 00 00 00 00 00 5D 00 35 00)
8x 01 5C                  |   | Unknown(8D 41 5C 0C 00 00 50 02 00 00 20 01 16 00)
8x 01 5D                  | X | Clock 1 (t=3308789)
8x 01 5E                  | X | Clock 2 (t=3306553)
8x 01 60                  | X | Preset(one: 0, 0, 0)
8x 01 61                  | X | Preset(two: 0, 0, 0)
8x 01 62                  | X | Preset(three: 0, 0, 0)
8x 01 63                  | X | Preset(four: 770, 30467, 0)
8x 01 64                  | X | Preset(five: 766, 6, 0)
8x 01 65                  | X | Preset(six: 642, 2050, 0)
8x 01 66                  | X | Preset(seven: 725, 316, 0)
8x 01 67                  | X | Preset(eight: 11265, 7169, 0)
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
8x 03 00                  | X | IrisLevel(222)
8x 03 02                  | X | Zoom(64)
8x 03 03                  | X | Focus(133)
8x 03 04                  | X | Pan(238)
8x 03 05                  | X | Tilt(250)
8x 03 26                  | X | EffectiveGain(14dB)
8x 03 3D                  | X | Sharpness(11)
8x 03 3E                  | X | Saturation(6)
8x 03 3F                  | X | WhiteLevel(100%)
8x 03 40                  | X | WBTint(128)
8x 03 41                  | X | WBTemp(128)
8x 03 42                  | X | RedGain(35)
8x 03 43                  | X | BlueGain(35)
8x 03 50                  |   | Unknown(84 43 50 01 00)
8x 03 51                  |   | Unknown(84 43 51 01 00)
8x 03 52                  |   | Unknown(84 43 52 01 00)
8x 03 53                  |   | Unknown(84 43 53 01 00)
8x 03 54                  |   | Unknown(84 43 54 01 00)
8x 03 55                  |   | Unknown(84 43 55 01 00)
8x 03 56                  |   | Unknown(84 43 56 01 00)
8x 03 57                  |   | Unknown(84 43 57 01 00)
8x 03 58                  |   | Unknown(84 43 58 01 00)
8x 03 59                  |   | Unknown(84 43 59 01 00)
8x 03 5A                  |   | Unknown(84 43 5A 01 00)
8x 03 5B                  |   | Unknown(84 43 5B 01 00)
8x 03 5C                  |   | Unknown(84 43 5C 01 00)
8x 03 5D                  |   | Unknown(84 43 5D 01 00)
8x 03 5E                  |   | Unknown(84 43 5E 01 00)
8x 03 5F                  |   | Unknown(84 43 5F 01 00)
8x 03 60                  |   | Unknown(84 43 60 01 00)
8x 03 61                  |   | Unknown(84 43 61 01 00)


Hello
-----
8x 06 77                  | X | MPTZ 11(sysVer=01000057 camVer=01010052 backVer=01000021 bootVer=01000006 splVer=2950 pkgVer=01010048)


Setters
-------
8x 41 00                  | X | Skipped: Standby mode
8x 41 01 (00 -> 30)       |   | Executed
8x 41 02 (00 -> 02)       |   | Executed
8x 41 0B (00 -> 01)       | X | Executed: DevMode(off)
8x 41 0C 01 (00 -> 01)    |   | Executed
8x 41 10                  | X | Skipped: Mire mode
8x 41 13                  | X | Skipped: Video output
8x 41 21                  | X | Skipped: LED mode
8x 41 23 (00 -> 10)       |   | Executed
8x 41 24 (00 -> 01)       |   | Executed
8x 41 31 (00 -> 05)       | X | Executed: GainMode(0dB)
8x 41 32 (76 -> 01 0A)    |   | Executed
8x 41 33 (76 -> 01 0A)    | X | Executed: Brightness(1)
8x 41 34 (00 -> 01)       |   | Executed
8x 41 3A (00 -> 01)       |   | Executed
8x 41 3B (00 -> 01)       |   | Executed
8x 41 3C (00 -> 01)       |   | Executed
8x 41 3D (00 -> 01)       |   | Executed
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
8x 43 42 (60 -> 01 01+)   | X | Not executed: Mode condition: RedGain(1)
8x 43 43 (60 -> 01 01+)   | X | Not executed: Mode condition: BlueGain(1)
8x 43 50 (7B -> 01 05)    |   | Executed
8x 43 51 (7B -> 01 05)    |   | Executed
8x 43 52 (7B -> 01 05)    |   | Executed
8x 43 53 (7B -> 01 05)    |   | Executed
8x 43 54 (7B -> 01 05)    |   | Executed
8x 43 55 (7B -> 01 05)    |   | Executed
8x 43 56 (76 -> 01 0A)    |   | Executed
8x 43 57 (76 -> 01 0A)    |   | Executed
8x 43 58 (76 -> 01 0A)    |   | Executed
8x 43 59 (76 -> 01 0A)    |   | Executed
8x 43 5A (76 -> 01 0A)    |   | Executed
8x 43 5B (76 -> 01 0A)    |   | Executed
8x 43 5C (76 -> 01 0A)    |   | Executed
8x 43 5D (76 -> 01 0A)    |   | Executed
8x 43 5E (76 -> 01 0A)    |   | Executed
8x 43 5F (76 -> 01 0A)    |   | Executed
8x 43 60 (76 -> 01 0A)    |   | Executed
8x 43 61 (76 -> 01 0A)    |   | Executed


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
8x 45 13                  |   | Executed
8x 45 14                  | X | Skipped: DrunkTest
8x 45 17                  | X | Not executed: Mode condition: Start manual white balance calibration
8x 45 32                  | X | Skipped: Reset
8x 45 71                  | / | Not executed: Mode condition > couldn't find a request to run before this one to handle the "mode condition"


Stats
-----
Duration: 605 seconds
