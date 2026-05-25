------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 3/23/2026
-- Design Name: MultiplierTB
-- Module Name: MultiplierTB - Testbench
-- Project Name: Exercise4
-- Target Devices: Basys3
--
-- Description: Self-checking testbench for generic
--              unsigned Multiplier.
------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MultiplierTB is
    Generic ( N : integer := 32 );
end MultiplierTB;

architecture tb of MultiplierTB is

component Multiplier is
    Generic ( N : integer := 32 );
    Port (
        A       : in  std_logic_vector((N/2)-1 downto 0);
        B       : in  std_logic_vector((N/2)-1 downto 0);
        Product : out std_logic_vector(N-1 downto 0)
    );
end component;

signal A       : std_logic_vector((N/2)-1 downto 0);
signal B       : std_logic_vector((N/2)-1 downto 0);
signal Product : std_logic_vector(N-1 downto 0);

type mult_tests is record
    A       : std_logic_vector((N/2)-1 downto 0);
    B       : std_logic_vector((N/2)-1 downto 0);
    Product : std_logic_vector(N-1 downto 0);
end record;

type test_array is array (natural range <>) of mult_tests;

constant tests : test_array :=(
    -- General cases
    (A => x"0003", B => x"0004", Product => x"0000000C"),
    (A => x"0005", B => x"0007", Product => x"00000023"),
    (A => x"0012", B => x"0034", Product => x"000003A8"),
    (A => x"00FF", B => x"0002", Product => x"000001FE"),
    (A => x"1234", B => x"0010", Product => x"00012340"),
    (A => x"00F0", B => x"000F", Product => x"00000E10"),
    (A => x"7FFF", B => x"0002", Product => x"0000FFFE"),

    -- Edge case: one operand is zero
    (A => x"1234", B => x"0000", Product => x"00000000"),

    -- Edge case: both operands maximum
    (A => x"FFFF", B => x"FFFF", Product => x"FFFE0001"),

    -- Edge case: overflow occurs without using maximum operands
    (A => x"8000", B => x"0002", Product => x"00010000")
);

begin

    uut : Multiplier
        generic map ( N => N )
        port map (
            A       => A,
            B       => B,
            Product => Product
        );

    stim_proc : process
    begin
        for i in tests'range loop
            A <= tests(i).A;
            B <= tests(i).B;

            wait for 1 ns;

            assert (Product = tests(i).Product)
                report "Multiplier test failed at index " & integer'image(i)
                severity failure;

            wait for 100 ns;
        end loop;

        assert false
            report "Testbench Concluded."
            severity failure;
    end process;

end tb;