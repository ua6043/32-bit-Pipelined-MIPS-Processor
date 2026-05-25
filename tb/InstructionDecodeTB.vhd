-------------------------------------------------
--  File:          InstructionDecodeTB.vhd
--
--  Entity:        InstructionDecodeTB
--  Architecture:  testbench
--  Author:        Jason Blocklove
--  Created:       09/04/19
--  Modified:
--  VHDL'93
--  Description:   The following is the entity and
--                 architectural description of a
--                 testbench for InstructionDecode
--                 stage
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionDecodeTB is
end InstructionDecodeTB;

architecture testbench of InstructionDecodeTB is

type test_vector is record
	Instruction	 : std_logic_vector(31 downto 0);
	RegWriteAddr : std_logic_vector(4 downto 0);
	RegWriteData : std_logic_vector(31 downto 0);
	RegWriteEn	 : std_logic;
	RegWrite	 : std_logic;
	MemtoReg	 : std_logic;
	MemWrite	 : std_logic;
	ALUControl	 : std_logic_vector(3 downto 0);
	ALUSrc		 : std_logic;
	RegDst		 : std_logic;
	RD1, RD2	 : std_logic_vector(31 downto 0);
	RtDest		 : std_logic_vector(4 downto 0);
	RdDest		 : std_logic_vector(4 downto 0);
	ImmOut		 : std_logic_vector(31 downto 0);
end record;

type test_array is array (natural range <>) of test_vector;
constant test_vector_array : test_array := (
--NOOP
	(Instruction => x"00000000",
	RegWriteAddr => "00000",
	RegWriteData => x"00000000",
	RegWriteEn => '0',
	RegWrite => '1',
	MemtoReg => '0',
	MemWrite => '0',
	ALUControl => "1100",
	ALUSrc => '0',
	RegDst => '1',
	RD1 => x"00000000",
	RD2 => x"00000000",
	RtDest => "00000",
	RdDest => "00000",
	ImmOut => x"00000000"),
--ADD R1, R1, R2 - 00000000001000010001000000100000
	(Instruction => x"00211020",
	RegWriteAddr => "00001",
	RegWriteData => x"12121212",
	RegWriteEn => '1',
	RegWrite => '1',
	MemtoReg => '0',
	MemWrite => '0',
	ALUControl => "0100",
	ALUSrc => '0',
	RegDst => '1',
	RD1 => x"12121212",
	RD2 => x"12121212",
	RtDest => "00001",
	RdDest => "00010",
	ImmOut => x"00001020"),
--ADDI R1, R1, 13 - 00100000001000010000000000001101
	(Instruction => x"2021000d",
	RegWriteAddr => "00010",
	RegWriteData => x"00000001",
	RegWriteEn => '1',
	RegWrite => '1',
	MemtoReg => '0',
	MemWrite => '0',
	ALUControl => "0100",
	ALUSrc => '1',
	RegDst => '0',
	RD1 => x"12121212",
	RD2 => x"12121212",
	RtDest => "00001",
	RdDest => "00000",
	ImmOut => x"0000000d"),

    -- SUB R3, R1, R2 (R-type)
    (Instruction => x"00221822",
    RegWriteAddr => "00011",
    RegWriteData => x"00000000",
    RegWriteEn   => '0',
    RegWrite     => '1',
    MemtoReg     => '0',
    MemWrite     => '0',
    ALUControl   => "0101",
    ALUSrc       => '0',
    RegDst       => '1',
    RD1          => x"12121212",
    RD2          => x"00000001",
    RtDest       => "00010",
    RdDest       => "00011",
    ImmOut       => x"00001822"),

    -- ORI R4, R1, 255 (I-type)
    (Instruction => x"3424000f",
    RegWriteAddr => "00100",
    RegWriteData => x"00000000",
    RegWriteEn   => '0',
    RegWrite     => '1',
    MemtoReg     => '0',
    MemWrite     => '0',
    ALUControl   => "1000",
    ALUSrc       => '1',
    RegDst       => '0',
    RD1          => x"12121212",
    RD2          => x"00000000",
    RtDest       => "00100",
    RdDest       => "00000",
    ImmOut       => x"0000000f"),
    
    
    -- SW R2, 4(R1)
    (Instruction => x"AC220004",
    RegWriteAddr => "00000",
    RegWriteData => x"00000000",
    RegWriteEn   => '0',
    RegWrite     => '0',   
    MemtoReg     => '0',   
    MemWrite     => '1',   
    ALUControl   => "0100", 
    ALUSrc       => '1',  
    RegDst       => '0',   
    RD1          => x"12121212",
    RD2          => x"00000001", 
    RtDest       => "00010",     
    RdDest       => "00000",     
    ImmOut       => x"00000004")
);

