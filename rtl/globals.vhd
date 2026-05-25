------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/15/2026
-- Design Name: globals
-- Module Name: globals - package (library)
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: Constants used in top and test bench level
--     Xilinx does not like generics in the top level of a design
------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
package globals is
  constant N : INTEGER := 32;
  constant M : INTEGER := 5;
end;
