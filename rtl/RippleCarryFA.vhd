------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/15/2026
-- Design Name: RippleCarryFA
-- Module Name: RippleCarryFA - structural
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: Generic N-bit ripple-carry adder/subtractor.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RippleCarryFA is
    Generic ( N : integer := 32 );
    Port (
        A   : in  std_logic_vector(N-1 downto 0);
        B   : in  std_logic_vector(N-1 downto 0);
        OP  : in  std_logic;
        Sum : out std_logic_vector(N-1 downto 0)
    );
end RippleCarryFA;

architecture Structural of RippleCarryFA is

    component fa is
        Port (
            A    : in  std_logic;
            B    : in  std_logic;
            Cin  : in  std_logic;
            Sum  : out std_logic;
            Cout : out std_logic
        );
    end component;

    signal carry : std_logic_vector(N downto 0);
    signal B_ctrl  : std_logic_vector(N-1 downto 0);

begin

    carry(0) <= OP;
    B_XOR : for i in 0 to N-1 generate
        B_ctrl(i) <= B(i) xor OP;
    end generate B_XOR;

    -- Instantiate N full adders in a chain
    ADDER_CHAIN : for i in 0 to N-1 generate
        Full_Adder : fa
            port map (
                A    => A(i),
                B    => B_ctrl(i),
                Cin  => carry(i),
                Sum  => Sum(i),
                Cout => carry(i+1)
            );
    end generate ADDER_CHAIN;

end Structural;