component instr_decode is
	port(
	--------- INPUTS ------------------
		--Main Input
		Instruction	: in std_logic_vector(31 downto 0);

		--CLK
		clk			: in std_logic;

		--WB Inputs
		RegWriteAddr : in std_logic_vector(4 downto 0);
		RegWriteData : in std_logic_vector(31 downto 0);
		RegWriteEn	: in std_logic;

	---------- OUTPUTS ----------------
		--Cotrol Unit Outputs
		RegWrite	: out std_logic;
		MemtoReg	: out std_logic;
		MemWrite	: out std_logic;
		ALUControl	: out std_logic_vector(3 downto 0);
		ALUSrc		: out std_logic;
		RegDst		: out std_logic;

		--Register File Outputs
		RD1, RD2	: out std_logic_vector(31 downto 0);

		--Other Outputs
		RtDest		: out std_logic_vector(4 downto 0);
		RdDest		: out std_logic_vector(4 downto 0);
		ImmOut		: out std_logic_vector(31 downto 0)
	);
end component;

signal Instruction	: std_logic_vector(31 downto 0);
signal clk			: std_logic;
signal RegWriteAddr : std_logic_vector(4 downto 0);
signal RegWriteData : std_logic_vector(31 downto 0);
signal RegWriteEn	: std_logic;
signal RegWrite		: std_logic;
signal MemtoReg		: std_logic;
signal MemWrite		: std_logic;
signal ALUControl	: std_logic_vector(3 downto 0);
signal ALUSrc		: std_logic;
signal RegDst		: std_logic;
signal RD1, RD2		: std_logic_vector(31 downto 0);
signal RtDest		: std_logic_vector(4 downto 0);
signal RdDest		: std_logic_vector(4 downto 0);
signal ImmOut		: std_logic_vector(31 downto 0);

begin


UUT : instr_decode
	port map (
	--------- INPUTS ------------------
		--Main Input
		Instruction	 => Instruction,
		--CLK
		clk			 => clk,
		--WB Inputs
		RegWriteAddr  => RegWriteAddr,
		RegWriteData  => RegWriteData,
		RegWriteEn	 => RegWriteEn,
	---------- OUTPUTS ----------------
		--Cotrol Unit Outputs
		RegWrite	 => RegWrite,
		MemtoReg	 => MemtoReg,
		MemWrite	 => MemWrite,
		ALUControl	 => ALUControl,
		ALUSrc		 => ALUSrc,
		RegDst		 => RegDst,
		--Register File Outputs
		RD1 => RD1,
		RD2 => RD2,
		--Other Outputs
		RtDest		 => RtDest,
		RdDest		 => RdDest,
		ImmOut		 => ImmOut
	);

clk_proc:process
begin
	clk <= '0';
	wait for 50 ns;
	clk <= '1';
	wait for 50 ns;
end process;

stim_proc:process
begin
	wait until clk='0';
	for i in test_vector_array'range loop
		wait until clk='1';
		Instruction <= test_vector_array(i).Instruction;
		RegWriteAddr <= test_vector_array(i).RegWriteAddr;
		RegWriteData <= test_vector_array(i).RegWriteData;
		RegWriteEn <= test_vector_array(i).RegWriteEn;
		wait until clk='0';
    	wait for 5 ns;

        assert (RegWrite = test_vector_array(i).RegWrite)
            report "Test " & integer'image(i) & " RegWrite failed."
            severity error;
        assert (MemtoReg = test_vector_array(i).MemtoReg)
            report "Test " & integer'image(i) & " MemtoReg failed."
            severity error;
        assert (MemWrite = test_vector_array(i).MemWrite)
            report "Test " & integer'image(i) & " MemWrite failed."
            severity error;
        assert (ALUControl = test_vector_array(i).ALUControl)
            report "Test " & integer'image(i) & " ALUControl failed."
            severity error;
        assert (ALUSrc = test_vector_array(i).ALUSrc)
            report "Test " & integer'image(i) & " ALUSrc failed."
            severity error;
        assert (RegDst = test_vector_array(i).RegDst)
            report "Test " & integer'image(i) & " RegDst failed."
            severity error;
        assert (RD1 = test_vector_array(i).RD1)
            report "Test " & integer'image(i) & " RD1 failed."
            severity error;
        assert (RD2 = test_vector_array(i).RD2)
            report "Test " & integer'image(i) & " RD2 failed."
            severity error;
        assert (RtDest = test_vector_array(i).RtDest)
            report "Test " & integer'image(i) & " RtDest failed."
            severity error;
        assert (RdDest = test_vector_array(i).RdDest)
            report "Test " & integer'image(i) & " RdDest failed."
            severity error;
        assert (ImmOut = test_vector_array(i).ImmOut)
            report "Test " & integer'image(i) & " ImmOut failed."
            severity error;

	end loop;
	wait until clk='0';
    assert false
        report "Testbench Concluded"
        severity failure;
end process;

end testbench;
