library ieee ;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mux32to1 is
    port(
    d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20,
    d21,d22,d23,d24,d25,d26,d27,d28,d29,d30,d31  : in  std_logic_vector(31 downto 0); --32 bit bus ionputs
    sel_in  : in  std_logic_vector(4 downto 0); --5 bit select line
    m_out : out std_logic_vector(31 downto 0)); --32 bit output
end mux32to1;

architecture mixed of mux32to1 is

type t_array_mux is array (31 downto 0) of std_logic_vector(31 downto 0);
signal array_mux  : t_array_mux;

begin
  array_mux(0)  <= d0;
  array_mux(1)  <= d1;
  array_mux(2)  <= d2;
  array_mux(3)  <= d3;
  array_mux(4)  <= d4;
  array_mux(5)  <= d5;
  array_mux(6)  <= d6;
  array_mux(7)  <= d7;
  array_mux(8)  <= d8;
  array_mux(9)  <= d9;
  array_mux(10)  <= d10;
  array_mux(11)  <= d11;
  array_mux(12)  <= d12;
  array_mux(13)  <= d13;
  array_mux(14)  <= d14;
  array_mux(15)  <= d15;
  array_mux(16)  <= d16;
  array_mux(17)  <= d17;
  array_mux(18)  <= d18;
  array_mux(19)  <= d19;
  array_mux(20)  <= d20;
  array_mux(21)  <= d21;
  array_mux(22)  <= d22;
  array_mux(23)  <= d23;
  array_mux(24)  <= d24;
  array_mux(25)  <= d25;
  array_mux(26)  <= d26;
  array_mux(27)  <= d27;
  array_mux(28)  <= d28;
  array_mux(29)  <= d29;
  array_mux(30)  <= d30;
  array_mux(31)  <= d31;

  m_out <= array_mux(to_integer(unsigned(sel_in)));
  
end mixed;