library IEEE;
use IEEE.STD_LOGIC_1164.all;
 
entity mux_2to1 is
 port(
 
     A,B : in STD_LOGIC;
     S: in STD_LOGIC;
     Q: out STD_LOGIC
  );
end mux_2to1;
 
architecture behaviour of mux_2to1 is
begin
process (A,B,S) is
begin
  if (S ='0') then
      Q <= A;
  else
      Q <= B;
  end if;
 
end process;
end behaviour;
