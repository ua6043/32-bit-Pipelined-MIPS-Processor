----------------------------------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 4/15/2026
-- Design Name: MicroprocessorTB
-- Module Name: MicroprocessorTB - Behavioral
-- Project Name: pipelined_mips
-- Target Devices: Basys3
--
-- Description:
--   Behavioral testbench for the pipelined MIPS processor.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MicroprocessorTB is
end MicroprocessorTB;

architecture Behavioral of MicroprocessorTB is

    constant CLK_PERIOD : time := 10 ns;

    signal clk            : std_logic := '0';
    signal rst            : std_logic := '1';
    signal Switches       : std_logic_vector(15 downto 0) := (others => '0');

    signal ActiveDigit    : std_logic_vector(3 downto 0);
    signal SevenSegDigit  : std_logic_vector(6 downto 0);
    signal ALUResultDebug : std_logic_vector(31 downto 0);
    signal MemOutDebug    : std_logic_vector(31 downto 0);

begin

    uut : entity work.Microprocessor_HW
        port map (
            clk            => clk,
            rst            => rst,
            Switches       => Switches,
            ActiveDigit    => ActiveDigit,
            SevenSegDigit  => SevenSegDigit
--            ALUResultDebug => ALUResultDebug,
--            MemOutDebug    => MemOutDebug
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    stim_proc : process
    begin
        -- No switch-based instruction is used
        Switches <= (others => '0');

        -- Hold reset active, then release
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';

        -- Let the whole program execute through the pipeline
        wait for 50 * CLK_PERIOD;

        assert false
            report "Testbench concluded."
            severity failure;
    end process;
end Behavioral;