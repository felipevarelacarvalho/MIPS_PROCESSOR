library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--This is supposed to be a 16 to 32 bit sign extender

entity extender is
    port(
        signal_extend : in std_logic;
        d_in : in std_logic_vector(15 downto 0);
        d_out : out std_logic_vector(31 downto 0)
    );
end extender;


architecture behavioural of extender is
    begin
        d_out <=    X"0000" & d_in when signal_extend = '0' else
                    X"ffff" & d_in when d_in(15) = '1' else 
                    X"0000" & d_in;
    end behavioural;

