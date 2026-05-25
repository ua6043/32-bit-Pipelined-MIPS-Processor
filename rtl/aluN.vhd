------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 1/15/2026
-- Design Name: aluN
-- Module Name: aluN - structural
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: N - bit Arithmetic Logic Unit
------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.globals.all; -- provides N and M to top level

entity aluN is
    PORT (
            in1  : IN std_logic_vector(N -1 downto 0);
            in2  : IN std_logic_vector(N -1 downto 0);
            control : IN std_logic_vector(3 downto 0);
            out1  : OUT std_logic_vector(N -1 downto 0)
        );
end aluN;

architecture structural of aluN is
-- OR component declaration
    Component orN is
        GENERIC ( N : INTEGER := 32); -- bit width
        PORT (
            A : IN std_logic_vector(N -1 downto 0) ;
            B : IN std_logic_vector(N-1 downto 0);
            Y : OUT std_logic_vector(N -1 downto 0)
        );
    end Component;
-- XOR component declaration
    Component xorN is
        GENERIC ( N : INTEGER := 32); -- bit width
        PORT (
            A : IN std_logic_vector(N -1 downto 0) ;
            B : IN std_logic_vector(N-1 downto 0);
            Y : OUT std_logic_vector(N -1 downto 0)
        );
    end Component;
-- AND component declaration
    Component andN is
        GENERIC ( N : INTEGER := 32); -- bit width
        PORT (
            A : IN std_logic_vector(N -1 downto 0) ;
            B : IN std_logic_vector(N-1 downto 0);
            Y : OUT std_logic_vector(N -1 downto 0)
        );
    end Component;
-- skip shift left component declaration, use entity work.
--   this is done so you can see code with and without components.
    signal sll_result : std_logic_vector(N-1 downto 0);
    signal srl_result : std_logic_vector(N-1 downto 0);
    signal sra_result : std_logic_vector(N-1 downto 0);
    signal xor_result : std_logic_vector(N-1 downto 0);
    signal and_result : std_logic_vector(N-1 downto 0);
    signal or_result  : std_logic_vector(N-1 downto 0);
    signal ripple_carry_fa_result : std_logic_vector(N-1 downto 0);
    signal addsub_ctrl: std_logic;
    signal mult_result : std_logic_vector(N-1 downto 0);
begin

    -- 0 for ADD (0100), 1 for SUB (0101)
    addsub_ctrl <= '1' when control = "0101" else '0';

    -- Instantiate the SLL unit , without component
    sll_comp: entity work.sllN
        generic map ( N => N , M => M )
        port map ( A => in1, SHIFT_AMT => in2(M-1 downto 0), Y => sll_result );
    -- Instantiate the SRL unit , without component
    srl_comp: entity work.srlN
        generic map ( N => N , M => M )
        port map ( A => in1, SHIFT_AMT => in2(M-1 downto 0), Y => srl_result );
    -- Instantiate the SRA unit , without component
    sra_comp: entity work.sraN
        generic map ( N => N , M => M )
        port map ( A => in1, SHIFT_AMT => in2(M-1 downto 0), Y => sra_result );
    -- Instantiate the XOR unit , with component
    xor_comp: entity work.xorN
        generic map ( N => N )
        port map ( A => in1, B => in2, Y => xor_result );
    -- Instantiate the OR unit , with component
    or_comp: entity work.orN
        generic map ( N => N )
        port map ( A => in1, B => in2, Y => or_result );
    -- Instantiate the AND unit , with component
    and_comp: entity work.andN
        generic map ( N => N )
        port map ( A => in1, B => in2, Y => and_result );
    -- Instantiate the RippleCarryFA
    ripplecarryfa_comp: entity work.RippleCarryFA
        generic map ( N => N )
        port map ( A => in1, B => in2, OP => addsub_ctrl, Sum => ripple_carry_fa_result );
    -- Instantiate the Multiplier
    mult_comp: entity work.Multiplier
    generic map ( N => N )
    port map (
        A       => in1((N/2)-1 downto 0),
        B       => in2((N/2)-1 downto 0),
        Product => mult_result
    );
        
    -- Use OP to control which operation to show / perform
    with control select
        out1 <= ripple_carry_fa_result when "0100", -- ADD
             ripple_carry_fa_result when "0101", -- SUB
             mult_result when "0110", -- MULT
             or_result when "1000", -- OR
             and_result when "1010", -- AND
             xor_result when "1011", -- XOR
             sll_result when "1100", -- SLL
             srl_result when "1101", -- SRL
             sra_result when "1110", -- SRA
             (others => '0') when others;
end structural ;