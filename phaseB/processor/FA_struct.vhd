library IEEE;
use IEEE.std_logic_1164.all;

entity FA_struct is
    generic(N : integer :=32);
    port(Cin : in std_logic;
        A, B : in std_logic_vector (N-1 downto 0);
        Cout : out std_logic;
        Sum : out std_logic_vector (N-1 downto 0));
end FA_struct;

architecture structure of FA_struct is
--Describe components
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

    component xorg2
        port(i_A          : in std_logic;
             i_B          : in std_logic;
             o_F          : out std_logic);
      end component;
    
--Signals to save partial values
signal sXOR1 : std_logic_vector(N-1 downto 0);
signal sAND1 : std_logic_vector(N-1 downto 0);
signal sAND2 : std_logic_vector(N-1 downto 0);
signal sCtemp : std_logic_vector(N downto 0) ;

begin

    sCtemp(0) <= Cin;
--Loop through
    G1:for i in 0 to N-1 generate
    --Calculate SUM
        g_XOR1 : xorg2
            port MAP(
            i_A => A(i),
            i_B => B(i),
            o_F => sXOR1(i) 
            );
        
        g_XOR2 : xorg2
            port MAP(
                i_A => sXOR1(i),
                i_B => sCtemp(i),
                o_F => Sum(i)
            );
    --Calculate Cout
        g_AND2 : andg2
        port MAP(
            i_A => A(i),
            i_B => B(i),
            o_F => sAND2(i)
        );

        g_AND1 : andg2
        port MAP(
            i_A => sXOR1(i),
            i_B => sCtemp(i),
            o_F => sAND1(i)
            );

        
        g_OR1 : org2
            port MAP(
                i_A => sAND1(i),
                i_B => sAND2(i),
                o_F => sCtemp(i + 1)
            );

    end generate;
    Cout <= sCtemp(N);

end structure;
