Repository consists of VHDL source files and user constraint files needed to program FPGA (in this case, Spartan-3E Starter Kit) with JTAG interface.
Xylinx ISE was used to perform behavioral simulation.

Module is capable of working with USB on full-speed mode whose transmission rate is **12MBit/s**.
Component samples input with 60MHz. Spartan Board offers clock with frequency of 50MHz. To generate proper clock input for USBPacketDetector, built-in DCM primitives offered by Xylinx ISE could be used.

Component detects USB packet if proper sync pattern was detected. According to [USB Specification Rev 2.0](http://sdphca.ucsd.edu/lab_equip_manuals/usb_20.pdf) sync pattern for full-speed mode is *KJKJKJKK*. Currently, component takes D+ signal as its input where K is low, meaning that it accepts the sequence of *01010100*. After proper detection it sets output to high and freezes its state. The state can be cleared using reset input (high means reset is active).

