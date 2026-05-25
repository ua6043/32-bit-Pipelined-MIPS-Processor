------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/15/2026
-- Design Name: andN
-- Module Name: andN - rtl
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: Generic N-bit bitwise AND unit.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity andN is
  generic ( N : integer := 32 );
  port (
    A : in  std_logic_vector(N-1 downto 0);
    B : in  std_logic_vector(N-1 downto 0);
    Y : out std_logic_vector(N-1 downto 0)
  );
end andN;

architecture rtl of andN is
begin
  Y <= A and B;
end rtl;
