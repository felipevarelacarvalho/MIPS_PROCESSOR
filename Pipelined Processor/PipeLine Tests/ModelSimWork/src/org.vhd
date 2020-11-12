--------------------------------------------------------------------------------------------------------------
--Trevor Rowland
--Muhamed Stilic

--Project 1A: 1-Bit ALU - OR Component
--------------------------------------------------------------------------------------------------------------

--org.vhd
-----------------------------------------------------------------------------------------------------------------
--Description: 	This File Contains a Description for an or gate that takes in two variables
-----------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity org is
	port(	i_A : in std_logic;
			i_B : in std_logic;
			o_S : out std_logic);
end org;

architecture behavior of org is

begin
	o_S <= i_A OR i_B;
end behavior;