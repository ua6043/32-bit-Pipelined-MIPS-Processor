----------------------------------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/22/2026
-- Design Name: RegisterFile
-- Module Name: RegisterFile - behavioral
-- Project Name: Lab2
-- Target Devices: Basys3
--
-- Description: Register file with two read outputs and one write input. 
--              Reads are immediate and writes happen on falling clock 
--              edges. Register 0 always stays 0.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
    generic(
        BIT_WIDTH      : integer := 32; -- width of each register
        LOG_PORT_DEPTH : integer := 5  -- address width
    );
    port(
        clk_n, we              : in std_logic;                                    -- active clock input, write enable
        Addr1, Addr2, Addr3    : in std_logic_vector(LOG_PORT_DEPTH-1 downto 0);  -- read, read, write addresses
        wd                     : in std_logic_vector(BIT_WIDTH-1 downto 0);       -- write data
        RD1, RD2               : out std_logic_vector(BIT_WIDTH-1 downto 0)       -- read data outputs
    );
end RegisterFile;

architecture behavioral of RegisterFile is
    -- Register file storage array
    type register_array is array(0 to (2**LOG_PORT_DEPTH)-1) of std_logic_vector(BIT_WIDTH-1 downto 0);
    signal registers : register_array := (others => (others => '0'));

    constant zero_address : std_logic_vector(LOG_PORT_DEPTH-1 downto 0) := (others => '0');

begin
    -- Asynchronous reads
    RD1 <= (others => '0') when Addr1 = zero_address else registers(to_integer(unsigned(Addr1)));
    RD2 <= (others => '0') when Addr2 = zero_address else registers(to_integer(unsigned(Addr2)));

    -- Synchronous writes on falling clock edge
    process(clk_n)
    begin
        if falling_edge(clk_n) and we = '1' and Addr3 /= zero_address then  --register zero is non-writable
            registers(to_integer(unsigned(Addr3))) <= wd;
        end if;
    end process;
end behavioral;
