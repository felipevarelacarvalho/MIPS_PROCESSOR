--------------------------------------------------------------------------------------------------------------
--Trevor Rowland
--Muhamed Stilic

--Project 1A: 1-Bit ALU - NOR Component
--------------------------------------------------------------------------------------------------------------

--norg.vhd
-----------------------------------------------------------------------------------------------------------------
--Description: 	This File Contains a Description for a nor gate that takes in two variables
-----------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity norg is
	port(	i_A : in std_logic;
			i_B : in std_logic;
			o_S : out std_logic);
end norg;

architecture behavior of norg is

begin
	o_S <= i_A NOR i_B;
end behavior;