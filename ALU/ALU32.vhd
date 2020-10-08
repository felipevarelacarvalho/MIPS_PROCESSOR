--32 Bit ALU with the following operations and select lines:
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

entity ALU32 is

	port(
		iA				: in std_logic_vector (31 downto 0);
		iB				: in std_logic_vector (31 downto 0);
		--iC				: in std_logic;
		s1				: in std_logic;
		s2				: in std_logic;
		s3				: in std_logic;
		oC				: out std_logic;		
		oOut				: out std_logic_vector (31 downto 0));

end ALU32;

architecture structure of ALU32 is

component oneBitALU is
	port(
		iA				: in std_logic;
		iB				: in std_logic;
		iC				: in std_logic;
		less            : in std_logic;
		s1				: in std_logic;
		s2				: in std_logic;
		s3				: in std_logic;
		oC				: out std_logic;		
		oOut			: out std_logic);
end component;

component oneBitALU_withSet is
	port(
		iA				: in std_logic;
		iB				: in std_logic;
		iC				: in std_logic;
		less            : in std_logic;
		s1				: in std_logic;
		s2				: in std_logic;
		s3				: in std_logic;
		set             : out std_logic;
		oC				: out std_logic;		
		oOut			: out std_logic);
end component;

signal c: std_logic_vector (30 downto 0);
signal s_set : std_logic;
signal carry_in :std_logic;
constant ground : std_logic := '0';

begin
	carry_in <= '1' when s1= '0' and s2 = '0' and s3 = '1' else  
	'1' when s1= '0' and s2 = '1' and s3 = '0' else
	'0';

	A1 : oneBitALU port map(
		iA(0),
		iB(0),
		carry_in,
		s_set,
		s1,
		s2,
		s3,
		c(0),	
		oOut(0));
		
	G1 : for i in 1 to 30 generate
		ALUs : oneBitALU port map(
			iA(i),
			iB(i),
			c(i-1),
			ground,
			s1,
			s2,
			s3,
			c(i),	
			oOut(i));
	end generate;
	
	A32 : oneBitALU_withSet port map(
		iA(31),
		iB(31),
		c(30),
		ground,
		s1,
		s2,
		s3,
		s_set,
		oC,	
		oOut(31));
end structure;
	