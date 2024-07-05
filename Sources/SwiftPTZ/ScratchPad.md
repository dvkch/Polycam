------------------------------------------------------

12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: rx: read response 49 bytes: 8f 30 46 77 06 30 31 30 30 30 30 35 37 30 31 30 31 30 30 35 32 30 31 30 30 30 30 32 31 30 31 30 30 30 30 30 36 32 39 35 30 30 31 30 31 30 30 34 38
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: MPTZ_11
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: sysver = "01000057", camver = "01010052"
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: lensver = "", promver = ""
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: backver = "01000021", bootver = "01000006"
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: splver = "2950", pkgver = "01010048"
12:35:28.339 INFO     SMan: hd[0]: SrcMan: DiscoverCamera: Detected MPTZ_11 @ -1248683884, Port 1

------------------------------------------------------

//17:28:11.039 DEBUG    SMan: hd[0]: CameraBase: In: Command: 3e8 fa 8b5 1f8
//17:28:11.039 INFO     SMan: hd[0]: CameraJCCP: Send 14 bytes: 8d 41 51 24 0 3 68 0 0 7a 3 2 8 35

------------------------------------------------------

// 82 4c 19

/*
2:17.581 INFO     PCon: hd[0]: PcThreads: PC_ProcessMsg: component_id: "cam1" serial_properties { baud_rate: 9600 parity: PARITY_NONE data_bits: 8 stop_bits: 1 }
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Enter PC_SerialPropertiesCB for serial port on cam1
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Set baud rate to 9600
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Set parity to 3
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Set data bits to 8
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Set stop bits to 1
12:22:17.581 INFO     SMan: hd[0]: CameraVisca: DiscoverCamera()
12:22:17.581 DEBUG    SMan: hd[0]: CameraBase: Send 5 bytes: 81 9 0 2 ff
12:22:17.582 DEBUG    SMan: hd[0]: CameraBase: SM: WaitForNewCmdMsg: got message...
12:22:17.582 DEBUG    SMan: hd[0]: CameraBase: In: Command:
12:22:17.582 DEBUG    SMan: hd[0]: CameraBase: Have generic command
12:22:17.582 INFO     SMan: hd[0]: SrcMan: 81 09 00 02 FF
*/

/*

01 50 => Get position
06 77 => Hello
41 00 => Set standby
41 13 => Set video output
41 21 => Set LED
41 25 => Set mute
41 33 => Set brightness
41 3E => Set invert mode
41 51 => Move to precise position
42 12 => Set white balance
42 14 => Set shutter speed
42 15 => Set backlight compensation
43 3E => Set saturation
43 42 => Set R gain
43 43 => Set B gain
45 17 => Start white balance calibration
45 xx => Move continuously in/Stop for direction xx

*/
