----------------------------------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Design Name: Microprocessor
-- Module Name: Microprocessor - Structural
-- Project Name: pipelined_mips
-- Target Devices: Basys3
--
-- Description:
--   Top-level pipelined MIPS wrapper.
--   Instantiates InstructionFetch, InstructionDecode, ExecuteStage,
--   MemoryStage, and WritebackStage, with registers between stages
--   implemented in one clocked process.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Microprocessor is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        Switches       : in  std_logic_vector(15 downto 0);

        ActiveDigit    : out std_logic_vector(3 downto 0);
        SevenSegDigit  : out std_logic_vector(6 downto 0)

--        ALUResultDebug : out std_logic_vector(31 downto 0);
--        MemOutDebug    : out std_logic_vector(31 downto 0)
    );
end Microprocessor;

architecture Structural of Microprocessor is

    -- Fetch stage output
    signal if_Instruction : std_logic_vector(31 downto 0);

    -- IF/ID register
    signal ifid_Instruction : std_logic_vector(31 downto 0);

    -- Writeback feedback into Decode
    signal wb_Result_s      : std_logic_vector(31 downto 0);
    signal wb_WriteRegOut_s : std_logic_vector(4 downto 0);
    signal wb_RegWriteOut_s : std_logic;

    -- Decode stage outputs
    signal dec_RegWrite   : std_logic;
    signal dec_MemtoReg   : std_logic;
    signal dec_MemWrite   : std_logic;
    signal dec_ALUControl : std_logic_vector(3 downto 0);
    signal dec_ALUSrc     : std_logic;
    signal dec_RegDst     : std_logic;
    signal dec_RD1        : std_logic_vector(31 downto 0);
    signal dec_RD2        : std_logic_vector(31 downto 0);
    signal dec_RtDest     : std_logic_vector(4 downto 0);
    signal dec_RdDest     : std_logic_vector(4 downto 0);
    signal dec_ImmOut     : std_logic_vector(31 downto 0);

    -- ID/EX registers
    signal idex_RegWrite   : std_logic;
    signal idex_MemtoReg   : std_logic;
    signal idex_MemWrite   : std_logic;
    signal idex_ALUControl : std_logic_vector(3 downto 0);
    signal idex_ALUSrc     : std_logic;
    signal idex_RegDst     : std_logic;
    signal idex_RD1        : std_logic_vector(31 downto 0);
    signal idex_RD2        : std_logic_vector(31 downto 0);
    signal idex_RtDest     : std_logic_vector(4 downto 0);
    signal idex_RdDest     : std_logic_vector(4 downto 0);
    signal idex_ImmOut     : std_logic_vector(31 downto 0);

    -- Execute stage outputs
    signal ex_RegWriteOut : std_logic;
    signal ex_MemtoRegOut : std_logic;
    signal ex_MemWriteOut : std_logic;
    signal ex_ALUResult   : std_logic_vector(31 downto 0);
    signal ex_WriteData   : std_logic_vector(31 downto 0);
    signal ex_WriteReg    : std_logic_vector(4 downto 0);

    -- EX/MEM registers
    signal exmem_RegWrite : std_logic;
    signal exmem_MemtoReg : std_logic;
    signal exmem_MemWrite : std_logic;
    signal exmem_ALUResult : std_logic_vector(31 downto 0);
    signal exmem_WriteData : std_logic_vector(31 downto 0);
    signal exmem_WriteReg  : std_logic_vector(4 downto 0);

    -- Memory stage outputs
    signal mem_RegWriteOut  : std_logic;
    signal mem_MemtoRegOut  : std_logic;
    signal mem_WriteRegOut  : std_logic_vector(4 downto 0);
    signal mem_MemOut       : std_logic_vector(31 downto 0);
    signal mem_ALUResultOut : std_logic_vector(31 downto 0);
    signal mem_ActiveDigit  : std_logic_vector(3 downto 0);
    signal mem_SevenSegDigit: std_logic_vector(6 downto 0);

    -- MEM/WB registers
    signal memwb_RegWrite  : std_logic;
    signal memwb_MemtoReg  : std_logic;
    signal memwb_ALUResult : std_logic_vector(31 downto 0);
    signal memwb_ReadData  : std_logic_vector(31 downto 0);
    signal memwb_WriteReg  : std_logic_vector(4 downto 0);
    
    -- extra delay registers to align synchronous memory read with WB control
    signal memd_RegWrite  : std_logic;
    signal memd_MemtoReg  : std_logic;
    signal memd_ALUResult : std_logic_vector(31 downto 0);
    signal memd_WriteReg  : std_logic_vector(4 downto 0);

