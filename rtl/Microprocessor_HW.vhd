library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Microprocessor_HW is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        Switches      : in  std_logic_vector(15 downto 0);
        ActiveDigit   : out std_logic_vector(3 downto 0);
        SevenSegDigit : out std_logic_vector(6 downto 0)
    );
end Microprocessor_HW;

architecture Structural of Microprocessor_HW is

    signal clk_slow : std_logic;

    component clk_wiz_0
        port (
            clk_out1 : out std_logic;
            reset    : in  std_logic;
            clk_in1  : in  std_logic
        );
    end component;

begin

    CLKGEN_UUT : clk_wiz_0
        port map (
            clk_out1 => clk_slow,
            reset    => rst,
            clk_in1  => clk
        );

    CPU_UUT : entity work.Microprocessor
        port map (
            clk           => clk_slow,
            rst           => rst,
            Switches      => Switches,
            ActiveDigit   => ActiveDigit,
            SevenSegDigit => SevenSegDigit
        );

end Structural;