------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/15/2026
-- Design Name: orN
-- Module Name: orN - rtl
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: Generic N-bit bitwise OR unit.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity orN is
  generic ( N : integer := 32 );
  port (
    A : in  std_logic_vector(N-1 downto 0);
    B : in  std_logic_vector(N-1 downto 0);
    Y : out std_logic_vector(N-1 downto 0)
  );
end orN;

architecture rtl of orN is
begin
  Y <= A or B;
end rtl;
