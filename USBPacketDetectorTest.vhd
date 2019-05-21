LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;
ENTITY scheme_scheme_sch_tb IS
END scheme_scheme_sch_tb;
ARCHITECTURE behavioral OF scheme_scheme_sch_tb IS 

   COMPONENT scheme
   PORT( CLK_IN   :   IN   STD_LOGIC;
          rst : IN STD_LOGIC;
          data_plus   :   IN   STD_LOGIC;
          data_minus: IN STD_LOGIC);
   END COMPONENT;

   SIGNAL CLK_IN   :   STD_LOGIC := '0';
   SIGNAL data_plus   :   STD_LOGIC;
   signal rst : STD_LOGIC := '0';
   signal data_minus: std_logic;

BEGIN

   UUT: scheme PORT MAP(
      CLK_IN => CLK_IN,
      rst => rst,
      data_plus => data_plus,
      data_minus => data_minus
   );

   CLK_IN <= not CLK_IN after 10 ns; -- after 1 us / 120

   tb : PROCESS
      constant test_bits: std_logic_vector(0 to 16):= B"01010100_0000001_11";
   BEGIN
      wait for 230 ns;
      for i in test_bits'range loop
         data_plus <= test_bits(i);
         data_minus <= not test_bits(i);
         wait for 1 us / 12;
      end loop;
   END PROCESS;

END;
