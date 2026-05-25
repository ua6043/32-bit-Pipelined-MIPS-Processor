library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ExecuteStageTB is
end ExecuteStageTB;

architecture tb of ExecuteStageTB is

component executeStage is
    Port (
        RegWrite   : in  std_logic;
        MemtoReg   : in  std_logic;
        MemWrite   : in  std_logic;
        ALUControl : in  std_logic_vector(3 downto 0);
        ALUSrc     : in  std_logic;
        RegDst     : in  std_logic;
        RD1        : in  std_logic_vector(31 downto 0);
        RD2        : in  std_logic_vector(31 downto 0);
        RtDest     : in  std_logic_vector(4 downto 0);
        RdDest     : in  std_logic_vector(4 downto 0);
        ImmOut     : in  std_logic_vector(31 downto 0);

        RegWriteOut : out std_logic;
        MemtoRegOut : out std_logic;
        MemWriteOut : out std_logic;
        ALUResult   : out std_logic_vector(31 downto 0);
        WriteData   : out std_logic_vector(31 downto 0);
        WriteReg    : out std_logic_vector(4 downto 0)
    );
end component;

signal RegWrite   : std_logic;
signal MemtoReg   : std_logic;
signal MemWrite   : std_logic;
signal ALUControl : std_logic_vector(3 downto 0);
signal ALUSrc     : std_logic;
signal RegDst     : std_logic;
signal RD1        : std_logic_vector(31 downto 0);
signal RD2        : std_logic_vector(31 downto 0);
signal RtDest     : std_logic_vector(4 downto 0);
signal RdDest     : std_logic_vector(4 downto 0);
signal ImmOut     : std_logic_vector(31 downto 0);

signal RegWriteOut : std_logic;
signal MemtoRegOut : std_logic;
signal MemWriteOut : std_logic;
signal ALUResult   : std_logic_vector(31 downto 0);
signal WriteData   : std_logic_vector(31 downto 0);
signal WriteReg    : std_logic_vector(4 downto 0);

type execute_tests is record
    RegWrite   : std_logic;
    MemtoReg   : std_logic;
    MemWrite   : std_logic;
    ALUControl : std_logic_vector(3 downto 0);
    ALUSrc     : std_logic;
    RegDst     : std_logic;
    RD1        : std_logic_vector(31 downto 0);
    RD2        : std_logic_vector(31 downto 0);
    RtDest     : std_logic_vector(4 downto 0);
    RdDest     : std_logic_vector(4 downto 0);
    ImmOut     : std_logic_vector(31 downto 0);

    RegWriteOut : std_logic;
    MemtoRegOut : std_logic;
    MemWriteOut : std_logic;
    ALUResult   : std_logic_vector(31 downto 0);
    WriteData   : std_logic_vector(31 downto 0);
    WriteReg    : std_logic_vector(4 downto 0);
end record;

type test_array is array (natural range <>) of execute_tests;

