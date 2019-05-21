library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity USBPacketDetector is
    Port ( data_plus : in  STD_LOGIC;
           data_minus: in STD_LOGIC;
           CLK : in  STD_LOGIC;
           reset: in STD_LOGIC;
           data_out: out STD_LOGIC_VECTOR(7 downto 0);
           data_ready: out STD_LOGIC;
           eop_detected : out  STD_LOGIC);
end USBPacketDetector;

architecture Behavioral of USBPacketDetector is
   type state_type is (st1_idle, st2_read, st3_check, st4_accept, st5_show, st6_eop); 
   signal state, next_state : state_type;

   signal counter_reset: std_logic; -- flag for resetting counters
   signal counter_mod_5: natural range 0 to 4;
   signal counter_mod_9: natural range 0 to 8;
   signal shift_reg: std_logic_vector(7 downto 0); -- register for detecting sync pattern

   signal received_byte: std_logic_vector(7 downto 0);   -- container shift register for received byte (least significant bit first)
   signal output_byte: std_logic_vector(7 downto 0);     -- byte on output when data_ready = '1'
   signal decoded_bit: std_logic;   -- decoded nrzi bit
   signal previous_bit: std_logic;  -- previous bit for nrzi decoding
   signal in_data_ready: std_logic; -- signals when byte is ready
   signal se0_twice: std_logic;     -- flag for se0 twice in a row
   signal se0: std_logic;           -- flag for se0 (data_plus = data_minus = '0') detected
   signal counter_ones: natural range 0 to 6; -- counter for nrzi ones
   signal detected_eop: std_logic;            -- signals eop (when se0_twice and data_plus = '1')

begin
   data_ready <= in_data_ready;
   decoded_bit <= previous_bit xnor data_plus;
   data_out <= output_byte;

   -- resetting machine
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

   -- showing byte on output when it's ready
   SHOW_BYTE: process (state, received_byte)
   begin
      if state = st5_show then
         output_byte <= received_byte;
         in_data_ready <= '1';
      else
         output_byte <= X"00";
         in_data_ready <= '0';
      end if;
   end process;
   
   -- counting only when it's needed
   -- during sync pattern accepting and byte reading
   COUNTER_STATE: process (state)
   begin
      if state = st2_read or state = st4_accept then
         counter_reset <= '0';
      else
         counter_reset <= '1';
     end if;
   end process;
   
   -- signaling end of packet
   NEWLINE: process (state)
   begin
      if state = st6_eop then 
         eop_detected <= '1';
      else
         eop_detected <= '0';
      end if;
   end process;

   -- fsm process
   NEXT_STATE_DECODE: process (state, data_plus, counter_mod_9, shift_reg, detected_eop)
   begin
      next_state <= state;
      case (state) is
         when st1_idle =>
            if data_plus = '0' then
               next_state <= st2_read;
            end if;
         when st2_read =>
            if counter_mod_9 = 8 then
               next_state <= st3_check;
            end if;
         when st3_check =>
            if shift_reg = "01010100" then
               next_state <= st4_accept;
            else
               next_state <= st1_idle;
            end if;
         when st4_accept =>
            if detected_eop = '1' then
               next_state <= st6_eop;
            elsif counter_mod_9 = 8 then
               next_state <= st5_show;
            end if;
         when st5_show =>
            next_state <= st4_accept;
         when st6_eop =>
            next_state <= st1_idle;  
         when others =>
            next_state <= st1_idle;
      end case;      
   end process;

   -- counter modulo 5
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

   -- counter modulo 9
   process (CLK, counter_mod_5, decoded_bit, counter_ones) 
   begin
      if rising_edge(CLK) then
         if counter_reset='1' then
            counter_mod_9 <= 0;
         elsif counter_mod_5=1 and not (decoded_bit = '0' and counter_ones = 6) then
            if counter_mod_9=8 then
               counter_mod_9 <= 0;
            else
               counter_mod_9 <= counter_mod_9 + 1;
            end if;
         end if;
      end if;
   end process;

   -- 8-bit shift register used during detecting sync pattern
   process(CLK, counter_mod_5)
   begin
      if rising_edge(CLK) and counter_mod_5=1 then
         shift_reg( 7 downto 0 ) <= shift_reg( 6 downto 0 ) & data_plus;
      end if;
   end process;
   
   -- remembering previous state on data_plus
   -- for further nrzi decoding
   process(CLK, data_plus)
   begin
      if rising_edge(CLK) and counter_mod_5=1 then
         previous_bit <= data_plus;
      end if;
   end process;
 
   -- detecting se0 state
   process(CLK, data_plus, data_minus, counter_mod_5)
   begin
      if rising_edge(CLK) and counter_mod_5=1 then
         if (data_plus = '0') and (data_minus = '0') then
            se0 <= '1';
         else
            se0 <= '0';
         end if;
      end if;
   end process;
 
   -- detecting 2x se0 in a row
   process(CLK, se0, counter_mod_5)
   begin
      if rising_edge(CLK) and counter_mod_5=1 then
         if (data_plus = '0') and (data_minus = '0') and (se0 = '1') then
            se0_twice <= '1';
         else
            se0_twice <= '0';
         end if;
      end if;
   end process;

   -- detecting end of packet
   process(CLK, se0, counter_mod_5)
   begin
      if rising_edge(CLK) and counter_mod_5=1 then
         if (data_plus = '1') and (data_minus = '0') and (se0_twice = '1') then
            detected_eop <= '1';
         else
            detected_eop <= '0';
         end if;
      end if;
   end process;

   -- remembering the byte in 8-bit shift register
   -- bit unstuffing is performed
   -- zero after six consecutive ones is ignored
   process(CLK, counter_mod_5, decoded_bit, counter_ones, counter_mod_9)
   begin
      if rising_edge(CLK) and counter_mod_5=1 and state = st4_accept then
         if decoded_bit = '0' and counter_ones = 6 then
            counter_ones <= 0;
         else
            if decoded_bit = '1' then
               counter_ones <= counter_ones + 1;
            elsif decoded_bit = '0' then
               counter_ones <= 0;
            end if;
            for i in 6 downto 0 loop  
               received_byte(i) <= received_byte(i+1);
            end loop;            
            received_byte(7) <= decoded_bit;
         end if;
      end if;
   end process;

end Behavioral;

