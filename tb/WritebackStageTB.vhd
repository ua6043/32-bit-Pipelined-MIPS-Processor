-----------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 3/25/2026
-- Design Name: WritebackStageTB
-- Module Name: WritebackStageTB - Behavioral
-- Project Name: Memstage_Wb
-- Target Devices: Basys3
--
-- Description:
--   Self-checking testbench for WritebackStage.
-----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity WritebackStageTB is
end WritebackStageTB;

architecture Behavioral of WritebackStageTB is

    signal WriteReg    : std_logic_vector(4 downto 0) := (others => '0');
    signal RegWrite    : std_logic := '0';
    signal MemtoReg    : std_logic := '0';
    signal ALUResult   : std_logic_vector(31 downto 0) := (others => '0');
    signal ReadData    : std_logic_vector(31 downto 0) := (others => '0');

    signal Result      : std_logic_vector(31 downto 0);
    signal WriteRegOut : std_logic_vector(4 downto 0);
    signal RegWriteOut : std_logic;

begin

    uut: entity work.WritebackStage
        port map (
            WriteReg    => WriteReg,
            RegWrite    => RegWrite,
            MemtoReg    => MemtoReg,
            ALUResult   => ALUResult,
            ReadData    => ReadData,
            Result      => Result,
            WriteRegOut => WriteRegOut,
            RegWriteOut => RegWriteOut
        );

    stim_proc : process
    begin
        -- initial zero case
        WriteReg  <= "00000";
        RegWrite  <= '0';
        MemtoReg  <= '0';
        ALUResult <= x"00000000";
        ReadData  <= x"00000000";
        wait for 20 ns;

        assert Result = x"00000000"
            report "Case 1 failed: Result should be 00000000"
            severity failure;
        assert WriteRegOut = "00000"
            report "Case 1 failed: WriteRegOut should be 00000"
            severity failure;
        assert RegWriteOut = '0'
            report "Case 1 failed: RegWriteOut should be 0"
            severity failure;

        -- MemtoReg = 0, select ALUResult
        WriteReg  <= "00101";
        RegWrite  <= '1';
        MemtoReg  <= '0';
        ALUResult <= x"AAAA5555";
        ReadData  <= x"12345678";
        wait for 20 ns;

        assert Result = x"AAAA5555"
            report "Case 2 failed: Result should select ALUResult"
            severity failure;
        assert WriteRegOut = "00101"
            report "Case 2 failed: WriteRegOut should be 00101"
            severity failure;
        assert RegWriteOut = '1'
            report "Case 2 failed: RegWriteOut should be 1"
            severity failure;

        -- MemtoReg = 1, select ReadData
        WriteReg  <= "01010";
        RegWrite  <= '1';
        MemtoReg  <= '1';
        ALUResult <= x"AAAA5555";
        ReadData  <= x"5555AAAA";
        wait for 20 ns;

        assert Result = x"5555AAAA"
            report "Case 3 failed: Result should select ReadData"
            severity failure;
        assert WriteRegOut = "01010"
            report "Case 3 failed: WriteRegOut should be 01010"
            severity failure;
        assert RegWriteOut = '1'
            report "Case 3 failed: RegWriteOut should be 1"
            severity failure;

        -- RegWrite = 0 passthrough
        WriteReg  <= "11111";
        RegWrite  <= '0';
        MemtoReg  <= '0';
        ALUResult <= x"DEADBEEF";
        ReadData  <= x"00000000";
        wait for 20 ns;

        assert Result = x"DEADBEEF"
            report "Case 4 failed: Result should still select ALUResult"
            severity failure;
        assert WriteRegOut = "11111"
            report "Case 4 failed: WriteRegOut should be 11111"
            severity failure;
        assert RegWriteOut = '0'
            report "Case 4 failed: RegWriteOut should be 0"
            severity failure;

        -- extreme values with MemtoReg = 1
        WriteReg  <= "00001";
        RegWrite  <= '1';
        MemtoReg  <= '1';
        ALUResult <= x"FFFFFFFF";
        ReadData  <= x"00000000";
        wait for 20 ns;

        assert Result = x"00000000"
            report "Case 5 failed: Result should select ReadData = 00000000"
            severity failure;
        assert WriteRegOut = "00001"
            report "Case 5 failed: WriteRegOut should be 00001"
            severity failure;
        assert RegWriteOut = '1'
            report "Case 5 failed: RegWriteOut should be 1"
            severity failure;

        -- different pattern with MemtoReg = 0
        WriteReg  <= "10101";
        RegWrite  <= '1';
        MemtoReg  <= '0';
        ALUResult <= x"12345678";
        ReadData  <= x"87654321";
        wait for 20 ns;

        assert Result = x"12345678"
            report "Case 6 failed: Result should select ALUResult = 12345678"
            severity failure;
        assert WriteRegOut = "10101"
            report "Case 6 failed: WriteRegOut should be 10101"
            severity failure;
        assert RegWriteOut = '1'
            report "Case 6 failed: RegWriteOut should be 1"
            severity failure;

        -- change only WriteReg
        WriteReg  <= "01110";
        RegWrite  <= '1';
        MemtoReg  <= '0';
        ALUResult <= x"12345678";
        ReadData  <= x"87654321";
        wait for 20 ns;

        assert Result = x"12345678"
            report "Case 7 failed: Result should remain 12345678"
            severity failure;
        assert WriteRegOut = "01110"
            report "Case 7 failed: WriteRegOut should update to 01110"
            severity failure;
        assert RegWriteOut = '1'
            report "Case 7 failed: RegWriteOut should remain 1"
            severity failure;

        -- change only RegWrite
        WriteReg  <= "01110";
        RegWrite  <= '0';
        MemtoReg  <= '1';
        ALUResult <= x"11111111";
        ReadData  <= x"22222222";
        wait for 20 ns;

        assert Result = x"22222222"
            report "Case 8 failed: Result should select ReadData = 22222222"
            severity failure;
        assert WriteRegOut = "01110"
            report "Case 8 failed: WriteRegOut should remain 01110"
            severity failure;
        assert RegWriteOut = '0'
            report "Case 8 failed: RegWriteOut should update to 0"
            severity failure;

        assert false
            report "WritebackStageTB completed successfully."
            severity failure;
    end process;

end Behavioral;