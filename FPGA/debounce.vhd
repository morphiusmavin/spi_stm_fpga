-- Listing 5.6
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity db_fsm is
port(
	clk, reset: in std_logic;
	sw: in std_logic;
	db: out std_logic
);
end db_fsm;

architecture arch of db_fsm is
	constant N: integer:=10;
	signal q_reg, q_next: unsigned(N-1 downto 0);
	signal m_tick: std_logic;
	type eg_state_type is (zero,wait1_1,wait1_2,wait1_3,
		  one,wait0_1,wait0_2,wait0_3);
	signal state_reg, state_next: eg_state_type;
	signal temp1: std_logic_vector(3 downto 0);
--	signal Period: STD_LOGIC;

begin
--===================================
-- counter to generate 10 ms tick
-- (2^19 * 20ns)
--===================================
clk_proc: process( reset, clk, temp1)
begin 
	------------------------------------
	--Period: 1uS (Period <= clk; )
	if reset = '0' then
		q_reg <= (others=>'0');
		temp1 <= (others=>'0');
--		Period <= '0';
	elsif  clk'event and clk='1'  then
		temp1 <= std_logic_vector(q_reg(N-1 downto N-4));
		if temp1 = "1000" then
			q_reg <= (others=>'0');
		else
			q_reg <= q_next;
		end if;
	end if;
--	Period <= temp1(3);
end process;

q_next <= q_reg + 1;

--output tick
m_tick <= '1' when q_reg=0 else
'0';
--===================================
-- debouncing FSM
--===================================
-- state register
process(clk,reset)
begin
	if (reset='0') then
	state_reg <= zero;
	elsif (clk'event and clk='1') then
	state_reg <= state_next;
	end if;
end process;

-- next-state/output logic
process(state_reg,sw,m_tick)
begin
	state_next <= state_reg; --default: back to same state
	db <= '0';   -- default 0
	case state_reg is
		when zero =>
			if sw='1' then
				state_next <= wait1_1;
			end if;
		when wait1_1 =>
			if sw='0' then
				state_next <= zero;
			else
				if m_tick='1' then
					state_next <= wait1_2;
				end if;
			end if;
		when wait1_2 =>
			if sw='0' then
				state_next <= zero;
			else
				if m_tick='1' then
					state_next <= wait1_3;
				end if;
			end if;
		when wait1_3 =>
			if sw='0' then
				state_next <= zero;
			else
				if m_tick='1' then
					state_next <= one;
				end if;
			end if;
		when one =>
			db <='1';
			if sw='0' then
				state_next <= wait0_1;
			end if;
		when wait0_1 =>
			db <='1';
			if sw='1' then
				state_next <= one;
			else
				if m_tick='1' then
					state_next <= wait0_2;
				end if;
			end if;
		when wait0_2 =>
			db <='1';
			if sw='1' then
				state_next <= one;
			else
				if m_tick='1' then
					state_next <= wait0_3;
				end if;
			end if;
		when wait0_3 =>
			db <='1';
			if sw='1' then
				state_next <= one;
			else
				if m_tick='1' then
					state_next <= zero;
				end if;
			end if;
	end case;
end process;
end arch;
