-----------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 3/25/2026
-- Design Name: WritebackStage
-- Module Name: WritebackStage - Behavioral
-- Project Name: Memstage_Wb
-- Target Devices: Basys3
--
-- Description:
--   Writeback stage for the pipelined MIPS datapath.
--   Selects either ALUResult or ReadData based on
--   MemtoReg, and passes WriteReg and RegWrite through.
-----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WritebackStage is
    port (
        WriteReg    : in  std_logic_vector(4 downto 0);
        RegWrite    : in  std_logic;
        MemtoReg    : in  std_logic;
        ALUResult   : in  std_logic_vector(31 downto 0);
        ReadData    : in  std_logic_vector(31 downto 0);
        Result      : out std_logic_vector(31 downto 0);
        WriteRegOut : out std_logic_vector(4 downto 0);
        RegWriteOut : out std_logic
    );
end WritebackStage;

architecture Behavioral of WritebackStage is
begin

    process(ReadData, MemtoReg, ALUResult)
    begin
        if MemtoReg = '1' then
            Result <= ReadData;
        else
            Result <= ALUResult;
        end if;
    end process;

    WriteRegOut <= WriteReg;
    RegWriteOut <= RegWrite;

end Behavioral;