begin

    -- Instruction Fetch
    FETCH_UUT : entity work.InstructionFetch
        port map (
            clk         => clk,
            rst         => rst,
            Instruction => if_Instruction
        );

    -- Instruction Decode
    DECODE_UUT : entity work.InstructionDecode
        port map (
            clk          => clk,
            Instruction  => ifid_Instruction,
            RegWriteAddr => wb_WriteRegOut_s,
            RegWriteData => wb_Result_s,
            RegWriteEn   => wb_RegWriteOut_s,
            RegWrite     => dec_RegWrite,
            MemtoReg     => dec_MemtoReg,
            MemWrite     => dec_MemWrite,
            ALUControl   => dec_ALUControl,
            ALUSrc       => dec_ALUSrc,
            RegDst       => dec_RegDst,
            RD1          => dec_RD1,
            RD2          => dec_RD2,
            RtDest       => dec_RtDest,
            RdDest       => dec_RdDest,
            ImmOut       => dec_ImmOut
        );

    -- Execute Stage
    EXECUTE_UUT : entity work.ExecuteStage
        port map (
            RegWrite    => idex_RegWrite,
            MemtoReg    => idex_MemtoReg,
            MemWrite    => idex_MemWrite,
            ALUControl  => idex_ALUControl,
            ALUSrc      => idex_ALUSrc,
            RegDst      => idex_RegDst,
            RD1         => idex_RD1,
            RD2         => idex_RD2,
            RtDest      => idex_RtDest,
            RdDest      => idex_RdDest,
            ImmOut      => idex_ImmOut,
            RegWriteOut => ex_RegWriteOut,
            MemtoRegOut => ex_MemtoRegOut,
            MemWriteOut => ex_MemWriteOut,
            ALUResult   => ex_ALUResult,
            WriteData   => ex_WriteData,
            WriteReg    => ex_WriteReg
        );

    -- Memory Stage
    MEMORY_UUT : entity work.MemoryStage
        port map (
            clk           => clk,
            rst           => rst,
            RegWrite      => exmem_RegWrite,
            MemtoReg      => exmem_MemtoReg,
            WriteReg      => exmem_WriteReg,
            MemWrite      => exmem_MemWrite,
            ALUResult     => exmem_ALUResult,
            WriteData     => exmem_WriteData,
            Switches      => Switches,
            RegWriteOut   => mem_RegWriteOut,
            MemtoRegOut   => mem_MemtoRegOut,
            WriteRegOut   => mem_WriteRegOut,
            MemOut        => mem_MemOut,
            ALUResultOut  => mem_ALUResultOut,
            ActiveDigit   => mem_ActiveDigit,
            SevenSegDigit => mem_SevenSegDigit
        );

    -- Writeback Stage
    WRITEBACK_UUT : entity work.WritebackStage
        port map (
            WriteReg    => memwb_WriteReg,
            RegWrite    => memwb_RegWrite,
            MemtoReg    => memwb_MemtoReg,
            ALUResult   => memwb_ALUResult,
            ReadData    => memwb_ReadData,
            Result      => wb_Result_s,
            WriteRegOut => wb_WriteRegOut_s,
            RegWriteOut => wb_RegWriteOut_s
        );

    -- Pipeline registers
    process(clk, rst)
    begin
        if rst = '1' then
            -- IF/ID
            ifid_Instruction <= (others => '0');

            -- ID/EX
            idex_RegWrite   <= '0';
            idex_MemtoReg   <= '0';
            idex_MemWrite   <= '0';
            idex_ALUControl <= (others => '0');
            idex_ALUSrc     <= '0';
            idex_RegDst     <= '0';
            idex_RD1        <= (others => '0');
            idex_RD2        <= (others => '0');
            idex_RtDest     <= (others => '0');
            idex_RdDest     <= (others => '0');
            idex_ImmOut     <= (others => '0');

            -- EX/MEM
            exmem_RegWrite  <= '0';
            exmem_MemtoReg  <= '0';
            exmem_MemWrite  <= '0';
            exmem_ALUResult <= (others => '0');
            exmem_WriteData <= (others => '0');
            exmem_WriteReg  <= (others => '0');
            
            -- extra MEM delay stage
            memd_RegWrite   <= '0';
            memd_MemtoReg   <= '0';
            memd_ALUResult  <= (others => '0');
            memd_WriteReg   <= (others => '0');
        
            -- MEM/WB
            memwb_RegWrite  <= '0';
            memwb_MemtoReg  <= '0';
            memwb_ALUResult <= (others => '0');
            memwb_ReadData  <= (others => '0');
            memwb_WriteReg  <= (others => '0');

        elsif rising_edge(clk) then
            -- IF/ID
            ifid_Instruction <= if_Instruction;

            -- ID/EX
            idex_RegWrite   <= dec_RegWrite;
            idex_MemtoReg   <= dec_MemtoReg;
            idex_MemWrite   <= dec_MemWrite;
            idex_ALUControl <= dec_ALUControl;
            idex_ALUSrc     <= dec_ALUSrc;
            idex_RegDst     <= dec_RegDst;
            idex_RD1        <= dec_RD1;
            idex_RD2        <= dec_RD2;
            idex_RtDest     <= dec_RtDest;
            idex_RdDest     <= dec_RdDest;
            idex_ImmOut     <= dec_ImmOut;

            -- EX/MEM
            exmem_RegWrite  <= ex_RegWriteOut;
            exmem_MemtoReg  <= ex_MemtoRegOut;
            exmem_MemWrite  <= ex_MemWriteOut;
            exmem_ALUResult <= ex_ALUResult;
            exmem_WriteData <= ex_WriteData;
            exmem_WriteReg  <= ex_WriteReg;

            -- MEM/WB
--            memwb_RegWrite  <= mem_RegWriteOut;
--            memwb_MemtoReg  <= mem_MemtoRegOut;
--            memwb_ALUResult <= mem_ALUResultOut;
--            memwb_ReadData  <= mem_MemOut;
--            memwb_WriteReg  <= mem_WriteRegOut;

            -- delaying control/address path by one cycle
            memd_RegWrite   <= mem_RegWriteOut;
            memd_MemtoReg   <= mem_MemtoRegOut;
            memd_ALUResult  <= mem_ALUResultOut;
            memd_WriteReg   <= mem_WriteRegOut;
    
            -- capturing data one cycle later, aligned with delayed control
            memwb_RegWrite  <= memd_RegWrite;
            memwb_MemtoReg  <= memd_MemtoReg;
            memwb_ALUResult <= memd_ALUResult;
            memwb_ReadData  <= mem_MemOut;
            memwb_WriteReg  <= memd_WriteReg;

        end if;
    end process;

    -- Top-level outputs
    ActiveDigit    <= mem_ActiveDigit;
    SevenSegDigit  <= mem_SevenSegDigit;
--    ALUResultDebug <= ex_ALUResult;
--    MemOutDebug    <= mem_MemOut;

end Structural;