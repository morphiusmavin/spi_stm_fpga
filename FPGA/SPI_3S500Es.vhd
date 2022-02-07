-- test_uart.vhd - copied from X3S500E1.vhd with just the uart stuff
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

library XESS;
use XESS.CommonPckg.all;

entity X3S500E is
	port(
		clk, reset: in std_logic;
-- signals for master
		MOSI_i : in std_logic;
		MISO_o : out std_logic;
		SCLK_i : in std_logic;
--		SS_o : out std_logic_vector(1 downto 0);
		TRIGGER : out std_logic;
		SS_i : in std_logic;
-- signals for slave
--		MOSI_i : in std_logic;
--		MISO_o : out std_logic;
--		SCLK_i : in std_logic;
--		SS_i : in std_logic;
		tx_uart: out std_logic;
		led1: out std_logic_vector(3 downto 0)
		);
end X3S500E;

architecture truck_arch of X3S500E is

	type state_dout is (idle_dout, start_dout, done_dout, wait_dout);
	signal state_dout_reg, state_dout_next: state_dout;

--	signal time_delay_reg, time_delay_next: unsigned(23 downto 0);
	signal time_delay_reg1, time_delay_next1: unsigned(23 downto 0);

	type state_uart1 is (idle10, idle11, start2, done);
	signal state_tx1_reg, state_tx1_next: state_uart1;

	signal start_tx, done_tx: std_logic;
	signal data_tx: std_logic_vector(7 downto 0);

--	signal skip : std_logic;

	signal mspi_ready : std_logic;
	signal mspi_din_vld, mspi_dout_vld : std_logic;
	signal mosi, miso, sclk, ss: std_logic;
	signal mspi_din, mspi_dout : std_logic_vector(7 downto 0);
--	signal stlv_temp1 : std_logic_vector(7 downto 0);
	signal stlv_temp1a : std_logic_vector(7 downto 0);
--	signal addr: std_logic_vector(1 downto 0);
--	signal addr: std_logic;
--	signal sample: signed(7 downto 0);
--	signal sample2: signed(7 downto 0);
	signal echo_data: std_logic_vector(7 downto 0);
	signal send_flag: std_logic;
	signal my_reset: std_logic;

begin

my_reset <= not reset;

tx_uart_wrapper_unit: entity work.uartLED(str_arch)
	generic map(DVSR_M=>DVSR_MU_19200)
	port map(clk=>clk, reset=>reset,
	tx_start=>start_tx,
	w_data=>data_tx,
	done_tick=>done_tx,
	tx=>tx_uart);

spi_slave_unit1: entity work. SPI_SLAVE(RTL)
	port map(CLK=>clk, RST=>my_reset,
	SCLK=>SCLK_i,
	CS_N=>SS_i,
	MOSI=>MOSI_i,
	MISO=>MISO_o,
	READY=>mspi_ready,
	DIN=>mspi_din,
	DIN_VLD=>mspi_din_vld,
	DOUT=>mspi_dout,
	DOUT_VLD=>mspi_dout_vld);

-- ********************************************************************************

echo_dout_unit1: process(clk, reset, state_dout_reg)
begin
	if reset = '0' then
		state_dout_reg <= idle_dout;
		echo_data <= (others=>'0');
		mspi_din_vld <= '0';
		mspi_din <= (others=>'0');
		led1 <= "1111";

	else if clk'event and clk = '1' then
		case state_dout_reg is
			when idle_dout =>
				TRIGGER <= '1';
				mspi_din_vld <= '1';
				led1 <= "0111";
				if mspi_ready = '1' then
					state_dout_next <= start_dout;
				end if;
			when start_dout =>
				led1 <= "1011";
				state_dout_next <= done_dout;
			when done_dout =>
				if mspi_dout_vld = '1' then
					echo_data <= mspi_dout;  -- mspi_dout is what gets received by MISO
					led1 <= conv_std_logic_vector(conv_integer(echo_data),4);
					stlv_temp1a <= echo_data;
					state_dout_next <= wait_dout;
				end if;
			when wait_dout =>
				TRIGGER <= '0';
				mspi_din <= echo_data;		-- write
				mspi_din_vld <= '0';
				state_dout_next <= idle_dout;
		end case;
		state_dout_reg <= state_dout_next;
		end if;
	end if;
