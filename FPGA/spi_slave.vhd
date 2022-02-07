--------------------------------------------------------------------------------
-- PROJECT: SPI MASTER AND SLAVE FOR FPGA
--------------------------------------------------------------------------------
-- NAME:    SPI_SLAVE
-- AUTHORS: Jakub Cabal <jakubcabal@gmail.com>
-- LICENSE: LGPL-3.0, please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/spi-fpga
--------------------------------------------------------------------------------
-- COPYRIGHT NOTICE:
--------------------------------------------------------------------------------
-- SPI MASTER AND SLAVE FOR FPGA
-- Copyright (C) 2016 Jakub Cabal
--
-- This source file is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This source file is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- THE SPI SLAVE MODULE SUPPORT ONLY SPI MODE 0 (CPOL=0, CPHA=0)!!!

entity SPI_SLAVE is
    Port (
        CLK      : in  std_logic; -- system clock
        RST      : in  std_logic; -- high active synchronous reset
        -- SPI SLAVE INTERFACE
        SCLK     : in  std_logic;
        CS_N     : in  std_logic;
        MOSI     : in  std_logic;
        MISO     : out std_logic;
        -- USER INTERFACE
        READY    : out std_logic; -- when READY = 1, SPI slave is ready to accept input data
        DIN      : in  std_logic_vector(7 downto 0); -- input data for master
        DIN_VLD  : in  std_logic; -- when DIN_VLD = 1, input data are valid and can be accept
        DOUT     : out std_logic_vector(7 downto 0); -- output data from master
        DOUT_VLD : out std_logic  -- when DOUT_VLD = 1, output data are valid
    );
end SPI_SLAVE;

architecture RTL of SPI_SLAVE is

    signal spi_clk_reg        : std_logic;
    signal spi_clk_redge_en   : std_logic;
    signal spi_clk_fedge_en   : std_logic;
    signal load_data          : std_logic;
    signal data_shreg         : std_logic_vector(7 downto 0);
    signal bit_cnt            : unsigned(2 downto 0);
    signal last_bit_en        : std_logic;
    signal slave_ready        : std_logic;
    signal data_busy_reg      : std_logic;
    signal rx_data_vld        : std_logic;

begin

    load_data <= slave_ready and DIN_VLD;
    READY     <= slave_ready;
    DOUT      <= data_shreg;

    -- -------------------------------------------------------------------------
    --  SPI CLOCK REGISTER
    -- -------------------------------------------------------------------------

    spi_clk_reg_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '0') then
                spi_clk_reg <= '0';
            else
                spi_clk_reg <= SCLK;
            end if;
        end if;
    end process;

    -- -------------------------------------------------------------------------
    --  SPI CLOCK EDGES FLAGS
    -- -------------------------------------------------------------------------

    spi_clk_fedge_en <= not SCLK and spi_clk_reg;
    spi_clk_redge_en <= SCLK and not spi_clk_reg;

    -- -------------------------------------------------------------------------
    --  DATA BUSY REGISTER
    -- -------------------------------------------------------------------------

    data_busy_reg_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '0') then
                data_busy_reg <= '0';
            else
                if (DIN_VLD = '1' and CS_N = '1') then
                    data_busy_reg <= '1';
                elsif (rx_data_vld = '1') then
                    data_busy_reg <= '0';
                else
                    data_busy_reg <= data_busy_reg;
                end if;
            end if;
        end if;
    end process;

    slave_ready <= CS_N and not data_busy_reg;

    -- -------------------------------------------------------------------------
    --  MISO REGISTER
    -- -------------------------------------------------------------------------

    miso_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (load_data = '1') then
                MISO <= DIN(7);
            elsif (spi_clk_fedge_en = '1' and CS_N = '0') then
                MISO <= data_shreg(7);
            end if;
        end if;
    end process;

    -- -------------------------------------------------------------------------
    --  DATA SHIFT REGISTER
    -- -------------------------------------------------------------------------

    data_shreg_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (load_data = '1') then
                data_shreg <= DIN;
            elsif (spi_clk_redge_en = '1' and CS_N = '0') then
                data_shreg <= data_shreg(6 downto 0) & MOSI;
            end if;
        end if;
    end process;

    -- -------------------------------------------------------------------------
    --  DATA OUT VALID FLAG REGISTER
    -- -------------------------------------------------------------------------

    rx_data_vld <= spi_clk_fedge_en and last_bit_en;

    dout_vld_reg_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '0') then
                DOUT_VLD <= '0';
            else
                DOUT_VLD <= rx_data_vld;
            end if;
        end if;
    end process;

    -- -------------------------------------------------------------------------
    --  BIT COUNTER
    -- -------------------------------------------------------------------------

    bit_cnt_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '0') then
                bit_cnt <= (others => '0');
            elsif (spi_clk_fedge_en = '1' and CS_N = '0') then
                if (bit_cnt = "111") then
                    bit_cnt <= (others => '0');
                else
                    bit_cnt <= bit_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    -- -------------------------------------------------------------------------
    --  LAST BIT FLAG REGISTER
    -- -------------------------------------------------------------------------

    last_bit_en_p : process (CLK)
    begin
        if (rising_edge(CLK)) then
            if (RST = '0') then
                last_bit_en <= '0';
            else
                if (bit_cnt = "111") then
                    last_bit_en <= '1';
                else
                    last_bit_en <= '0';
                end if;
            end if;
        end if;
    end process;

end RTL;
