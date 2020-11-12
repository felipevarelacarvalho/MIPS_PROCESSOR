--MEM/WB
library IEEE;
use IEEE.std_logic_1164.all;

entity mem_wb is

port(i_CLK	: in std_logic;
     i_RST_MEMWB: in std_logic;
     i_WE_MEMWB : in std_logic;
     i_D_MEMWB  : in std_logic_vector(N-1 downto 0);
     o_Q_MEMWB  : out std_logic_vector(N-1 downto 0));

end mem_web;

architecture structure of mem_wb is

component Register_Nbits is
  generic(N : integer :=32);
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
end component;

begin
mem_wb_register: Register_Nbits
port MAP(
       i_CLK        => i_CLK,     -- Clock input
       i_RST        => i_RST_MEMWB,     -- Reset input
       i_WE         => i_WE_MEMWB,     -- Write enable input
       i_D          => i_D_MEMWB,     -- Data value input
       o_Q          => o_Q_MEMWB);    -- Data value output
end structure;

	