--------------------------------------------------------------------------------------------------------------
--Trevor Rowland
--Muhamed Stilic

--Project 1A: 1-Bit ALU - Nand Component
--------------------------------------------------------------------------------------------------------------

--nandg.vhd
-----------------------------------------------------------------------------------------------------------------
--Description: 	This File Contains a Description for a nand gate that takes in two variables
-----------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity nandg is
	port(	i_A : in std_logic;
			i_B : in std_logic;
			o_S : out std_logic);
end nandg;

architecture behavior of nandg is

begin
	o_S <= i_A NAND i_B;
end behavior;