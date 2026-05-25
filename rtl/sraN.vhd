------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/15/2026
-- Design Name: sraN
-- Module Name: sraN - rtl
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: Generic N-bit arithmetic right shift unit.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sraN is
  generic ( N : integer := 32; M : integer := 5 );
  port (
    A         : in  std_logic_vector(N-1 downto 0);
    SHIFT_AMT : in  std_logic_vector(M-1 downto 0);
    Y         : out std_logic_vector(N-1 downto 0)
  );
end sraN;

architecture rtl of sraN is
begin
  Y <= std_logic_vector(shift_right(signed(A), to_integer(unsigned(SHIFT_AMT))));
end rtl;