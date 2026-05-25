-----------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 3/25/2026
-- Design Name: MemoryStage
-- Module Name: MemoryStage - Structural
-- Project Name: Memstage_Wb
-- Target Devices: Basys3
--
-- Description:
--   Memory stage for the pipelined MIPS datapath.
--   Instantiates DataMemory and the provided seven-
--   segment controller. Passes required control/data
--   signals through to the next stage.
-----------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MemoryStage is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        RegWrite     : in  std_logic;
        MemtoReg     : in  std_logic;
        WriteReg     : in  std_logic_vector(4 downto 0);
        MemWrite     : in  std_logic;
        ALUResult    : in  std_logic_vector(31 downto 0);
        WriteData    : in  std_logic_vector(31 downto 0);
        Switches     : in  std_logic_vector(15 downto 0);

        RegWriteOut  : out std_logic;
        MemtoRegOut  : out std_logic;
        WriteRegOut  : out std_logic_vector(4 downto 0);
        MemOut       : out std_logic_vector(31 downto 0);
        ALUResultOut : out std_logic_vector(31 downto 0);
        ActiveDigit  : out std_logic_vector(3 downto 0);
        SevenSegDigit: out std_logic_vector(6 downto 0)
    );
end MemoryStage;

architecture Structural of MemoryStage is

    signal seven_seg_raw : std_logic_vector(15 downto 0);

    component DataMemory is
        generic (
            WIDTH      : integer := 32;
            ADDR_SPACE : integer := 10
        );
        port (
            clk       : in  std_logic;
            w_en      : in  std_logic;
            addr      : in  std_logic_vector(ADDR_SPACE - 1 downto 0);
            d_in      : in  std_logic_vector(WIDTH - 1 downto 0);
            switches  : in  std_logic_vector(15 downto 0);
            d_out     : out std_logic_vector(WIDTH - 1 downto 0);
            seven_seg : out std_logic_vector(15 downto 0)
        );
    end component;

    component SevenSegController is
        port (
            clk             : in  std_logic;
            rst             : in  std_logic;
            display_number  : in  std_logic_vector(15 downto 0);
            active_segment  : out std_logic_vector(3 downto 0);
            led_out         : out std_logic_vector(6 downto 0)
        );
    end component;

begin

    data_mem_0 : DataMemory
        generic map (
            WIDTH      => 32,
            ADDR_SPACE => 10
        )
        port map (
            clk       => clk,
            w_en      => MemWrite,
            addr      => ALUResult(9 downto 0),
            d_in      => WriteData,
            switches  => Switches,
            d_out     => MemOut,
            seven_seg => seven_seg_raw
        );

    seven_seg_ctrl_0 : SevenSegController
        port map (
            clk             => clk,
            rst             => rst,
            display_number  => seven_seg_raw,
            active_segment  => ActiveDigit,
            led_out         => SevenSegDigit
        );

    RegWriteOut  <= RegWrite;
    MemtoRegOut  <= MemtoReg;
    WriteRegOut  <= WriteReg;
    ALUResultOut <= ALUResult;

end Structural;