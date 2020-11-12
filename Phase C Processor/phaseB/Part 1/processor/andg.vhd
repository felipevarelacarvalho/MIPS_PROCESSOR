--------------------------------------------------------------------------------------------------------------
--Trevor Rowland
--Muhamed Stilic

--Project 1A: 1-Bit ALU - And Component
--------------------------------------------------------------------------------------------------------------

--andg.vhd
-----------------------------------------------------------------------------------------------------------------
--Description: 	This File Contains a Description for an and gate that takes in two variables
-----------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity andg is
	port(	i_A : in std_logic;
			i_B : in std_logic;
			o_S : out std_logic);
end andg;

architecture behavior of andg is

begin
	o_S <= i_A AND i_B;
end behavior;