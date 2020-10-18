library IEEE;
use IEEE.std_logic_1164.all;

entity Q1A is
    generic(N :  integer := 32);
    port(i_A1 : in std_logic_vector (N-1 downto 0);
         o_F1 : out std_logic_vector(N-1 downto 0));
end Q1A;

architecture structure of Q1A is
    --Describe components
    component invg
        port(i_A          : in std_logic;
             o_F          : out std_logic);
    end component;


begin

-- We loop through and instantiate and connect N inv modules

G1:for i in 0 to N-1 generate
    not_i : invg
        port map(i_A => i_A1(i),
                o_F => o_F1(i)
        );
end generate;

end structure;