end process;	

--echo_dout_unit1: process(clk, reset, state_dout_reg)
--begin
--	if reset = '0' then
--		state_dout_reg <= idle_dout;
--		stlv_temp1 <= (others=>'0');
--		stlv_temp1a <= (others=>'0');
--		led1 <= (others=>'1');
--		mspi_din_vld <= '0';
--		mspi_din <= (others=>'0');
--		skip <= '0';
--		time_delay_reg <= (others=>'0');
--		time_delay_next <= (others=>'0');
--		sample <= (others=>'0');
----		sample <= X"A9";
--		send_flag <= '0';
--		led1 <= "0000";
--		TRIGGER <= '0';
--		addr <= '0';
--		
--	else if clk'event and clk = '1' then
--		case state_dout_reg is
--			when idle_dout =>
--				if mspi_ready = '1' then
--					TRIGGER <= '1';
--					mspi_din <= conv_std_logic_vector(conv_integer(sample),8);  -- write
--					led1 <= conv_std_logic_vector(conv_integer(sample),4);
--					skip <= not skip;
--					if skip = '1' then
--						if sample > 126 then
--							sample <= X"21";
--						else	
--							sample <= sample + 1;
--						end if;
--						sample <= sample + 1;
--					end if;
--					mspi_din_vld <= '1';
--					state_dout_next <= start_dout;
--				end if;
--			when start_dout =>
--				mspi_din_vld <= '0';			
--				if mspi_dout_vld = '1' then
--					TRIGGER <= '0';
---- mspi_dout is what gets received by MISO
--					stlv_temp1a <= mspi_dout;
--					state_dout_next <= time_delay_dout;
--					send_flag <= '1';
--				end if;
--			when time_delay_dout =>
--				send_flag <= '0';
--				if time_delay_reg > TIME_DELAY9/6 then	-- about 350us
----				if time_delay_reg > TIME_DELAY8 then	-- about 20ms
----				if time_delay_reg > TIME_DELAY8c then	-- about 10ms
--					time_delay_next <= (others=>'0');
--					state_dout_next <= done_dout;
--				else
--					time_delay_next <= time_delay_reg + 1;
--				end if;	
--			when done_dout =>
--				state_dout_next <= idle_dout;
--		end case;
--		state_dout_reg <= state_dout_next;
--		time_delay_reg <= time_delay_next;
--		end if;
--	end if;
--
--end process;	

send_uart1: process(clk, reset, state_tx1_reg)
variable temp_uart: integer range 0 to 255:= 33;
begin
	if reset = '0' then
		state_tx1_reg <= idle10;
		data_tx <= (others=>'0');
		start_tx <= '0';
		time_delay_reg1 <= (others=>'0');
		time_delay_next1 <= (others=>'0');
--		sample2 <= X"21";

	else if clk'event and clk = '1' then
		case state_tx1_reg is

			when idle10 =>
				start_tx <= '0';
--				start_keyscan <= '1';
				state_tx1_next <= idle11;

			when idle11 =>	
--				if time_delay_reg1 > TIME_DELAY8 then
				if time_delay_reg1 > TIME_DELAY9 then	-- about 2.5ms
					time_delay_next1 <= (others=>'0');
--					state_tx1_next <= idle1;
					state_tx1_next <= start2;
				else
					time_delay_next1 <= time_delay_reg1 + 1;
				end if;
				
			when start2 =>
				-- if sample2 > 126 then
					-- sample2 <= X"21";
				-- else	
					-- sample2 <= sample2 + 1;
				-- end if;
				if send_flag = '1' then
					data_tx <= conv_std_logic_vector(conv_integer(stlv_temp1a),8);
					start_tx <= '1';
					state_tx1_next <= done;
				end if;

			when done =>
				start_tx <= '0';
				if done_tx = '1' then
					start_tx <= '1';
					state_tx1_next <= idle10;
				end if;

		end case;
		time_delay_reg1 <= time_delay_next1;
		state_tx1_reg <= state_tx1_next;
		end if;
	end if;
end process;

end truck_arch;