library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;


entity ALU is

	port(
		iA				: in std_logic;
		iB				: in std_logic;
		iC				: in std_logic;
		s1				: in std_logic;
		s2				: in std_logic;
		s3				: in std_logic;
		oC				: out std_logic;		
		oOut				: out std_logic);

end ALU;

architecture dataflow of ALU is

signal add_sub_out : std_logic;
signal slt_out : std_logic;
signal and_out : std_logic;
signal or_out : std_logic;
signal xor_out : std_logic;
signal nand_out : std_logic;
signal nor_out : std_logic;
signal b_invert : std_logic;
signal add_out : std_logic;
signal sub_out : std_logic;

	
begin
	
	b_invert <= not iB;
	
	and_out <= iA and iB;
	
	or_out <= iA or iB;
	
	xor_out <= iA xor iB;
	
	nand_out <= iA nand iB;
	
	nor_out <= iA nor iB;
	
	slt_out <= xor_out and iB;
	
	add_out <= (xor_out and iC) and (iA and iB);
	
	sub_out <= (xor_out and iC) and (iA and b_invert);
	
	add_sub_out <= add_out when s3 = '0' else
			sub_out when s3 = '1';
	
	oC <= iC xor xor_out;
	
	oOut <= add_sub_out when s1= '0' and s2 = '0' else
		slt_out when s1= '0' and s2 = '1' and s3 = '0' else 
		and_out when s1= '0' and s2 = '1' and s3 = '1' else
		or_out when s1= '1' and s2 = '0' and s3 = '0' else
		xor_out when s1= '1' and s2 = '0' and s3 = '1' else
		nand_out when s1= '1' and s2 = '1' and s3 = '0' else
		nor_out when s1= '1' and s2 = '1' and s3 = '1';
	

end dataflow;