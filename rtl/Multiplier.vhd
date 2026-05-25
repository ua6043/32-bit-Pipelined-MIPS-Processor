------------------------------------------------------
-- Company: Rochester Institute of Technology (RIT)
-- Engineer: UMAR ARIF (ua6043@rit.edu)
--
-- Create Date: 3/23/2026
-- Design Name: Multiplier
-- Module Name: Multiplier - structural
-- Project Name: execute
-- Target Devices: Basys3
--
-- Description: Generic unsigned ripple-carry multiplier.
--              Inputs A and B are N/2 bits each.
--              Output Product is N bits.
--              Partial products are generated with AND logic
--              and added sequentially using RippleCarryFA.
------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Multiplier is
    Generic ( N : integer := 32 );
    Port (
        A       : in  std_logic_vector((N/2)-1 downto 0);
        B       : in  std_logic_vector((N/2)-1 downto 0);
        Product : out std_logic_vector(N-1 downto 0)
    );
end Multiplier;

architecture structural of Multiplier is

    constant HALF_N : integer := N/2;

    type row_array is array (0 to HALF_N-1) of std_logic_vector(N-1 downto 0);

    signal partial_products : row_array;
    signal sums             : row_array;

begin

    -- Build each shifted partial-product row
    PARTIAL_ROWS : for i in 0 to HALF_N-1 generate
        PARTIAL_BITS : for j in 0 to HALF_N-1 generate
            partial_products(i)(i + j) <= A(j) and B(i);
        end generate PARTIAL_BITS;

        ZERO_LOW : if i > 0 generate
            partial_products(i)(i-1 downto 0) <= (others => '0');
        end generate ZERO_LOW;

        ZERO_HIGH : if (i + HALF_N) <= (N-1) generate
            partial_products(i)(N-1 downto i + HALF_N) <= (others => '0');
        end generate ZERO_HIGH;
    end generate PARTIAL_ROWS;

    -- First row goes straight into the running sum
    sums(0) <= partial_products(0);

    -- Add remaining rows using ripple-carry adders
    ADDER_CHAIN : for i in 1 to HALF_N-1 generate
        RC_ADD : entity work.RippleCarryFA
            generic map ( N => N )
            port map (
                A    => sums(i-1),
                B    => partial_products(i),
                OP => '0',
                Sum  => sums(i)
            );
    end generate ADDER_CHAIN;

    Product <= sums(HALF_N-1);

end structural;