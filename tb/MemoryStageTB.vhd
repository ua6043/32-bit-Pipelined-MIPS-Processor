-----------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 3/25/2026
-- Design Name: MemoryStageTB
-- Module Name: MemoryStageTB - Behavioral
-- Project Name: Memstage_Wb
-- Target Devices: Basys3
--
-- Description:
--   Self-checking testbench for MemoryStage.
-----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MemoryStageTB is
end MemoryStageTB;

architecture Behavioral of MemoryStageTB is

    constant CLK_PERIOD : time := 40 ns;

    signal clk           : std_logic := '0';
    signal rst           : std_logic := '0';
    signal RegWrite      : std_logic := '0';
    signal MemtoReg      : std_logic := '0';
    signal WriteReg      : std_logic_vector(4 downto 0) := (others => '0');
    signal MemWrite      : std_logic := '0';
    signal ALUResult     : std_logic_vector(31 downto 0) := (others => '0');
    signal WriteData     : std_logic_vector(31 downto 0) := (others => '0');
    signal Switches      : std_logic_vector(15 downto 0) := (others => '0');

    signal RegWriteOut   : std_logic;
    signal MemtoRegOut   : std_logic;
    signal WriteRegOut   : std_logic_vector(4 downto 0);
    signal MemOut        : std_logic_vector(31 downto 0);
    signal ALUResultOut  : std_logic_vector(31 downto 0);
    signal ActiveDigit   : std_logic_vector(3 downto 0);
    signal SevenSegDigit : std_logic_vector(6 downto 0);

begin

    uut: entity work.MemoryStage
        port map (
            clk           => clk,
            rst           => rst,
            RegWrite      => RegWrite,
            MemtoReg      => MemtoReg,
            WriteReg      => WriteReg,
            MemWrite      => MemWrite,
            ALUResult     => ALUResult,
            WriteData     => WriteData,
            Switches      => Switches,
            RegWriteOut   => RegWriteOut,
            MemtoRegOut   => MemtoRegOut,
            WriteRegOut   => WriteRegOut,
            MemOut        => MemOut,
            ALUResultOut  => ALUResultOut,
            ActiveDigit   => ActiveDigit,
            SevenSegDigit => SevenSegDigit
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
        rst       <= '1';
        RegWrite  <= '0';
        MemtoReg  <= '0';
        WriteReg  <= (others => '0');
        MemWrite  <= '0';
        ALUResult <= (others => '0');
        WriteData <= (others => '0');
        Switches  <= (others => '0');

        wait for 2 * CLK_PERIOD;
        rst <= '0';

        wait until falling_edge(clk);

        -- write AAAA5555 to address 0x1B
        RegWrite  <= '1';
        MemtoReg  <= '0';
        WriteReg  <= "00111";
        MemWrite  <= '1';
        ALUResult <= x"0000001B";
        WriteData <= x"AAAA5555";
        wait for 5 ns;

        assert RegWriteOut = '1'
            report "RegWriteOut failed during write to 0x1B"
            severity failure;
        assert MemtoRegOut = '0'
            report "MemtoRegOut failed during write to 0x1B"
            severity failure;
        assert WriteRegOut = "00111"
            report "WriteRegOut failed during write to 0x1B"
            severity failure;
        assert ALUResultOut = x"0000001B"
            report "ALUResultOut failed during write to 0x1B"
            severity failure;

        wait until rising_edge(clk);
        wait for 5 ns;

        wait until falling_edge(clk);

        -- write 5555AAAA to address 0x1C
        RegWrite  <= '1';
        MemtoReg  <= '0';
        WriteReg  <= "01010";
        MemWrite  <= '1';
        ALUResult <= x"0000001C";
        WriteData <= x"5555AAAA";
        wait for 5 ns;

        assert WriteRegOut = "01010"
            report "WriteRegOut failed during write to 0x1C"
            severity failure;
        assert ALUResultOut = x"0000001C"
            report "ALUResultOut failed during write to 0x1C"
            severity failure;

        wait until rising_edge(clk);
        wait for 5 ns;

        wait until falling_edge(clk);

        -- read address 0x1B
        RegWrite  <= '1';
        MemtoReg  <= '1';
        WriteReg  <= "00011";
        MemWrite  <= '0';
        ALUResult <= x"0000001B";
        wait for 5 ns;

        assert RegWriteOut = '1'
            report "RegWriteOut failed during read from 0x1B"
            severity failure;
        assert MemtoRegOut = '1'
            report "MemtoRegOut failed during read from 0x1B"
            severity failure;
        assert WriteRegOut = "00011"
            report "WriteRegOut failed during read from 0x1B"
            severity failure;
        assert ALUResultOut = x"0000001B"
            report "ALUResultOut failed during read from 0x1B"
            severity failure;

        wait until rising_edge(clk);
        wait for 5 ns;

        assert MemOut = x"AAAA5555"
            report "MemOut failed for address 0x1B"
            severity failure;

        wait until falling_edge(clk);

        -- read address 0x1C
        RegWrite  <= '1';
        MemtoReg  <= '1';
        WriteReg  <= "00100";
        MemWrite  <= '0';
        ALUResult <= x"0000001C";

        wait until rising_edge(clk);
        wait for 5 ns;

        assert MemOut = x"5555AAAA"
            report "MemOut failed for address 0x1C"
            severity failure;
        assert WriteRegOut = "00100"
            report "WriteRegOut failed during read from 0x1C"
            severity failure;

        wait until falling_edge(clk);

        -- test switch-mapped read at address 1022
        RegWrite  <= '1';
        MemtoReg  <= '1';
        WriteReg  <= "00101";
        MemWrite  <= '0';
        ALUResult <= x"000003FE";
        Switches  <= x"1111";

        wait until rising_edge(clk);
        wait for 5 ns;

        assert MemOut = x"00001111"
            report "MemOut failed for switch-mapped address 1022"
            severity failure;
        assert ALUResultOut = x"000003FE"
            report "ALUResultOut failed for address 1022"
            severity failure;

        wait until falling_edge(clk);

        -- verify address 1022 is not writable
        RegWrite  <= '1';
        MemtoReg  <= '1';
        WriteReg  <= "00110";
        MemWrite  <= '1';
        ALUResult <= x"000003FE";
        WriteData <= x"DEADBEEF";
        Switches  <= x"2222";

        wait until rising_edge(clk);
        wait for 5 ns;

        assert MemOut = x"00002222"
            report "Address 1022 behaved like normal writable memory through MemoryStage"
            severity failure;

        wait until falling_edge(clk);

        -- write to seven-segment mapped address 1023
        RegWrite  <= '1';
        MemtoReg  <= '0';
        WriteReg  <= "01000";
        MemWrite  <= '1';
        ALUResult <= x"000003FF";
        WriteData <= x"00003333";

        wait until rising_edge(clk);
        wait for 5 ns;

        wait until falling_edge(clk);

        -- verify address 1023 does not read as normal memory
        RegWrite  <= '1';
        MemtoReg  <= '1';
        WriteReg  <= "01001";
        MemWrite  <= '0';
        ALUResult <= x"000003FF";

        wait until rising_edge(clk);
        wait for 5 ns;

        assert MemOut = x"00000000"
            report "Address 1023 should not return normal memory data through MemoryStage"
            severity failure;

        -- check that display outputs are being driven
        assert ActiveDigit /= "UUUU"
            report "ActiveDigit appears undriven"
            severity failure;
        assert SevenSegDigit /= "UUUUUUU"
            report "SevenSegDigit appears undriven"
            severity failure;

        assert false
            report "MemoryStageTB completed successfully."
            severity failure;
    end process;

end Behavioral;