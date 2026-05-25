------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/15/2026
-- Design Name: fa
-- Module Name: fa - dataflow
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: One-bit full adder.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fa is
    Port (
        A    : in  std_logic;
        B    : in  std_logic;
        Cin  : in  std_logic;
        Sum  : out std_logic;
        Cout : out std_logic
    );
end fa;

architecture Dataflow of fa is
begin
    Sum  <= A XOR B XOR Cin;
    Cout <= (A AND B) OR (A AND Cin) OR (B AND Cin);
end Dataflow;