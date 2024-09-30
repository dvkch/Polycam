Running all possible commands from 00 00 to 0A 7F, then from 40 00 to 4A 7F, with one argument in (none, 00, 01), all replies are filtered to ignore : Fail, Reset, Command not defined, Syntax error.

Here are the detected commands, a cross next to it confirms we know it and implement it.

Getters
-------
8x 01 00                  | X | StandbyMode(unknown 1 (0x00))
8x 01 01                  |   | Unknown(83 41 01 00)
8x 01 02                  |   | Unknown(83 41 02 01)
8x 01 0B                  |   | Unknown(83 41 0B 00)
8x 01 10                  | X | MireMode(off)
8x 01 13                  | X | VideoOutputMode(1080p)
8x 01 14                  |   | -> Corresponding setter fails
8x 01 21                  | X | LedMode(blue, on)
8x 01 23                  |   | Unknown(83 41 23 00)
8x 01 24                  |   | Unknown(83 41 24 01)
8x 01 25                  | X | Volume(8)
8x 01 31                  | X | GainMode(auto)
8x 01 32                  |   | Unknown(84 41 32 01 00)
8x 01 33                  | X | Brightness(11)
8x 01 34                  |   | Unknown(83 41 34 01)
8x 01 3B                  |   | Unknown(83 41 3B 01)
8x 01 3C                  |   | Unknown(83 41 3C 01)
8x 01 3D                  |   | Unknown(83 41 3D 01)
8x 01 3E                  | X | InvertedMode(off)
8x 01 44                  |   | > Randomness?
8x 01 50                  | X | Position(1000, 250, 64)
8x 01 5D                  | X | Clock 1 (t=594142)
8x 01 5E                  | X | Clock 2 (t=594140)
8x 01 60                  | X | Preset(one: 0, 0, 0)
8x 01 61                  | X | Preset(two: 0, 0, 0)
8x 01 62                  | X | Preset(three: 0, 0, 0)
8x 01 63                  | X | Preset(four: 770, 30720, 0)
8x 01 64                  | X | Preset(five: 766, 515, 0)
8x 01 65                  | X | Preset(six: 32641, 1794, 0)
8x 01 66                  | X | Preset(seven: 741, 336, 0)
8x 01 67                  | X | Preset(eight: 22529, 17409, 0)
8x 01 71                  |   | > Corresponding setter fails
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
8x 03 00                  | X | IrisLevel(255)
8x 03 02                  | X | Zoom(64)
8x 03 03                  | X | Focus(133)
8x 03 04                  | X | Pan(238)
8x 03 05                  | X | Tilt(250)
8x 03 26                  |   | > Corresponding setter fails
8x 03 3D                  | X | Sharpness(6)
8x 03 3E                  | X | Saturation(6)
8x 03 3F                  |   | Unknown(83 43 3F 5A)
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
8x 43 3F 5A               |   | Executed
8x 43 3F 64               |   | Executed
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
8x 45 0A (00 -> 01)       | X | Executed: Move focus near
8x 45 0A 03               | X | Executed: Move focus near
8x 45 0B                  | X | Executed: Move focus stop
8x 45 0C (00 -> 03)       | X | Executed: Move zoom+
8x 45 0D (00 -> 03)       | X | Executed: Move zoom-
8x 45 0E                  | X | Executed: Move zoom stop
8x 45 17                  | X | Not executed: Mode condition: Start manual white balance calibration
8x 45 32 00               | X | Executed: Resetting sensor and motors
8x 45 33                  |   | Not executed: Mode condition
8x 45 33 00               |   | Not executed: Mode condition
8x 45 70                  |   | Not executed: Mode condition
8x 45 70 (00 -> 3D)       |   | Not executed: Mode condition
8x 45 71                  |   | Not executed: Mode condition // after try to set all states to all their possible values, haven't seen a way to run this action


Stats
-----
Duration: 314 seconds
First column width: 25 chars
