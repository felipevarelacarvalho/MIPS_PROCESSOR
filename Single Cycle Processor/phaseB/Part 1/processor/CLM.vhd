library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity CLM is
	port(
		opcode		: in std_logic_vector (5 downto 0);
		funct		: in std_logic_vector (5 downto 0);
		ALUSrc		: out std_logic;
		ALUControl	: out std_logic_vector (3 downto 0);
		MemtoReg	: out std_logic;
		s_DMemWr	: out std_logic;
		s_RegWr		: out std_logic;
		RegDst		: out std_logic;
		Jump		: out std_logic;
		Branch		: out std_logic;
		MemRead		: out std_logic);
end CLM;

architecture dataflow of CLM is



begin

	ALUSrc <= '0' when opcode = "000000" else
			  '1';
			  
	ALUControl <=   "0000" when opcode = "001001" else
			"0000" when opcode = "001000" else
			"0010" when opcode = "001010" else --slti
			"0010" when opcode = "001011" else --sltiu
			"0011" when opcode = "001100" else
			"0100" when opcode = "001101" else 
			"0101" when opcode = "001110" else
			"1000" when opcode = "001111" else
			"0000" when opcode = "100011" else 
			"0000" when opcode = "101011" else --sw
			"1010" when funct = "000010" else
			"0000" when funct = "100000" else
			"0000" when funct = "100001" else
			"0010" when funct = "101011" else --sltu
			"0001" when funct = "100010" else --sub
			"0001" when funct = "100011" else --subu
			"0010" when funct = "101010" else --slt
			"0011" when funct = "100100" else
			"0100" when funct = "100101" else
			"0101" when funct = "100110" else
			"0110" when funct = "000111" else
			"0111" when funct = "100111" else
			"1001" when funct = "000000" else
			"1011" when funct = "000011" else
			"1100" when funct = "000100" else
			"1101" when funct = "000110";

	MemtoReg <= '0' when opcode = "001111" else --LUI INSTRUCTION
				'1' when opcode = "100011" else
				'0';
	
	s_DMemWr <= '1' when opcode = "101011" else --sw
				'0';

	with opcode select s_RegWr <= 
			'1' when "001000", --addi
			'1' when "000000", --add,addu,srl,slt,sltu,and,or,xor,srav,nor,sll,sra,sllv,srlv
			'1' when "001001", --addiu
			'1' when "001010", --slti 
			'1' when "001011", --sltiu 
			'1' when "001100", --andi 
			'1' when "001101", --ori 
			'1' when "001110", --xori 
			'1' when "001111", --lui
			'1' when "100011", --lw 
 
			'0' when others;
	--PROGRESS SO FAR:
	--	srl: WORKS
	--	add: WORKS
	--	addiu: WORKS
	--	addu: WORKS
	--	sw: WORKS
	--	addi: WORKS
	--	sub: WORKS
	--	subu: WORKS
	--	slt: WORKS
	--	slti: WORKS
	--	sltiu: WORKS
	--	sltu: WORKS
	--	and: WORKS
	--	andi: WORKS
	--	or: WORKS
	--	ori: WORKS
	--	xor: WORKS
	--	xori: WORKS
	--	srav: WORKS
	--	nor: WORKS
	--	lui: WORKS
	--	lw: WORKS
	--	sll: WORKS
	--	sra: WORKS
	--	sllv: WORKS
	--	srlv: WORKS

	
	RegDst <= 	'0' when opcode = "001001" else
				'0' when opcode = "001000" else
				'0' when opcode = "001010" else
				'0' when opcode = "001011" else --sltiu
				'0' when opcode = "001100" else
				'0' when opcode = "001101" else
				'0' when opcode = "001110" else
				'0' when opcode = "001111" else
				'0' when opcode = "100011" else
				'1' when funct = "000010" else
				'1' when funct = "100000" else
				'1' when funct = "100001" else
				'1' when funct = "101011" else --sltu
				'1' when funct = "100010" else
				'1' when funct = "100011" else
				'1' when funct = "101010" else
				'1' when funct = "100100" else
				'1' when funct = "100101" else
				'1' when funct = "100110" else
				'1' when funct = "000111" else
				'1' when funct = "100111" else
				'1' when funct = "000000" else
				'1' when funct = "000011" else
				'1' when funct = "000100" else
				'1' when funct = "000110";
	
	Jump <= '0';
	
	Branch <= '0';
	
	MemRead <=  '1' when opcode = "001111" else
				'1' when opcode = "100011" else
				'0';

end dataflow;