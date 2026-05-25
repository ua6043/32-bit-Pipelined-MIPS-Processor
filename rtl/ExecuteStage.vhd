------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 3/23/2026
-- Design Name: ExecuteStage
-- Module Name: ExecuteStage - structural
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: Execute stage wrapper for the ALU datapath.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ExecuteStage is
    Port (
        RegWrite   : in  std_logic;
        MemtoReg   : in  std_logic;
        MemWrite   : in  std_logic;
        ALUControl : in  std_logic_vector(3 downto 0);
        ALUSrc     : in  std_logic;
        RegDst     : in  std_logic;
        RD1        : in  std_logic_vector(31 downto 0);
        RD2        : in  std_logic_vector(31 downto 0);
        RtDest     : in  std_logic_vector(4 downto 0);
        RdDest     : in  std_logic_vector(4 downto 0);
        ImmOut     : in  std_logic_vector(31 downto 0);

        RegWriteOut : out std_logic;
        MemtoRegOut : out std_logic;
        MemWriteOut : out std_logic;
        ALUResult   : out std_logic_vector(31 downto 0);
        WriteData   : out std_logic_vector(31 downto 0);
        WriteReg    : out std_logic_vector(4 downto 0)
    );
end ExecuteStage;

architecture structural of ExecuteStage is
    signal ALUIn2 : std_logic_vector(31 downto 0);
begin

    ALUIn2 <= RD2 when ALUSrc = '0' else ImmOut;

    WriteData <= RD2;
    WriteReg <= RtDest when RegDst = '0' else RdDest;

    RegWriteOut <= RegWrite;
    MemtoRegOut <= MemtoReg;
    MemWriteOut <= MemWrite;

    alu_comp : entity work.aluN
        port map (
            in1     => RD1,
            in2     => ALUIn2,
            control => ALUControl,
            out1    => ALUResult
        );

end structural;