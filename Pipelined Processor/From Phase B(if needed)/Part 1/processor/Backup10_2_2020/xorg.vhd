--------------------------------------------------------------------------------------------------------------
--Trevor Rowland
--Muhamed Stilic

--Project 1A: 1-Bit ALU - XOR Component
--------------------------------------------------------------------------------------------------------------

--xorg.vhd
-----------------------------------------------------------------------------------------------------------------
--Description: 	This File Contains a Description for an xor gate that takes in two variables
-----------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity xorg is
	port(	i_A : in std_logic;
			i_B : in std_logic;
			o_S : out std_logic);
end xorg;

architecture behavior of xorg is

begin
	o_S <= i_A XOR i_B;
end behavior;