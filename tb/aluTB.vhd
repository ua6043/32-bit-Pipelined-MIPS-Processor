--------------------------------------------------
--  File:          aluTB.vhd
--
--  Entity:        aluTB
--  Architecture:  Testbench
--  Author:        Jason Blocklove
--  Created:       07/29/19
--  Modified:      Umar Arif
--  VHDL'93
--  Description:   The following is the entity and
--                 architectural description of a
--                aluTB
-------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity aluTB is
    Generic ( N : integer := 32 );
end aluTB;

architecture tb of aluTB is

component aluN IS
    Port ( in1 : in  std_logic_vector(N-1 downto 0);
           in2 : in  std_logic_vector(N-1 downto 0);
           control : in  std_logic_vector(3 downto 0);
           out1    : out std_logic_vector(N-1 downto 0)
          );
end component;

signal in1 : std_logic_vector(N-1 downto 0);
signal in2 : std_logic_vector(N-1 downto 0);
signal control : std_logic_vector(3 downto 0);
signal out1 : std_logic_vector(N-1 downto 0);

type alu_tests is record
	-- Test Inputs
	in1 : std_logic_vector(N-1 downto 0);
	in2 : std_logic_vector(N-1 downto 0);
	control : std_logic_vector(3 downto 0);
	-- Test Outputs
	out1 : std_logic_vector(N-1 downto 0);
end record;

type test_array is array (natural range <>) of alu_tests;

constant tests : test_array :=(
    -- ADD 0100
    (in1 => x"00000001", in2 => x"00000001", control => "0100", out1 => x"00000002"),
    (in1 => x"00000010", in2 => x"00000005", control => "0100", out1 => x"00000015"),
    (in1 => x"12345678", in2 => x"11111111", control => "0100", out1 => x"23456789"),

    -- ADD edge: overflow
    (in1 => x"7FFFFFFF", in2 => x"00000001", control => "0100", out1 => x"80000000"),

    -- SUB 0101
    (in1 => x"00000005", in2 => x"00000003", control => "0101", out1 => x"00000002"),
    (in1 => x"00000010", in2 => x"00000001", control => "0101", out1 => x"0000000F"),
    (in1 => x"12345678", in2 => x"00005678", control => "0101", out1 => x"12340000"),

    -- SUB edge: underflow
    (in1 => x"80000000", in2 => x"00000001", control => "0101", out1 => x"7FFFFFFF"),
    
    -- MULTU 0110 
    (in1 => x"00000003", in2 => x"00000004", control => "0110", out1 => x"0000000C"),
    (in1 => x"0000FFFF", in2 => x"00000002", control => "0110", out1 => x"0001FFFE"),
    (in1 => x"00001234", in2 => x"00000010", control => "0110", out1 => x"00012340"),
    
    -- MULTU edge: one operand is zero
    (in1 => x"00001234", in2 => x"00000000", control => "0110", out1 => x"00000000"),
    
    -- MULTU edge: both operands are maximum
    (in1 => x"0000FFFF", in2 => x"0000FFFF", control => "0110", out1 => x"FFFE0001"),

    -- OR 1000
    (in1 => x"0F0F0000", in2 => x"0000F0F0", control => "1000", out1 => x"0F0FF0F0"),
    (in1 => x"AAAAAAAA", in2 => x"55555555", control => "1000", out1 => x"FFFFFFFF"),
    (in1 => x"12340000", in2 => x"00005678", control => "1000", out1 => x"12345678"),

    -- AND 1010
    (in1 => x"0F0F0F0F", in2 => x"00FF00FF", control => "1010", out1 => x"000F000F"),
    (in1 => x"AAAAAAAA", in2 => x"55555555", control => "1010", out1 => x"00000000"),
    (in1 => x"FFFF0000", in2 => x"12345678", control => "1010", out1 => x"12340000"),

    -- XOR 1011
    (in1 => x"0F0F0000", in2 => x"0000F0F0", control => "1011", out1 => x"0F0FF0F0"),
    (in1 => x"AAAAAAAA", in2 => x"55555555", control => "1011", out1 => x"FFFFFFFF"),
    (in1 => x"FFFF0000", in2 => x"12345678", control => "1011", out1 => x"EDCB5678"),

    -- SLL 1100
    (in1 => x"00000001", in2 => x"00000001", control => "1100", out1 => x"00000002"),
    (in1 => x"00000003", in2 => x"00000002", control => "1100", out1 => x"0000000C"),
    (in1 => x"0000FFFF", in2 => x"00000008", control => "1100", out1 => x"00FFFF00"),

    -- SRL 1101
    (in1 => x"00000010", in2 => x"00000001", control => "1101", out1 => x"00000008"),
    (in1 => x"80000000", in2 => x"00000001", control => "1101", out1 => x"40000000"),
    (in1 => x"00000020", in2 => x"00000005", control => "1101", out1 => x"00000001"),

    -- SRA 1110
    (in1 => x"F0000000", in2 => x"00000004", control => "1110", out1 => x"FF000000"),
    (in1 => x"70000000", in2 => x"00000004", control => "1110", out1 => x"07000000"),
    (in1 => x"80000000", in2 => x"00000001", control => "1110", out1 => x"C0000000")
);

begin


aluN_0 : aluN
    port map (
			in1  => in1,
			in2  => in2,
            control  => control,
            out1     => out1
		);

	stim_proc:process
	begin

		for i in tests'range loop
        in1     <= tests(i).in1;
        in2     <= tests(i).in2;
        control <= tests(i).control;

        wait for 100 ns;  -- allow signals/UUT to update

        assert (out1 = tests(i).out1)
          report "ALU test failed at test index " & integer'image(i)
          severity failure;
          
		wait for 100 ns;
		end loop;


		assert false
		  report "Testbench Concluded."
		  severity failure;

	end process;
end tb;
