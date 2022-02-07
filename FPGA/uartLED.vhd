--
-- uartLED.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity uartLED is
   generic(
     -- Default setting:
     -- 19,200 baud, 8 data bis, 1 stop its, 2^2 FIFO
     DBIT: integer:=8;     -- # data bits
      SB_TICK: integer:=16; -- # ticks for stop bits, 16/24/32
                            --   for 1/1.5/2 stop bits
--      DVSR: integer:= 163;  -- baud rate divisor
--		DVSR: integer:= 27; -- 115200 baud
		DVSR_M: integer:= 326; -- 9600 baud
                            -- DVSR = 50M/(16*baud rate)
      DVSR_BIT: integer:=9 -- # bits of DVSR
   );
   port(
      clk, reset: in std_logic;
	  tx_start: in std_logic;
      w_data: in std_logic_vector(7 downto 0);
	  done_tick: out std_logic;
      tx: out std_logic);
end uartLED;

architecture str_arch of uartLED is
	signal tick: std_logic;
	signal tx_done_tick: std_logic;
begin
   baud_gen_unit: entity work.mod_m_counter(arch)
      generic map(M=>DVSR_M, N=>DVSR_BIT)
      port map(clk=>clk, reset=>reset,
		max_tick=>tick);
			   
   uart_tx_unit: entity work.uart_tx(arch)
      generic map(DBIT=>DBIT, SB_TICK=>SB_TICK)
      port map(clk=>clk, reset=>reset,
		tx_start=>tx_start,
		s_tick=>tick,
		din => w_data,
		tx_done_tick=> tx_done_tick, 
		tx=>tx);
done_tick <= tx_done_tick;	
end str_arch;
