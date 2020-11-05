library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity tb_CLM is
	generic(gCLK_HPER : time := 50 ns);
end tb_CLM;

architecture behaviour of tb_CLM is
	constant cCLK_PER : time := gCLK_HPER * 2;
	
	component CLM
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
		JumpReg		: out std_logic;
		JumpNLink	: out std_logic;
		BranchEqual	: out std_logic;
		BranchNotEqual: out std_logic;
		isExtendSigned: out std_logic;
		MemRead		: out std_logic);
	end component;
	
	--Signals
	signal s_CLK : std_logic;
	signal s_opcode, s_funct : std_logic_vector (5 downto 0);
	signal s_ALUControl : std_logic_vector (3 downto 0);
	signal s_ALUSrc, s_MemtoReg, s_s_DMemWr, s_s_RegWr, s_RegDst, s_Jump, s_MemRead, s_JumpReg, s_JumpNLink, s_BranchEqual, s_BranchNotEqual, s_isExtendSigned : std_logic;
	
begin
	DUT : CLM
	port map(
		opcode	     =>s_opcode,
		funct		 =>s_funct,
		ALUSrc		 =>s_ALUSrc,
		ALUControl	 =>s_ALUControl,
		MemtoReg	 =>s_MemtoReg,
		s_DMemWr	 =>s_s_DMemWr,
		s_RegWr		 =>s_s_RegWr,
		RegDst		 =>s_RegDst,
		Jump		 =>s_Jump,
		JumpReg		 => s_JumpReg,
		JumpNLink	 => s_JumpNLink,
		BranchEqual	 => s_BranchEqual,
		BranchNotEqual => s_BranchNotEqual,
		isExtendSigned => s_isExtendSigned,
		MemRead		 =>s_MemRead
	);
	
	P_CLK : process
	begin
		s_CLK <= '0';
		wait for gCLK_HPER;
		s_CLK <= '1';
		wait for gCLK_HPER;
	end process;
	
	P_TB : process
	begin
		s_opcode <="000000";	s_funct <="000010"; --srl
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="100000"; --add
		wait for cCLK_PER;
		
		s_opcode <="001001";	s_funct <="000000"; --addiu
		wait for cCLK_PER;
		
		s_opcode <= "000000";	s_funct <= "100001"; --addu
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="101011"; --sw
		wait for cCLK_PER;
		
		s_opcode <="001000";	s_funct <="000000"; --addi
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="100010"; --sub
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="100011";--subu
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="101010"; --slt
		wait for cCLK_PER;
		
		s_opcode <="001010";	s_funct <="000000"; --slti
		wait for cCLK_PER;
		
		s_opcode <="001011";	s_funct <="000000"; --sltiu
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="101011"; --sltu
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="100100"; --and
		wait for cCLK_PER;
		
		s_opcode <="001100";	s_funct <="000000"; --andi
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="100101"; --or
		wait for cCLK_PER;
		
		s_opcode <="001101";	s_funct <="000000"; --ori
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="100110"; --xor
		wait for cCLK_PER;
		
		s_opcode <="001110";	s_funct <="000000";--xori
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="000111"; --srav
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="100111"; --nor
		wait for cCLK_PER;
		
		s_opcode <="001111";	s_funct <="000000"; --lui
		wait for cCLK_PER;
		
		s_opcode <="100011";	s_funct <="000000"; --lw
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="000000"; --sll
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="000011"; --sra
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="000100";--sllv
		wait for cCLK_PER;
		
		s_opcode <="000000";	s_funct <="000110"; --srlv
		wait for cCLK_PER;

		s_opcode <="000100";     s_funct <="011001"; --beq
		wait for cCLK_PER;

		s_opcode <="000101";     s_funct <="011001"; --bne
		wait for cCLK_PER;

		s_opcode <="000010"; --j (funct should not matter)
		wait for cCLK_PER;

		s_opcode <="000011"; --jal (funct should not matter)
		wait for cCLK_PER;

		s_opcode <="000000";     s_funct <="001000"; --jr
		wait for cCLK_PER;
	end process;

end behaviour;
