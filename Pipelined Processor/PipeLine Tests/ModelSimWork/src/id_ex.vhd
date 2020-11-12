--ID/EX

entity if_id is

generic(N : integer := 32);
port(i_CLK 				: in std_logic; 						-- Clock Input
	 i_RST_IDEX 		: in std_logic; 						-- Reset Input
	 i_WE_IDEX 			: in std_logic; 						-- Write Enable Input
	 o_Q_IDEX 			: out std_logic_vector(N-1 downto 0); 	-- Data Value Output
	 --These are for just ID/EX ------------------------------------------------------
	 i_JAL_IDEX 		: in std_logic;							-- Jal Instruction
	 i_J_IDEX 			: in std_logic;							-- J Instruction
	 i_BNE_IDEX			: in std_logic;							-- Bne Instruction
	 i_BEQ_IDEX			: in std_logic;							-- Beq Instruction
	 i_MEMTOREG_IDEX	: in std_logic;							-- MemToReg Instruction
	 i_MEMWR_IDEX		: in std_logic;							-- MemWrite Instruction
	 i_ALUOP_IDEX		: in std_logic_vector(3 downto 0);		-- ALU_OP Instruction
	 i_ALUSRC_IDEX		: in std_logic;							-- ALU_Src Instruction
	 i_JUMP_ADDR_IDEX 	: in std_logic_vector(N-1 downto 0);	-- Jump Addr.
	 i_SIGN_EXT_IDEX	: in std_logic_vector(N-1 downto 0);	-- PC+4 and SignExtend
	 i_READ_DATA1_IDEX	: in std_logic_vector(N-1 downto 0);	-- Read Data 1
	 i_READ_DATA2_IDEX	: in std_logic_vector(N-1 downto 0);	-- Read Data 2
	 i_PC_PLUS_4_IDEX 	: in std_logic_vector(N-1 downto 0);	-- PC+4
	 ---------------------------------------------------------------------------------

end if_id

architecture structure of id_ex is

--Register(N-bits)
component Register_Nbits:
  generic(N : integer);
  port(i_CLK	: in std_logic;     					 -- Clock input
       i_RST	: in std_logic;     					 -- Reset input
       i_WE		: in std_logic;     					 -- Write enable input
       i_D		: in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q		: out std_logic_vector(N-1 downto 0));   -- Data value output
	   
end Register_Nbits;

--add any addt'l components

-- 32 bit output signals
signal s_readData1		: std_logic_vector(31 downto 0); -- READ_DATA1
signal s_readData2		: std_logic_vector(31 downto 0); -- READ_DATA2
signal s_jumpAddr		: std_logic_vector(31 downto 0); -- Jump Addr.
signal s_signExt		: std_logic_vector(31 downto 0); --(PC+4) + SignExt
signal s_pcPlus4		: std_logic_vector(31 downto 0); -- PC+4

-- 4 bit output signal
signal s_aluOp 			: std_logic_vector(3 downto 0); -- aluOp

-- 1 bit output signals
signal s_jal 			: std_logic_vector(1 downto 0); -- jal
signal s_j 				: std_logic_vector(1 downto 0); -- j
signal s_bne 			: std_logic_vector(1 downto 0); -- bne
signal s_beq 			: std_logic_vector(1 downto 0); -- beq
signal s_memToReg 		: std_logic_vector(1 downto 0); -- memToReg
signal s_memWr 			: std_logic_vector(1 downto 0); -- memWr
signal s_aluSrc 		: std_logic_vector(1 downto 0); -- aluSrc

begin

-- 32 Bit Registers(READ_DATA1 & READ_DATA2,Jump Addr.,(PC+4)+SignExt,PC+4)

-- READ_DATA1
id_ex_data_reg1 : Register_Nbits
	generic MAP(N => 32);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_READ_DATA1_IDEX,
			 o_Q 	=> s_readData1
	);
	
-- READ_DATA2
id_ex_data_reg2 : Register_Nbits
	generic MAP(N => 32);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_READ_DATA2_IDEX,
			 o_Q 	=> s_readData2
	);
	
--for each input make a specific n-bit register for it

-- Jump Addr.
id_ex_jumpAddr_reg : Register_Nbits
	generic MAP(N => 32);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_JUMP_ADDR_IDEX,
			 o_Q 	=> s_jumpAddr
	);
	
--(PC+4)+SignExt
id_ex_PC4_SignExt_reg : Register_Nbits
	generic MAP(N => 32);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_SIGN_EXT_IDEX,
			 o_Q 	=> s_signExt
	);
	
-- PC+4
id_ex_PC4_reg : Register_Nbits
	generic MAP(N => 32);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_PC_PLUS_4_IDEX,
			 o_Q 	=> s_pcPlus4
	);
	
-- 4 Bit Register(ALUOp)
id_ex_ALUOp_reg : Register_Nbits
	generic MAP(N => 4);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_ALUOP_IDEX,
			 o_Q 	=> s_aluOp
	);
	
-- 1 Bit Registers(jal, j, bne, beq, memToReg, memWr, ALUSrc)

-- jal
id_ex_jal_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_JAL_IDEX,
			 o_Q 	=> s_jal
	);
	
-- j
id_ex_j_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_J_IDEX,
			 o_Q 	=> s_j
	);
	
-- bne
id_ex_bne_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_BNE_IDEX,
			 o_Q 	=> s_bne
	);
	
-- beq
id_ex_beq_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_BEQ_IDEX,
			 o_Q 	=> s_beq
	);
	
-- memToReg
id_ex_memToReg_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_MEMTOREG_IDEX,
			 o_Q 	=> s_memToReg
	);
	
-- memWr
id_ex_memWr_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_MEMWR_IDEX,
			 o_Q 	=> s_memWr
	);
	
-- ALUSrc
id_ex_ALUSrc_reg : Register_Nbits
	generic MAP(N => 1);
	port MAP(i_CLK 	=> i_CLK,
			 i_RST 	=> i_RST_IDEX,
			 i_WE 	=> i_WE_IDEX, 
			 i_D 	=> i_ALUSRC_IDEX,
			 o_Q 	=> s_aluSrc
	);
	
