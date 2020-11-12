library IEEE;
use IEEE.std_logic_1164.all;

entity MUX21_structN is
    generic(N : integer :=32);
    port(A,B : in std_logic_vector (N-1 downto 0);
        S : in std_logic;
        Q : out std_logic_vector(N-1 downto 0));
end MUX21_structN;

architecture structure of MUX21_structN is
--Describe components
    component invg
        port(i_A          : in std_logic;
            o_F          : out std_logic);
    end component;

    component org2
        port(i_A          : in std_logic;
            i_B          : in std_logic;
            o_F          : out std_logic);
    end component;

    component andg2
        port(i_A  : in std_logic;
            i_B  : in std_logic;
            o_F  : out std_logic);
    end component;
    
--Signals to save partial values
signal sAND1 : std_logic_vector(N-1 downto 0);
signal sAND2 : std_logic_vector(N-1 downto 0);
signal sNOT1 : std_logic_vector(N-1 downto 0);

begin

--Loop through and find the overall result of the MUX
    G1:for i in 0 to N-1 generate
        g_AND1 : andg2
            port MAP(
            i_A => A(i),
            i_B => S,
            o_F => sAND1(i) 
            );
        
        g_NOT1 : invg
            port MAP(
                i_A => S,
                o_F => sNOT1(i)
            );

        g_AND2 : andg2
            port MAP(
            i_A => B(i),
            i_B => sNOT1(i),
            o_F => sAND2(i)
            );

        g_OR1 : org2
            port MAP(
                i_A => sAND1(i),
                i_B => sAND2(i),
                o_F => Q(i)
            );
    end generate;
end structure;