constant tests : test_array :=(
    -- ADD, uses immediate path and RtDest
    (
        RegWrite => '1', MemtoReg => '0', MemWrite => '0',
        ALUControl => "0100", ALUSrc => '1', RegDst => '0',
        RD1 => x"00000005", RD2 => x"DEADBEEF", RtDest => "00101", RdDest => "01010", ImmOut => x"00000003",
        RegWriteOut => '1', MemtoRegOut => '0', MemWriteOut => '0',
        ALUResult => x"00000008", WriteData => x"DEADBEEF", WriteReg => "00101"
    ),

    -- SUB, uses register path and RdDest
    (
        RegWrite => '1', MemtoReg => '0', MemWrite => '0',
        ALUControl => "0101", ALUSrc => '0', RegDst => '1',
        RD1 => x"00000009", RD2 => x"00000004", RtDest => "00011", RdDest => "01011", ImmOut => x"00000000",
        RegWriteOut => '1', MemtoRegOut => '0', MemWriteOut => '0',
        ALUResult => x"00000005", WriteData => x"00000004", WriteReg => "01011"
    ),

    -- OR
    (
        RegWrite => '1', MemtoReg => '1', MemWrite => '0',
        ALUControl => "1000", ALUSrc => '0', RegDst => '1',
        RD1 => x"0F0F0000", RD2 => x"0000F0F0", RtDest => "00110", RdDest => "01100", ImmOut => x"00000000",
        RegWriteOut => '1', MemtoRegOut => '1', MemWriteOut => '0',
        ALUResult => x"0F0FF0F0", WriteData => x"0000F0F0", WriteReg => "01100"
    ),

    -- AND
    (
        RegWrite => '0', MemtoReg => '0', MemWrite => '1',
        ALUControl => "1010", ALUSrc => '0', RegDst => '0',
        RD1 => x"FF00FF00", RD2 => x"0F0F0F0F", RtDest => "00111", RdDest => "01101", ImmOut => x"00000000",
        RegWriteOut => '0', MemtoRegOut => '0', MemWriteOut => '1',
        ALUResult => x"0F000F00", WriteData => x"0F0F0F0F", WriteReg => "00111"
    ),

    -- XOR
    (
        RegWrite => '1', MemtoReg => '0', MemWrite => '0',
        ALUControl => "1011", ALUSrc => '0', RegDst => '1',
        RD1 => x"12345678", RD2 => x"FFFF0000", RtDest => "01000", RdDest => "01110", ImmOut => x"00000000",
        RegWriteOut => '1', MemtoRegOut => '0', MemWriteOut => '0',
        ALUResult => x"EDCB5678", WriteData => x"FFFF0000", WriteReg => "01110"
    ),

    -- SLL
    (
        RegWrite => '1', MemtoReg => '0', MemWrite => '0',
        ALUControl => "1100", ALUSrc => '0', RegDst => '1',
        RD1 => x"00000003", RD2 => x"00000002", RtDest => "01001", RdDest => "01111", ImmOut => x"00000000",
        RegWriteOut => '1', MemtoRegOut => '0', MemWriteOut => '0',
        ALUResult => x"0000000C", WriteData => x"00000002", WriteReg => "01111"
    ),

    -- SRL
    (
        RegWrite => '1', MemtoReg => '0', MemWrite => '0',
        ALUControl => "1101", ALUSrc => '0', RegDst => '1',
        RD1 => x"80000000", RD2 => x"00000001", RtDest => "01010", RdDest => "10000", ImmOut => x"00000000",
        RegWriteOut => '1', MemtoRegOut => '0', MemWriteOut => '0',
        ALUResult => x"40000000", WriteData => x"00000001", WriteReg => "10000"
    ),

    -- SRA
    (
        RegWrite => '1', MemtoReg => '0', MemWrite => '0',
        ALUControl => "1110", ALUSrc => '0', RegDst => '1',
        RD1 => x"F0000000", RD2 => x"00000004", RtDest => "01011", RdDest => "10001", ImmOut => x"00000000",
        RegWriteOut => '1', MemtoRegOut => '0', MemWriteOut => '0',
        ALUResult => x"FF000000", WriteData => x"00000004", WriteReg => "10001"
    ),
    
    -- MULTU
    (
        RegWrite => '1', MemtoReg => '0', MemWrite => '0',
        ALUControl => "0110", ALUSrc => '0', RegDst => '1',
        RD1 => x"00000003", RD2 => x"00000004", RtDest => "01100", RdDest => "10010", ImmOut => x"00000000",
        RegWriteOut => '1', MemtoRegOut => '0', MemWriteOut => '0',
        ALUResult => x"0000000C", WriteData => x"00000004", WriteReg => "10010"
    )
);

begin

    uut : executeStage
        port map (
            RegWrite    => RegWrite,
            MemtoReg    => MemtoReg,
            MemWrite    => MemWrite,
            ALUControl  => ALUControl,
            ALUSrc      => ALUSrc,
            RegDst      => RegDst,
            RD1         => RD1,
            RD2         => RD2,
            RtDest      => RtDest,
            RdDest      => RdDest,
            ImmOut      => ImmOut,
            RegWriteOut => RegWriteOut,
            MemtoRegOut => MemtoRegOut,
            MemWriteOut => MemWriteOut,
            ALUResult   => ALUResult,
            WriteData   => WriteData,
            WriteReg    => WriteReg
        );

    stim_proc : process
    begin
        for i in tests'range loop
            RegWrite   <= tests(i).RegWrite;
            MemtoReg   <= tests(i).MemtoReg;
            MemWrite   <= tests(i).MemWrite;
            ALUControl <= tests(i).ALUControl;
            ALUSrc     <= tests(i).ALUSrc;
            RegDst     <= tests(i).RegDst;
            RD1        <= tests(i).RD1;
            RD2        <= tests(i).RD2;
            RtDest     <= tests(i).RtDest;
            RdDest     <= tests(i).RdDest;
            ImmOut     <= tests(i).ImmOut;

            wait for 100 ns;

            assert (RegWriteOut = tests(i).RegWriteOut)
                report "RegWriteOut failed at test index " & integer'image(i)
                severity failure;

            assert (MemtoRegOut = tests(i).MemtoRegOut)
                report "MemtoRegOut failed at test index " & integer'image(i)
                severity failure;

            assert (MemWriteOut = tests(i).MemWriteOut)
                report "MemWriteOut failed at test index " & integer'image(i)
                severity failure;

            assert (ALUResult = tests(i).ALUResult)
                report "ALUResult failed at test index " & integer'image(i)
                severity failure;

            assert (WriteData = tests(i).WriteData)
                report "WriteData failed at test index " & integer'image(i)
                severity failure;

            assert (WriteReg = tests(i).WriteReg)
                report "WriteReg failed at test index " & integer'image(i)
                severity failure;

            wait for 100 ns;
        end loop;

        assert false
            report "Testbench Concluded."
            severity failure;
    end process;

end tb;