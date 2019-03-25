-- Vhdl test bench created from schematic /home/ise/VM_SHARED/USB_UCISW/scheme.sch - Sun Mar 24 21:12:07 2019
--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Xilinx recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "Source->Add"
-- menu in Project Navigator to import the testbench. Then
-- edit the user defined section below, adding code to generate the 
-- stimulus for your design.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;
ENTITY scheme_scheme_sch_tb IS
END scheme_scheme_sch_tb;
ARCHITECTURE behavioral OF scheme_scheme_sch_tb IS 

   COMPONENT scheme
   PORT( CLK_IN	:	IN	STD_LOGIC;
          rst : IN STD_LOGIC;
          Clk_60MHz	:	OUT	STD_LOGIC; 
          detected	:	OUT	STD_LOGIC; 
          o_state: OUT STD_LOGIC_VECTOR(2 downto 0);
          usb_in	:	IN	STD_LOGIC);
   END COMPONENT;

   SIGNAL CLK_IN	:	STD_LOGIC := '0';
   SIGNAL Clk_60MHz	:	STD_LOGIC;
   SIGNAL detected	:	STD_LOGIC;
   SIGNAL usb_in	:	STD_LOGIC;
   SIGNAL o_state : STD_LOGIC_VECTOR(2 downto 0);
	signal rst : STD_LOGIC := '0';

BEGIN

   UUT: scheme PORT MAP(
		CLK_IN => CLK_IN,
      rst => rst,
		Clk_60MHz => Clk_60MHz, 
		detected => detected, 
		usb_in => usb_in,
      o_state => o_state
   );

   CLK_IN <= not CLK_IN after 10 ns; -- after 1 us / 120
-- *** Test Bench - User Defined Section ***
   tb : PROCESS
      constant test_bits : std_logic_vector (0 to 39) := B"1111_01010111_1111_01010100_0101010001010101";
   BEGIN
		for i in test_bits'range loop
			usb_in <= test_bits(i);
         wait for 1 us / 12;
--			wait until rising_edge(Clk_60MHz);
--			wait until rising_edge(Clk_60MHz);
--			wait until rising_edge(Clk_60MHz);
--			wait until rising_edge(Clk_60MHz);
--			wait until rising_edge(Clk_60MHz);
		end loop;
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
