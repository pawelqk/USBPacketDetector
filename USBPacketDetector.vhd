library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity USBPacketDetector is
    Port ( usb_in : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           reset: in STD_LOGIC;
           o_state: out std_logic_vector(2 downto 0);
           data_out: out STD_LOGIC_VECTOR(7 downto 0);
           detected : out  STD_LOGIC);
end USBPacketDetector;

architecture Behavioral of USBPacketDetector is
   type state_type is (st1_idle, st2_read, st3_check, st4_accept, st5_show); 
   signal state, next_state : state_type; 
   signal output_signal : std_logic;
   signal i_state: std_logic_vector(2 downto 0) := "001";

   signal counter_reset: std_logic;
   signal counter_mod_5: natural range 0 to 4;
   signal counter_mod_9: natural range 0 to 8;
   signal shift_reg: std_logic_vector(7 downto 0);

   signal received_byte: std_logic_vector(7 downto 0);   -- container shift register for first received byte (least significant bit first)
   signal output_byte: std_logic_vector(7 downto 0);
   signal decoded_bit: std_logic;
   signal previous_bit: std_logic;

begin
   SYNC_PROC: process (CLK)
   begin
      if rising_edge(CLK) then
         if reset = '1' then
            state <= st1_idle;
         else
            state <= next_state;
         end if;
      end if;
   end process;
   
   detected <= output_signal;
   decoded_bit <= previous_bit xnor usb_in;
   data_out <= output_byte;
   o_state <= i_state;
   
   SHOW_BYTE: process (state, received_byte)
   begin
      if state = st5_show then
         output_byte <= received_byte;
      else
         output_byte <= X"00";
      end if;
   end process;
 
   OUTPUT_DECODE: process (state)
   begin
      if state = st4_accept then 
         output_signal <= '1';
      else
         output_signal <= '0';
      end if;
   end process;
   
   COUNTER_STATE: process (state)
   begin
      if state = st2_read or state = st4_accept then
         counter_reset <= '0';
      else
         counter_reset <= '1';
     end if;
   end process;
 
   NEXT_STATE_DECODE: process (state, usb_in, counter_mod_9, shift_reg)
   begin
      next_state <= state;
      case (state) is
         when st1_idle =>
            i_state <= "001";
            if usb_in = '0' then
               next_state <= st2_read;
            end if;
         when st2_read =>
            i_state <= "010";
            if counter_mod_9 = 8 then
               next_state <= st3_check;
            end if;
         when st3_check =>
            i_state <= "011";
            if shift_reg = "01010100" then
               next_state <= st4_accept;
            else
               next_state <= st1_idle;
            end if;
         when st4_accept =>
            i_state <= "100";
            if counter_mod_9 = 8 then
               next_state <= st5_show;
            end if;
         when st5_show =>
            i_state <= "101";
         when others =>
            i_state <= "000";
            next_state <= st1_idle;
      end case;      
   end process;

-- LICZNIK MODULO 5

   process (CLK)
   begin
      if rising_edge(CLK) then
         if counter_reset='1' then
            counter_mod_5 <= 0;
         else
            if counter_mod_5=4 then
               counter_mod_5 <= 0;
            else
               counter_mod_5 <= counter_mod_5 + 1;
            end if;
         end if;
      end if;
   end process;


-- LICZNIK MODULO 9 

   process (CLK, counter_mod_5) 
   begin
      if rising_edge(CLK) then
         if counter_reset='1' then
            counter_mod_9 <= 0;
         elsif counter_mod_5=1 then
            if counter_mod_9=8 then
               counter_mod_9 <= 0;
            else
               counter_mod_9 <= counter_mod_9 + 1;
            end if;
         end if;
      end if;
   end process;

-- REJESTR PRZESUWNY

   process(CLK, counter_mod_5)
   begin
      if rising_edge(CLK) and counter_mod_5=1 then
         shift_reg( 7 downto 0 ) <= shift_reg( 6 downto 0 ) & usb_in;
      end if;
   end process;
   
-- BIT DECODER
   process(CLK, usb_in)
   begin
      if rising_edge(CLK) and counter_mod_5=1 then
         previous_bit <= usb_in;
      end if;
   end process;

-- BYTE RECORDER
   process(CLK, counter_mod_5, decoded_bit)
   begin
      if rising_edge(CLK) and counter_mod_5=1 and state = st4_accept then
         for i in 6 downto 0 loop  
            received_byte(i) <= received_byte(i+1);
         end loop; 
         received_byte(7) <= decoded_bit;
         --received_byte( 0 downto 7 ) <= decoded_bit & received_byte( 0 downto 6 );
      end if;
   end process;

end Behavioral;

