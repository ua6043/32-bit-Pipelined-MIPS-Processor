-------------------------------------------------
--  File:          InstructionFetchTB.vhd
--
--  Entity:        InstructionFetchTB
--  Architecture:  BEHAVIORAL
--  Author:        Jason Blocklove
--  Created:       07/26/19
--  Modified:      Umar Arif
--  VHDL'93
--  Description:   The following is the entity and
--                 architectural description of a
--                 Testbench for Instruction Fetch
--                 Stage
-------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity instr_fetchTB is
end instr_fetchTB;

architecture Behavioral of instr_fetchTB is

    type test_vector is record
        rst : std_logic;
        Instruction	 : std_logic_vector(31 downto 0);
    end record;

    type test_array is array (natural range <>) of test_vector;
    constant test_vector_array : test_array := (
        (rst => '1', Instruction => x"00000000"), -- address 0, reset value
        (rst => '0', Instruction => x"11111111"), -- address 4
        (rst => '0', Instruction => x"22222222"), -- address 8
        (rst => '0', Instruction => x"1f2e3d4c"), -- address 12
        (rst => '1', Instruction => x"00000000"), -- reset again, address 0
        (rst => '0', Instruction => x"11111111"), -- address 4
        (rst => '0', Instruction => x"22222222"), -- address 8
        (rst => '0', Instruction => x"1f2e3d4c"), -- address 12
        (rst => '0', Instruction => x"33333333"), -- address 16
        (rst => '0', Instruction => x"44444444"), -- address 20
        (rst => '0', Instruction => x"55555555"), -- address 24
        (rst => '0', Instruction => x"66666666"), -- address 28
        (rst => '0', Instruction => x"CAFEBABE")  -- address 32
    );
    
    component instr_fetch
      port (
        clk : in std_logic;
        rst : in std_logic;
        Instruction : out std_logic_vector(31 DOWNTO 0)
      );
    end component;
    
    signal rst : std_logic;
    signal clk : std_logic;
    signal instr : std_logic_vector(31 downto 0);
    
    begin
        uut : entity work.instr_fetch
          port map (
            clk => clk,
            rst => rst,
            Instruction => instr
          );
    
        clk_proc : process
            begin
                clk <= '0';
                wait for 50 ns;
                clk <= '1';
                wait for 50 ns;
        end process;
    
        stim_proc : process
        begin
          -- time for everything to reset
          rst <= '1';
          wait until clk='1';
          wait until clk='0';
          assert instr = x"00000000"
              report "Reset check failed: expected addr 0 word (00000000) while rst=1"
              severity error;
        
          rst <= '0';
          wait until clk='1';
          wait until clk='0';
        
            for i in test_vector_array'range loop
                rst <= test_vector_array(i).rst;
                wait until clk='0';
                    assert instr = test_vector_array(i).Instruction
                        report "Mismatch at vector index " & integer'image(i)
                        severity error;
            end loop;
            wait until clk='0';
        
            assert false
                report "Testbench Concluded"
                severity failure;
        end process;
end Behavioral;
