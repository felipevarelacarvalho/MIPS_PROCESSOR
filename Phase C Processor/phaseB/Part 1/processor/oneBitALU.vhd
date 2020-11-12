--One Bit ALU with the following operations and select lines:
--Add:000
--Sub:001
--SetLessThan:010
--and:011
--or:100
--xor:101
--nand:110
--nor:111
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity oneBitALU is

	port(
		iA				: in std_logic;
		iB				: in std_logic;
		iC				: in std_logic;
		less            : in std_logic;
		s1				: in std_logic;
		s2				: in std_logic;
		s3				: in std_logic;
		oC				: out std_logic;		
		oOut				: out std_logic);

end oneBitALU;

architecture dataflow of oneBitALU is

	
signal s_B_in :std_logic;
signal slt_out : std_logic;
signal and_out : std_logic;
signal or_out : std_logic;
signal xor_out : std_logic;
signal nand_out : std_logic;
signal nor_out : std_logic;
signal b_invert : std_logic;
signal add_out : std_logic;


	
begin
	--Select signal that defines if operation will need B invert
	b_invert <= '1' when s1= '0' and s2 = '0' and s3 = '1' else  
		'1' when s1= '0' and s2 = '1' and s3 = '0' else
		'0';

	--Inverts B if b_invert ='1'
	s_B_in <= iB when b_invert = '0' else 
		not iB when b_invert ='1';
	
	add_out <= iA xor s_B_in xor iC; --Full Adder

	oC <= (iA and s_B_in) or (iC and (iA xor s_B_in)); --Overflow bit
	
	and_out <= iA and iB; --Logical and
	
	or_out <= iA or iB; --Logical or
	
	xor_out <= iA xor iB; --Logical xor
	
	nand_out <= iA nand iB; --Logical nand
	
	nor_out <= iA nor iB; --Logical nor
	
	slt_out <= less; --set less than
	
	oOut <= add_out when s1= '0' and s2 = '0' else
		slt_out when s1= '0' and s2 = '1' and s3 = '0' else
		and_out when s1= '0' and s2 = '1' and s3 = '1' else 
		or_out when s1= '1' and s2 = '0' and s3 = '0' else
		xor_out when s1= '1' and s2 = '0' and s3 = '1' else
		nand_out when s1= '1' and s2 = '1' and s3 = '0' else
		nor_out when s1= '1' and s2 = '1' and s3 = '1';
	

end dataflow;