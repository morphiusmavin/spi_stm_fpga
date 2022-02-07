--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:42:15 02/05/2022
-- Design Name:   
-- Module Name:   C:/Users/Daniel/dev/Xilinx/spi_test/tb.vhd
-- Project Name:  SPI_3S500E
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: X3S500E
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb IS
END tb;
 
ARCHITECTURE behavior OF tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT X3S500E
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         MOSI_o : OUT  std_logic;
         MISO_i : IN  std_logic;
         SCLK_o : OUT  std_logic;
         TRIGGER : OUT  std_logic;
         tx_uart : OUT  std_logic;
         led1 : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal MISO_i : std_logic := '0';

 	--Outputs
   signal MOSI_o : std_logic;
   signal SCLK_o : std_logic;
   signal TRIGGER : std_logic;
   signal tx_uart : std_logic;
   signal led1 : std_logic_vector(3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: X3S500E PORT MAP (
          clk => clk,
          reset => reset,
          MOSI_o => MOSI_o,
          MISO_i => MISO_i,
          SCLK_o => SCLK_o,
          TRIGGER => TRIGGER,
          tx_uart => tx_uart,
          led1 => led1
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
reset_proc: process
 	begin
 		reset <= '0';
 		wait for 100 ns;
 		reset <= '1';
 		wait;
 	end process; 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
