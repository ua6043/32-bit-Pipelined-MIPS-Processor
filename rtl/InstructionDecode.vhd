----------------------------------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 2/26/2026
-- Design Name: InstructionDecode
-- Module Name: InstructionDecode - Behavioral
-- Project Name: Lab3
-- Target Devices: Basys3
--
-- Description: Implements Instruction Decode stage by parsing instruction fields,
--              sign-extending the immediate and producing decoded outputs and
--              control signals.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionDecode is
    Port (
        clk          : in  STD_LOGIC;
        Instruction  : in  STD_LOGIC_VECTOR(31 downto 0);
        RegWriteAddr : in  STD_LOGIC_VECTOR(4 downto 0);
        RegWriteData : in  STD_LOGIC_VECTOR(31 downto 0);
        RegWriteEn   : in  STD_LOGIC;
        RegWrite     : out STD_LOGIC;
        MemtoReg     : out STD_LOGIC;
        MemWrite     : out STD_LOGIC;
        ALUControl   : out STD_LOGIC_VECTOR(3 downto 0);
        ALUSrc       : out STD_LOGIC;
        RegDst       : out STD_LOGIC;
        RD1          : out STD_LOGIC_VECTOR(31 downto 0);
        RD2          : out STD_LOGIC_VECTOR(31 downto 0);
        RtDest       : out STD_LOGIC_VECTOR(4 downto 0);
        RdDest       : out STD_LOGIC_VECTOR(4 downto 0);
        ImmOut       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end InstructionDecode;

architecture Behavioral of InstructionDecode is

    component ControlUnit
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
    end component;

    component RegisterFile
        Port (
            clk_n   : in  STD_LOGIC;
            we    : in  STD_LOGIC;
            Addr1 : in  STD_LOGIC_VECTOR(4 downto 0);
            Addr2 : in  STD_LOGIC_VECTOR(4 downto 0);
            Addr3 : in  STD_LOGIC_VECTOR(4 downto 0);
            wd    : in  STD_LOGIC_VECTOR(31 downto 0);
            RD1   : out STD_LOGIC_VECTOR(31 downto 0);
            RD2   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Internal parsed instruction signals
    signal Opcode : STD_LOGIC_VECTOR(5 downto 0);
    signal Rs     : STD_LOGIC_VECTOR(4 downto 0);
    signal Rt     : STD_LOGIC_VECTOR(4 downto 0);
    signal Rd     : STD_LOGIC_VECTOR(4 downto 0);
    signal Funct  : STD_LOGIC_VECTOR(5 downto 0);
    signal Imm    : STD_LOGIC_VECTOR(15 downto 0);

begin

    -- Parsed instruction fields
    Opcode <= Instruction(31 downto 26);
    Rs     <= Instruction(25 downto 21);
    Rt     <= Instruction(20 downto 16);
    Rd     <= Instruction(15 downto 11);
    Funct  <= Instruction(5 downto 0);
    Imm    <= Instruction(15 downto 0);

    -- Passed destination register fields to outputs
    RtDest <= Rt;
    RdDest <= Rd;

    -- Sign extend immediate
    ImmOut <= std_logic_vector(resize(signed(Imm), 32));

    -- Control Unit instantiation
    CU : ControlUnit
        port map (
            Opcode     => Opcode,
            Funct      => Funct,
            RegWrite   => RegWrite,
            MemtoReg   => MemtoReg,
            MemWrite   => MemWrite,
            ALUControl => ALUControl,
            ALUSrc     => ALUSrc,
            RegDst     => RegDst
        );

    -- Register File instantiation
    RF : RegisterFile
        port map (
            clk_n   => clk,
            we    => RegWriteEn,
            Addr1 => Rs,
            Addr2 => Rt,
            Addr3 => RegWriteAddr,
            wd    => RegWriteData,
            RD1   => RD1,
            RD2   => RD2
        );

end Behavioral;
