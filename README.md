USBPacketDetector
==
### University project for Digital Digital circuits and embedded systems 2 class

Repository consists of VHDL source files and user constraint files needed to program FPGA (in this case, Spartan-3E Starter Kit) with JTAG interface.
Xylinx ISE was used to perform behavioral simulation.

Module is capable of working with USB on full-speed mode whose transmission rate is **12MBit/s**.
Component samples input with 60MHz. Spartan Board offers clock with frequency of 50MHz. To generate proper clock input for USBPacketDetector, built-in DCM primitives offered by Xylinx ISE could be used.

Component can be used as a tool for analyzing incoming USB packets as it's capable of decoding them and slicing into single bytes that can be used further, e.g. put as ASCII characters to VGA screen (it was used this way during the class).
USBPacketDetector functions:
- detecting the sync pattern, which is the beginning of every USB transmission
- decoding the NRZI
- putting out single bytes to the *data_ready* bus and signalizing it with single-tick *data_out* port
- detecting the EOP, which is SE0 signal twice in a row followed by high D+ and signalizing it on *eop_detected* port

Documentation used during the development: [USB Specification Rev. 2.0](http://sdphca.ucsd.edu/lab_equip_manuals/usb_20.pdf)
