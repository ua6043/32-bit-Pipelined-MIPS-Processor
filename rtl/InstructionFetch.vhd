----------------------------------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 2/26/2026
-- Design Name: InstructionFetch
-- Module Name: InstructionFetch - Behavioral
-- Project Name: Lab3
-- Target Devices: Basys3
--
-- Description: Implements Instruction Fetch stage using a 28-bit program counter
--              with async reset and a PC+4 update on each rising clock edge
--              Connects PC to InstructionMem to output Instruction[31:0].
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionFetch is
    Port ( 
        clk, rst : in std_logic;
        Instruction : out std_logic_vector(31 downto 0)
    );
end InstructionFetch;

architecture structural of InstructionFetch is
    component InstructionMem is
        port (
            addr  : in  std_logic_vector(27 downto 0);
            d_out : out std_logic_vector(31 downto 0)
        );
    end component;

    signal pc      : std_logic_vector(27 downto 0) := (others => '0');
    signal instr_w : std_logic_vector(31 downto 0);

begin
    -- Instruction Memory instance
    imem : InstructionMem
        port map (
            addr  => pc,
            d_out => instr_w
        );

    -- Output is the memory word at current PC
    Instruction <= instr_w;

    -- async reset, at rising edge increment pc by 4
    process(clk, rst)
    begin
        if rst = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            pc <= std_logic_vector(unsigned(pc) + 4);
        end if;
    end process;

end structural;
