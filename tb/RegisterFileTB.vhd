----------------------------------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/22/2026
-- Design Name: RegisterFileTB
-- Module Name: RegisterFileTB - tb
-- Project Name: Lab2
-- Target Devices: Basys3
--
-- Description: Testbench for Register File
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFileTB is
end RegisterFileTB;

architecture tb of RegisterFileTB is

    constant BIT_WIDTH      : integer := 8;
    constant LOG_PORT_DEPTH : integer := 3;

    type test_vector is record
        we    : std_logic;
        Addr1 : std_logic_vector(LOG_PORT_DEPTH-1 downto 0);
        Addr2 : std_logic_vector(LOG_PORT_DEPTH-1 downto 0);
        Addr3 : std_logic_vector(LOG_PORT_DEPTH-1 downto 0);
        wd    : std_logic_vector(BIT_WIDTH-1 downto 0);
        RD1   : std_logic_vector(BIT_WIDTH-1 downto 0);
        RD2   : std_logic_vector(BIT_WIDTH-1 downto 0);
    end record;
   
-- Test vectors
    constant num_tests : integer := 10;
    type test_array is array (0 to num_tests-1) of test_vector;

    constant test_vector_array : test_array := (
        (we => '0', Addr1 => "000", Addr2 => "000", Addr3 => "001", wd => x"10", RD1 => x"00", RD2 => x"00"),
        (we => '1', Addr1 => "000", Addr2 => "000", Addr3 => "001", wd => x"10", RD1 => x"00", RD2 => x"00"),
        (we => '1', Addr1 => "001", Addr2 => "000", Addr3 => "010", wd => x"FF", RD1 => x"10", RD2 => x"00"),
        (we => '0', Addr1 => "100", Addr2 => "010", Addr3 => "100", wd => x"AA", RD1 => x"00", RD2 => x"FF"),
        (we => '1', Addr1 => "011", Addr2 => "001", Addr3 => "011", wd => x"33", RD1 => x"33", RD2 => x"10"),
        (we => '1', Addr1 => "010", Addr2 => "011", Addr3 => "010", wd => x"22", RD1 => x"22", RD2 => x"33"),
        (we => '0', Addr1 => "010", Addr2 => "010", Addr3 => "110", wd => x"66", RD1 => x"22", RD2 => x"22"),
        (we => '1', Addr1 => "111", Addr2 => "110", Addr3 => "111", wd => x"77", RD1 => x"77", RD2 => x"00"),
        (we => '1', Addr1 => "000", Addr2 => "111", Addr3 => "000", wd => x"AA", RD1 => x"00", RD2 => x"77"),
        (we => '1', Addr1 => "101", Addr2 => "100", Addr3 => "101", wd => x"55", RD1 => x"55", RD2 => x"00")
    );

    -- UUT signals
    signal clk_n : std_logic := '1';
    signal we    : std_logic := '0';
    signal Addr1 : std_logic_vector(LOG_PORT_DEPTH-1 downto 0) := (others => '0');
    signal Addr2 : std_logic_vector(LOG_PORT_DEPTH-1 downto 0) := (others => '0');
    signal Addr3 : std_logic_vector(LOG_PORT_DEPTH-1 downto 0) := (others => '0');
    signal wd    : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
    signal RD1   : std_logic_vector(BIT_WIDTH-1 downto 0);
    signal RD2   : std_logic_vector(BIT_WIDTH-1 downto 0);

    -- Vector conversion to string
    function vec2str(vec : std_logic_vector) return string is
        variable stmp    : string(1 to vec'length);
        variable counter : integer := 1;
    begin
        for i in vec'reverse_range loop
            stmp(counter) := std_logic'image(vec(i))(2); -- '0' or '1'
            counter := counter + 1;
        end loop;
        return stmp;
    end function;

begin
    -- UUT instance
    UUT : entity work.RegisterFile

        port map(
------------ INPUTS ---------------
            clk_n => clk_n,
            we    => we,
            Addr1 => Addr1,
            Addr2 => Addr2,
            Addr3 => Addr3,
            wd    => wd,
  ------------- OUTPUTS -------------
            RD1   => RD1,
            RD2   => RD2
        );
 
    -- 100 ns period clock
    clk_proc : process
    begin
        clk_n <= '1';
        wait for 50 ns;
        clk_n <= '0';
        wait for 50 ns;
    end process;

    stim_proc : process
    begin
        for i in 0 to num_tests-1 loop
            we    <= test_vector_array(i).we;
            Addr1 <= test_vector_array(i).Addr1;
            Addr2 <= test_vector_array(i).Addr2;
            Addr3 <= test_vector_array(i).Addr3;
            wd    <= test_vector_array(i).wd;

            wait for 100 ns;

            assert (test_vector_array(i).RD1 = RD1)
                report "RD1 mismatch. got " & vec2str(RD1) &
                       " expected " & vec2str(test_vector_array(i).RD1)
                severity error;

            assert (test_vector_array(i).RD2 = RD2)
                report "RD2 mismatch. got " & vec2str(RD2) &
                       " expected " & vec2str(test_vector_array(i).RD2)
                severity error;
        end loop;

        assert false
                report "Testbench Concluded" 
                severity failure;
    end process;

end tb;
