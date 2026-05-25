----------------------------------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 2/26/2026
-- Design Name: ControlUnit
-- Module Name: ControlUnit - Behavioral
-- Project Name: Lab3
-- Target Devices: Basys3
--
-- Description: Implements the control unit that decodes the instruction Opcode 
--              and Funct fields to generate control outputs using separate 
--              processes per signal.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ControlUnit is
    Port (
        Opcode     : in  STD_LOGIC_VECTOR(5 downto 0);
        Funct      : in  STD_LOGIC_VECTOR(5 downto 0);
        RegWrite   : out STD_LOGIC;
        MemtoReg   : out STD_LOGIC;
        MemWrite   : out STD_LOGIC;
        ALUControl : out STD_LOGIC_VECTOR(3 downto 0);
        ALUSrc     : out STD_LOGIC;
        RegDst     : out STD_LOGIC
    );
end ControlUnit;

architecture Behavioral of ControlUnit is
begin

    -- RegWrite process
    process(Opcode)
    begin
        case Opcode is
            when "000000" => RegWrite <= '1';  -- R-type
            when "001000" => RegWrite <= '1';  -- ADDI
            when "001100" => RegWrite <= '1';  -- ANDI
            when "001101" => RegWrite <= '1';  -- ORI
            when "001110" => RegWrite <= '1';  -- XORI
            when "100011" => RegWrite <= '1';  -- LW
            when others   => RegWrite <= '0';
        end case;
    end process;

    -- MemtoReg process
    process(Opcode)
    begin
        if Opcode = "100011" then
            MemtoReg <= '1';
        else
            MemtoReg <= '0';
        end if;
    end process;

    -- MemWrite process
    process(Opcode)
    begin
        if Opcode = "101011" then
            MemWrite <= '1';
        else
            MemWrite <= '0';
        end if;
    end process;

    -- ALUSrc process
    process(Opcode)
    begin
        if Opcode = "000000" then
            ALUSrc <= '0';
        else
            ALUSrc <= '1';
        end if;
    end process;

    -- RegDst process
    process(Opcode)
    begin
        if Opcode = "000000" then
            RegDst <= '1';
        else
            RegDst <= '0';
        end if;
    end process;

    -- ALUControl process
    process(Opcode, Funct)
    begin
        case Opcode is
            when "000000" =>
                case Funct is
                    when "100000" => ALUControl <= "0100";  -- ADD
                    when "100100" => ALUControl <= "1010";  -- AND
                    when "011001" => ALUControl <= "0110";  -- MULTU
                    when "100101" => ALUControl <= "1000";  -- OR
                    when "000000" => ALUControl <= "1100";  -- SLL
                    when "000011" => ALUControl <= "1110";  -- SRA
                    when "000010" => ALUControl <= "1101";  -- SRL
                    when "100010" => ALUControl <= "0101";  -- SUB
                    when "100110" => ALUControl <= "1011";  -- XOR
                    when others   => ALUControl <= "0000";
                end case;
            when "001000" => ALUControl <= "0100";  -- ADDI
            when "001100" => ALUControl <= "1010";  -- ANDI
            when "001101" => ALUControl <= "1000";  -- ORI
            when "001110" => ALUControl <= "1011";  -- XORI
            when "101011" => ALUControl <= "0100";  -- SW
            when "100011" => ALUControl <= "0100";  -- LW
            when others   => ALUControl <= "0000";
        end case;
    end process;

end Behavioral;
