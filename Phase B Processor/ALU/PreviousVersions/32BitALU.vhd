library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity ALU32 is

	port(
		iA				: in std_logic_vector (31 downto 0);
		iB				: in std_logic_vector (31 downto 0);
		iC				: in std_logic;
		s1				: in std_logic;
		s2				: in std_logic;
		s3				: in std_logic;
		oC				: out std_logic;		
		oOut				: out std_logic_vector (31 downto 0));

end ALU32;

architecture structure of ALU32 is

component ALU is
	port(
		iA				: in std_logic;
		iB				: in std_logic;
		iC				: in std_logic;
		s1				: in std_logic;
		s2				: in std_logic;
		s3				: in std_logic;
		oC				: out std_logic;		
		oOut			: out std_logic);
end component;

signal c: std_logic_vector (30 downto 0);

begin
	A1 : ALU port map(
		iA(0),
		iB(0),
		iC,
		s1,
		s2,
		s3,
		c(0),	
		oOut(0));
		
	G1 : for i in 1 to 30 generate
		ALUs : ALU port map(
			iA(i),
			iB(i),
			c(i-1),
			s1,
			s2,
			s3,
			c(i),	
			oOut(i));
	end generate;
	
	A32 : ALU port map(
		iA(31),
		iB(31),
		c(30),
		s1,
		s2,
		s3,
		oC,	
		oOut(31));
end structure;
	