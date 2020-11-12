--EX/MEM
-- By Trevor, Muhamed, Felipe
library IEEE;
use IEEE.std_logic_1164.all;

entity ex_mem is

generic(N : integer := 32);
port(i_CLK 				: in std_logic; 						-- Clock Input
	 i_RST_EXMEM		: in std_logic; 						-- Reset Input
	 i_WE_EXMEM 		: in std_logic; 						-- Write Enable Input
	 o_Q_EXMEM 			: out std_logic_vector(N-1 downto 0)); 	-- Data Value Output
	 -- INPUT PORTS FOR EX-MEM
	 i_JAL_EXMEM 		: in std_logic;							-- Jal Instruction
	 i_MEMTOREG_EXMEM	: in std_logic;							-- MemToReg Instruction
	 i_MEMWR_EXMEM		: in std_logic;							-- MemWrite Instruction
	 i_PC_PLUS_4_EXMEM 	: in std_logic_vector(N-1 downto 0);	-- PC+4
	 i_ALU_OUT_EXMEM	: in std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
	 i_READ_DATA2_EXMEM	: in std_logic_vector(N-1 downto 0);	-- Read Data 2
	 -- OUTPUT PORTS FOR EX-MEM
	 o_JAL_EXMEM 		: in std_logic;							-- Jal Instruction
	 o_MEMTOREG_EXMEM	: in std_logic;							-- MemToReg Instruction
	 o_MEMWR_EXMEM		: in std_logic;							-- MemWrite Instruction
	 o_PC_PLUS_4_EXMEM 	: in std_logic_vector(N-1 downto 0);	-- PC+4
	 o_ALU_OUT_EXMEM	: in std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
	 o_READ_DATA2_EXMEM	: in std_logic_vector(N-1 downto 0));	-- Read Data 2
end ex_mem;

architecture structure of ex_mem is

--Register(N-bits)
component Register_Nbits is
  generic(N : integer := 32);
  port(i_CLK	: in std_logic;     					 -- Clock input
       i_RST	: in std_logic;     					 -- Reset input
       i_WE		: in std_logic;     					 -- Write enable input
       i_D		: in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q		: out std_logic_vector(N-1 downto 0));   -- Data value output
end component;

-- 32 Bit Registers(READ_DATA2,ALU-OUTPUT-INPUT,PC+4)
begin 

-- READ_DATA2
	ex_mem_data2 : Register_Nbits
	generic MAP(N => 32);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_EXMEM,
			 i_WE 	=> i_WE_EXMEM, 
			 i_D 	=> i_READ_DATA2_EXMEM,
			 o_Q 	=> o_READ_DATA2_EXMEM
	);

-- ALU_OUT_INPUT
	ex_mem_alu_OUT_IN : Register_Nbits
	generic MAP(N => 32);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_EXMEM,
			 i_WE 	=> i_WE_EXMEM, 
			 i_D 	=> i_ALU_OUT_EXMEM,
			 o_Q 	=> o_ALU_OUT_EXMEM
	);
-- PC+4
	ex_mem_PC4_reg : Register_Nbits
	generic MAP(N => 32);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_EXMEM,
			 i_WE 	=> i_WE_EXMEM, 
			 i_D 	=> i_PC_PLUS_4_EXMEM,
			 o_Q 	=> o_PC_PLUS_4_EXMEM
	);
	
-- 1 Bit Registers(jal, memToReg, memWr)

-- jal
ex_mem_jal_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_EXMEM,
			 i_WE 	=> i_WE_EXMEM, 
			 i_D 	=> i_JAL_EXMEM,
			 o_Q 	=> o_JAL_EXMEM
	);
	
-- memToReg
ex_mem_memToReg_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_EXMEM,
			 i_WE 	=> i_WE_EXMEM, 
			 i_D 	=> i_MEMTOREG_EXMEM,
			 o_Q 	=> o_MEMTOREG_EXMEM
	);
	
-- memWr
ex_mem_memWr_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_EXMEM,
			 i_WE 	=> i_WE_EXMEM, 
			 i_D 	=> i_MEMWR_EXMEM,
			 o_Q 	=> o_MEMWR_EXMEM
	);
	
end structure;