-----------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 3/23/2026
-- Design Name: DataMemory
-- Module Name: DataMemory - Behavioral
-- Project Name: Memstage_Wb
-- Target Devices: Basys3
--
-- Description: 
--   Writable data memory for the Memory stage.
--   Address 1022 maps to switches (read only).
--   Address 1023 maps to seven segment output.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory is
    generic (
        WIDTH      : integer := 32;
        ADDR_SPACE : integer := 10
    );
    port (
        clk       : in  std_logic;
        w_en      : in  std_logic;
        addr      : in  std_logic_vector(ADDR_SPACE - 1 downto 0);
        d_in      : in  std_logic_vector(WIDTH - 1 downto 0);
        switches  : in  std_logic_vector(15 downto 0);
        d_out     : out std_logic_vector(WIDTH - 1 downto 0);
        seven_seg : out std_logic_vector(15 downto 0)
    );
end DataMemory;

architecture Behavioral of DataMemory is

    type mem_array_t is array (0 to (2 ** ADDR_SPACE) - 1) of
        std_logic_vector(WIDTH - 1 downto 0);

    signal mips_mem      : mem_array_t := (others => (others => '0'));
    signal d_out_reg     : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
    signal seven_seg_reg : std_logic_vector(15 downto 0) := (others => '0');

    constant SWITCH_ADDR : integer := (2 ** ADDR_SPACE) - 2; -- 1022 when ADDR_SPACE = 10
    constant SEVSEG_ADDR : integer := (2 ** ADDR_SPACE) - 1; -- 1023 when ADDR_SPACE = 10

begin

    process(clk)
        variable addr_int : integer;
    begin
        if rising_edge(clk) then
            addr_int := to_integer(unsigned(addr));

            -- Write behavior
            if w_en = '1' then
                if addr_int = SEVSEG_ADDR then
                    seven_seg_reg <= d_in(15 downto 0);
                elsif addr_int /= SWITCH_ADDR then
                    mips_mem(addr_int) <= d_in;
                end if;
            end if;

            -- Read behavior
            if addr_int = SWITCH_ADDR then
                d_out_reg <= std_logic_vector(resize(unsigned(switches), WIDTH));
            elsif addr_int = SEVSEG_ADDR then
                d_out_reg <= (others => '0');
            else
                d_out_reg <= mips_mem(addr_int);
            end if;
        end if;
    end process;

    d_out <= d_out_reg;
    seven_seg <= seven_seg_reg;

end Behavioral;