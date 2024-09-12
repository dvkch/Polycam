Running all possible commands from 00 00 to 0A 7F, then from 40 00 to 4A 7F, with one argument in (none, 00, 01), all replies are filtered to ignore : Fail, Reset, Command not defined, Syntax error.

Here are the detected commands, a cross next to it confirms we know it and implement it.

### Getters

- 82 01 01 | 83 41 01 00                                      |
- 82 01 02 | 83 41 02 01                                      |
- 82 01 0B | 83 41 0B 00                                      |
- 82 01 10 | 83 41 10 00                                      | MireMode(off)
- 82 01 13 | 83 41 13 1A                                      | VideoOutputMode(1080p)
- 82 01 14 | 83 41 14 00                                      | -> Corresponding setter fails
- 82 01 21 | 84 41 21 02 10                                   | LedMode(blue, on)
- 82 01 23 | 83 41 23 00                                      |
- 82 01 24 | 83 41 24 01                                      |
- 82 01 25 | 85 41 25 08 08 08                                | Volume(8)
- 82 01 31 | 83 41 31 05                                      | GainMode(5)
- 82 01 32 | 84 41 32 01 00                                   |
- 82 01 33 | 84 41 33 01 00                                   | Brightness(11)
- 82 01 34 | 83 41 34 01                                      |
- 82 01 3B | 83 41 3B 01                                      |
- 82 01 3C | 83 41 3C 01                                      |
- 82 01 3D | 83 41 3D 01                                      |
- 82 01 3E | 83 41 3E 00                                      | InvertedMode(off)
- 82 01 44 | 8F 0F 41 44 7A 00 71 05 71 71 71 4C 05 0C 06 71  | > Randomness?
- 82 01 50 | 8A 41 50 0A 03 68 00 7A 04 7A 00                 | Position(0, 0, 0)
- 82 01 5D | 8D 41 5D 02 00 07 2F 32 00 00 00 00 00 00        | Clock1(t=...)
- 82 01 5E | 8D 41 5E 02 00 07 26 0D 00 00 00 00 00 00        | Clock2(t=...)
- 82 01 60 | 8A 41 60 00 00 00 00 00 00 00 00                 | > Preset?
- 82 01 61 | 8A 41 61 00 00 00 00 00 00 00 00                 | > Preset? 
- 82 01 62 | 8A 41 62 00 00 00 00 00 00 00 00                 | > Preset?
- 82 01 63 | 8A 41 63 00 03 02 78 00 00 00 00                 | > Preset?
- 82 01 64 | 8A 41 64 02 02 7E 02 03 00 00 00                 | > Preset?
- 82 01 65 | 8A 41 65 02 7F 01 07 02 00 00 00                 | > Preset?
- 82 01 66 | 8A 41 66 03 02 65 01 50 00 00 00                 | > Preset?
- 82 01 67 | 8A 41 67 01 58 01 44 01 00 00 00                 | > Preset?
- 82 01 71 | 83 41 71 00                                      | > Corresponding setter fails
- 82 01 72 | 83 41 72 00                                      | 
- 82 02 09 | 83 42 09 01                                      | AutoFocus(false)
- 82 02 11 | 83 42 11 01                                      | AutoExposure(true)
- 82 02 12 | 83 42 12 01                                      | WhiteBalance(auto)
- 82 02 14 | 83 42 14 00                                      | ShutterSpeed(auto)
- 82 02 15 | 83 42 15 00                                      | BacklightCompensation(false)
- 82 02 22 | 83 42 22 01                                      |
- 82 03 00 | 84 43 00 01 58                                   | IrisLevel(216)
- 82 03 02 | 84 43 02 08 7A                                   | 
- 82 03 03 | 84 43 03 06 00                                   | 
- 82 03 04 | 84 43 04 07 68                                   | 
- 82 03 05 | 84 43 05 01 7A                                   | 
- 82 03 26 | 83 43 26 14                                      | > Corresponding setter fails
- 82 03 3D | 84 43 3D 01 00                                   | Sharpness(6)
- 82 03 3E | 84 43 3E 01 00                                   | Saturation(6)
- 82 03 3F | 83 43 3F 5A                                      |
- 82 03 40 | 84 43 40 01 00                                   |
- 82 03 41 | 84 43 41 01 00                                   |
- 82 03 42 | 84 43 42 01 02                                   | RedGain(35)
- 82 03 43 | 84 43 43 01 02                                   | BlueGain(35)
- 82 03 50 | 84 43 50 01 00                                   |
- 82 03 51 | 84 43 51 01 00                                   |
- 82 03 52 | 84 43 52 01 00                                   |
- 82 03 53 | 84 43 53 01 00                                   |
- 82 03 54 | 84 43 54 01 00                                   |
- 82 03 55 | 84 43 55 01 00                                   |
- 82 03 56 | 84 43 56 01 00                                   |
- 82 03 57 | 84 43 57 01 00                                   |
- 82 03 58 | 84 43 58 01 00                                   |
- 82 03 59 | 84 43 59 01 00                                   |
- 82 03 5A | 84 43 5A 01 00                                   |
- 82 03 5B | 84 43 5B 01 00                                   |
- 82 03 5C | 84 43 5C 01 00                                   |
- 82 03 5D | 84 43 5D 01 00                                   |
- 82 03 5E | 84 43 5E 01 00                                   |
- 82 03 5F | 84 43 5F 01 00                                   |
- 82 03 60 | 84 43 60 01 00                                   |
- 82 03 61 | 84 43 61 01 00                                   |
- 82 06 77 | 8F 30 46 77 05 xx...                             | MPTZ 11 Hello 

### Setters with no corresponding detected getter

- 83 41 70 00 | Accepts any integer arg, tested from 0x00 to 0x01 0x15, including no arg

### Actions, not already implemented

- 82 45 71 | mode condition. after try to set all states to all their possible values, haven't seen a way to run this action

### Unknowns

- 83 04 xx | Not executed: Syntax error
- 83 44 xx | Not executed: Syntax error
