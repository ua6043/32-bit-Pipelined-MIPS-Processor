------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/15/2026
-- Design Name: xorN
-- Module Name: xorN - rtl
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: Generic N-bit bitwise XOR unit.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity xorN is
  generic ( N : integer := 32 );
  port (
    A : in  std_logic_vector(N-1 downto 0);
    B : in  std_logic_vector(N-1 downto 0);
    Y : out std_logic_vector(N-1 downto 0)
  );
end xorN;

architecture rtl of xorN is
begin
  Y <= A xor B;
end rtl;
