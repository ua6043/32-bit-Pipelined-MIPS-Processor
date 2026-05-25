-----------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 3/23/2026
-- Design Name: DataMemoryTB
-- Module Name: DataMemoryTB - Behavioral
-- Project Name: Memstage_Wb
-- Target Devices: Basys3
--
-- Description: 
--   Self-checking testbench for DataMemory.
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemoryTB is
end DataMemoryTB;

architecture Behavioral of DataMemoryTB is

    constant WIDTH      : integer := 32;
    constant ADDR_SPACE : integer := 10;
    constant CLK_PERIOD : time := 40 ns;

    signal clk       : std_logic := '0';
    signal w_en      : std_logic := '0';
    signal addr      : std_logic_vector(ADDR_SPACE - 1 downto 0) := (others => '0');
    signal d_in      : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
    signal switches  : std_logic_vector(15 downto 0) := (others => '0');
    signal d_out     : std_logic_vector(WIDTH - 1 downto 0);
    signal seven_seg : std_logic_vector(15 downto 0);

begin

    uut: entity work.DataMemory
        generic map (
            WIDTH      => WIDTH,
            ADDR_SPACE => ADDR_SPACE
        )
        port map (
            clk       => clk,
            w_en      => w_en,
            addr      => addr,
            d_in      => d_in,
            switches  => switches,
            d_out     => d_out,
            seven_seg => seven_seg
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    stim_proc : process
    begin
        w_en     <= '0';
        addr     <= (others => '0');
        d_in     <= (others => '0');
        switches <= (others => '0');

        wait until falling_edge(clk);

        -- write AAAA5555 to 0x1B
        w_en <= '1';
        addr <= std_logic_vector(to_unsigned(16#1B#, ADDR_SPACE));
        d_in <= x"AAAA5555";

        wait until falling_edge(clk);

        -- write 5555AAAA to 0x1C
        addr <= std_logic_vector(to_unsigned(16#1C#, ADDR_SPACE));
        d_in <= x"5555AAAA";

        wait until falling_edge(clk);

        -- read 0x1B
        w_en <= '0';
        addr <= std_logic_vector(to_unsigned(16#1B#, ADDR_SPACE));

        wait until rising_edge(clk);
        wait for 1 ns;
        assert d_out = x"AAAA5555"
            report "Readback failed at address 0x1B"
            severity failure;

        wait until falling_edge(clk);

        -- read 0x1C
        addr <= std_logic_vector(to_unsigned(16#1C#, ADDR_SPACE));

        wait until rising_edge(clk);
        wait for 1 ns;
        assert d_out = x"5555AAAA"
            report "Readback failed at address 0x1C"
            severity failure;

        wait until falling_edge(clk);

        -- test switches at 1022
        switches <= x"1111";
        addr <= std_logic_vector(to_unsigned(1022, ADDR_SPACE));

        wait until rising_edge(clk);
        wait for 1 ns;
        assert d_out = x"00001111"
            report "Switch read failed at address 1022"
            severity failure;

        wait until falling_edge(clk);

        -- test seven segment write at 1023
        w_en <= '1';
        addr <= std_logic_vector(to_unsigned(1023, ADDR_SPACE));
        d_in <= x"00003333";

        wait until rising_edge(clk);
        wait for 1 ns;
        assert seven_seg = x"3333"
            report "Seven segment write failed at address 1023"
            severity failure;
        wait until falling_edge(clk);

        -- overwrite an existing normal memory location
        w_en <= '1';
        addr <= std_logic_vector(to_unsigned(16#1B#, ADDR_SPACE));
        d_in <= x"12345678";

        wait until falling_edge(clk);

        w_en <= '0';
        addr <= std_logic_vector(to_unsigned(16#1B#, ADDR_SPACE));

        wait until rising_edge(clk);
        wait for 1 ns;
        assert d_out = x"12345678"
            report "Overwrite failed at address 0x1B"
            severity failure;

        wait until falling_edge(clk);

        -- verify no write occurs when w_en = 0
        w_en <= '0';
        addr <= std_logic_vector(to_unsigned(16#1B#, ADDR_SPACE));
        d_in <= x"87654321";

        wait until falling_edge(clk);
        addr <= std_logic_vector(to_unsigned(16#1B#, ADDR_SPACE));

        wait until rising_edge(clk);
        wait for 1 ns;
        assert d_out = x"12345678"
            report "Memory changed even though w_en = 0 at address 0x1B"
            severity failure;

        wait until falling_edge(clk);

        -- verify address 1022 is not writable
        w_en <= '1';
        switches <= x"2222";
        addr <= std_logic_vector(to_unsigned(1022, ADDR_SPACE));
        d_in <= x"DEADBEEF";

        wait until rising_edge(clk);
        wait for 1 ns;
        assert d_out = x"00002222"
            report "Address 1022 behaved like normal writable memory"
            severity failure;

        wait until falling_edge(clk);

        -- verify address 1023 is not read like normal memory
        w_en <= '0';
        addr <= std_logic_vector(to_unsigned(1023, ADDR_SPACE));

        wait until rising_edge(clk);
        wait for 1 ns;
        assert d_out = x"00000000"
            report "Address 1023 should not return normal memory data"
            severity failure;

        assert seven_seg = x"3333"
            report "Seven segment output changed unexpectedly"
            severity failure;
        assert false
            report "DataMemoryTB completed successfully." 
            severity failure;
    end process;

end Behavioral;