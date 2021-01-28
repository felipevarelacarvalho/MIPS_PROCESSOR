--MEM/WB
-- By Trevor, Muhamed, Felipe
library IEEE;
use IEEE.std_logic_1164.all;

entity mem_wb is
generic(N : integer := 32);
port(i_CLK 				: in std_logic; 						-- Clock Input
	 i_RST_MEMWB		: in std_logic; 						-- Reset Input
	 i_WE_MEMWB 		: in std_logic; 						-- Write Enable Input
	 -- INPUT PORTS FOR MEM-WB
	 i_JAL_MEMWB 		: in std_logic;							-- Jal Instruction
	 i_MEMTOREG_MEMWB	: in std_logic;							-- MemToReg Instruction
	 i_RegWr_MEMWB      : in std_logic;							-- Register Write to go to Write phase (Added 11/19/20)
	 i_PC_PLUS_4_MEMWB 	: in std_logic_vector(N-1 downto 0);	-- PC+4
	 i_MEM_READ_MEMWB	: in std_logic_vector(N-1 downto 0);	-- Output from DMEM
	 i_ALU_OUT_MEMWB	: in std_logic_vector(N-1 downto 0);	-- Output from ALU
	 i_WriteRegAddr_MEMWB: in std_logic_vector(4 downto 0);   --Write register address
	 -- OUTPUT PORTS FOR MEM-WB
	 o_JAL_MEMWB 		: out std_logic;							-- Jal Instruction
	 o_MEMTOREG_MEMWB	: out std_logic;							-- MemToReg Instruction
	 o_RegWr_MEMWB      : out std_logic;							-- Register Write to go to Write phase (Added 11/19/20
	 o_PC_PLUS_4_MEMWB 	: out std_logic_vector(N-1 downto 0);	-- PC+4
	 o_MEM_READ_MEMWB	: out std_logic_vector(N-1 downto 0);	-- Output from DMEM
	 o_ALU_OUT_MEMWB	: out std_logic_vector(N-1 downto 0);	-- Output from ALU
	 o_WriteRegAddr_MEMWB: out std_logic_vector(4 downto 0));    --Write register address
end mem_wb;

architecture structure of mem_wb is

--Register(N-bits)
component Register_Nbits is
  generic(N : integer := 32);
  port(i_CLK	: in std_logic;     					 -- Clock input
       i_RST	: in std_logic;     					 -- Reset input
       i_WE		: in std_logic;     					 -- Write enable input
       i_D		: in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q		: out std_logic_vector(N-1 downto 0));   -- Data value output
end component;

--1 Bit Register for the Single Bit Instructions
component Register_1bit is
	--generic(N : integer);
	port(i_CLK        : in std_logic;     					 	-- Clock input
		 i_RST        : in std_logic;     					 	-- Reset input
		 i_WE         : in std_logic;     					 	-- Write enable input
		 i_D          : in std_logic;     						-- Data value input
		 o_Q          : out std_logic);   						-- Data value output
  end component;

-- 32 Bit Registers(READ_DATA2,ALU-OUTPUT-INPUT,PC+4)
begin 

-- READ_DATA2
	mem_wb_mem_read_data : Register_Nbits
	generic MAP(N => 32)
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_MEMWB,
			 i_WE 	=> i_WE_MEMWB, 
			 i_D 	=> i_MEM_READ_MEMWB,
			 o_Q 	=> o_MEM_READ_MEMWB
	);

-- ALU_OUT_INPUT
	mem_wb_alu_OUT_IN : Register_Nbits
	generic MAP(N => 32)
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_MEMWB,
			 i_WE 	=> i_WE_MEMWB, 
			 i_D 	=> i_ALU_OUT_MEMWB,
			 o_Q 	=> o_ALU_OUT_MEMWB
	);
-- PC+4
	mem_wb_PC4_reg : Register_Nbits
	generic MAP(N => 32)
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_MEMWB,
			 i_WE 	=> i_WE_MEMWB, 
			 i_D 	=> i_PC_PLUS_4_MEMWB,
			 o_Q 	=> o_PC_PLUS_4_MEMWB
	);

	-- Write Address
ex_mem_RegWrAdrr : Register_Nbits
	generic MAP(N => 5)
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_MEMWB,
			 i_WE 	=> i_WE_MEMWB, 
			 i_D 	=> i_WriteRegAddr_MEMWB,
			 o_Q 	=> o_WriteRegAddr_MEMWB
	);
-- 1 Bit Registers(jal, memToReg, memWr)

-- jal
mem_wb_jal_reg : Register_1bit
	--generic MAP(N => 1)
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_MEMWB,
			 i_WE 	=> i_WE_MEMWB, 
			 i_D 	=> i_JAL_MEMWB,
			 o_Q 	=> o_JAL_MEMWB
	);
	
-- memToReg
mem_wb_memToReg_reg : Register_1bit
	--generic MAP(N => 1)
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_MEMWB,
			 i_WE 	=> i_WE_MEMWB, 
			 i_D 	=> i_MEMTOREG_MEMWB,
			 o_Q 	=> o_MEMTOREG_MEMWB
	);

	-- RegWrite
ex_mem_RegWr_reg : Register_1bit
	--generic MAP(N => 1)
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_MEMWB,
			 i_WE 	=> i_WE_MEMWB, 
			 i_D 	=> i_RegWr_MEMWB,
			 o_Q 	=> o_RegWr_MEMWB
	);
	
end structure;

	