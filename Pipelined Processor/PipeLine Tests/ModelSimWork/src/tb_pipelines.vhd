
library IEEE;
use IEEE.std_logic_1164.all;

--Usually name your testbench similar to below for clarify tb_<name>
entity tb_pipelines is
    --Generic for half of the clock cycle period
      generic(gCLK_HPER   : time := 10 ns);  
    end tb_pipelines;

architecture mixed of tb_pipelines is
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;

  --Components
  ----------------------------------------------------------------------------------------------------------------  
  component if_id is
    generic(N : integer := 32);
    port(
      i_CLK 			: in std_logic; 						-- Clock Input
      i_RST_IFID 	: in std_logic; 						-- Reset Input (Can be used as the Flush input)
      i_WE_IFID 		: in std_logic; 						-- Write Enable Input
      -- these are specific to IF/ID --------------------------------------------------------
      --i_FLUSH_IFID	: in std_logic;							-- Flush Enable(Comes from CLM)
      i_PCplusFOUR	: in std_logic_vector(N-1 downto 0);	-- PC+4(From PC)
      i_MEM_IFID		: in std_logic_vector(N-1 downto 0);	-- Instruction Memory(From IMEM)
      ---------------------------------------------------------------------------------------
      o_PCplusFOUR	: out std_logic_vector(N-1 downto 0);	-- PC+4(From PC)
      o_MEM_IFID		: out std_logic_vector(N-1 downto 0));	-- Instruction Memory(From IMEM)
  end component;

  component id_ex is
    generic(N : integer := 32);
    port(
      i_CLK 				: in std_logic; 						-- Clock Input
      i_RST_IDEX 		: in std_logic; 						-- Reset Input
      i_WE_IDEX 			: in std_logic; 						-- Write Enable Input
      --These are for just ID/EX ------------------------------------------------------
      i_JAL_IDEX 		: in std_logic;							-- Jal Instruction
      i_J_IDEX 			: in std_logic;							-- J Instruction
      i_BNE_IDEX			: in std_logic;							-- Bne Instruction
      i_BEQ_IDEX			: in std_logic;							-- Beq Instruction
      i_MEMTOREG_IDEX	: in std_logic;							-- MemToReg Instruction
      i_MEMWR_IDEX		: in std_logic;							-- MemWrite Instruction
      i_ALUOP_IDEX		: in std_logic_vector(3 downto 0);		-- ALU_OP Instruction
      i_ALUSRC_IDEX		: in std_logic;							-- ALU_Src Instruction
      i_BRANCH_ADDR_IDEX : in std_logic_vector(N-1 downto 0);    --Branch Addr.
      i_JUMP_ADDR_IDEX 	: in std_logic_vector(N-1 downto 0);	-- Jump Addr.
      i_SIGN_EXT_IDEX	: in std_logic_vector(N-1 downto 0);	-- PC+4 and SignExtend
      i_READ_DATA1_IDEX	: in std_logic_vector(N-1 downto 0);	-- Read Data 1
      i_READ_DATA2_IDEX	: in std_logic_vector(N-1 downto 0);	-- Read Data 2
      i_PC_PLUS_4_IDEX 	: in std_logic_vector(N-1 downto 0);	-- PC+4
      i_Instruction     : in std_logic_vector(N-1 downto 0);    --Instruction coming from Imem
      ---------------------------------------------------------------------------------
      o_JAL_IDEX 		: out std_logic;							-- Jal Instruction
      o_J_IDEX 			: out std_logic;							-- J Instruction
      o_BNE_IDEX			: out std_logic;							-- Bne Instruction
      o_BEQ_IDEX			: out std_logic;							-- Beq Instruction
      o_MEMTOREG_IDEX	: out std_logic;							-- MemToReg Instruction
      o_MEMWR_IDEX		: out std_logic;							-- MemWrite Instruction
      o_ALUOP_IDEX		: out std_logic_vector(3 downto 0);		-- ALU_OP Instruction
      o_ALUSRC_IDEX		: out std_logic;							-- ALU_Src Instruction
      o_BRANCH_ADDR_IDEX : out std_logic_vector(N-1 downto 0);    --Branch Addr.
      o_JUMP_ADDR_IDEX 	: out std_logic_vector(N-1 downto 0);	-- Jump Addr.
      o_SIGN_EXT_IDEX	: out std_logic_vector(N-1 downto 0);	-- PC+4 and SignExtend
      o_READ_DATA1_IDEX	: out std_logic_vector(N-1 downto 0);	-- Read Data 1
      o_READ_DATA2_IDEX	: out std_logic_vector(N-1 downto 0);	-- Read Data 2
      o_PC_PLUS_4_IDEX 	: out std_logic_vector(N-1 downto 0);	-- PC+4
      o_Instruction     : out std_logic_vector(N-1 downto 0));   --intruction to be passed to the ALU
  end component;

  component ex_mem is
    generic(N : integer := 32);
    port(
      i_CLK 			: in std_logic; 						-- Clock Input
      i_RST_EXMEM		: in std_logic; 						-- Reset Input
      i_WE_EXMEM 		: in std_logic; 						-- Write Enable Input
      o_Q_EXMEM 		: out std_logic_vector(N-1 downto 0); 	-- Data Value Output
      -- INPUT PORTS FOR EX-MEM
      i_JAL_EXMEM 		: in std_logic;							-- Jal Instruction
      i_MEMTOREG_EXMEM	: in std_logic;							-- MemToReg Instruction
      i_MEMWR_EXMEM		: in std_logic;							-- MemWrite Instruction
      i_PC_PLUS_4_EXMEM 	: in std_logic_vector(N-1 downto 0);	-- PC+4
      i_ALU_OUT_EXMEM	: in std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
      i_READ_DATA2_EXMEM	: in std_logic_vector(N-1 downto 0);	-- Read Data 2
      -- OUTPUT PORTS FOR EX-MEM
      o_JAL_EXMEM 		: out std_logic;							-- Jal Instruction
      o_MEMTOREG_EXMEM	: out std_logic;							-- MemToReg Instruction
      o_MEMWR_EXMEM		: out std_logic;							-- MemWrite Instruction
      o_PC_PLUS_4_EXMEM 	: out std_logic_vector(N-1 downto 0);	-- PC+4
      o_ALU_OUT_EXMEM	: out std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
      o_READ_DATA2_EXMEM	: out std_logic_vector(N-1 downto 0));	-- Read Data 2
  end component;

  component mem_wb is
    generic(N : integer := 32);
    port(
       i_CLK 				: in std_logic; 						-- Clock Input
       i_RST_MEMWB		: in std_logic; 						-- Reset Input
       i_WE_MEMWB 		: in std_logic; 						-- Write Enable Input
       o_Q_MEMWB 			: out std_logic_vector(N-1 downto 0); 	-- Data Value Output
       -- INPUT PORTS FOR MEM-WB
       i_JAL_MEMWB 		: in std_logic;							-- Jal Instruction
       i_MEMTOREG_MEMWB	: in std_logic;							-- MemToReg Instruction
       i_PC_PLUS_4_MEMWB 	: in std_logic_vector(N-1 downto 0);	-- PC+4
       i_MEMWR_READ_MEMWB	: in std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
       i_ALU_OUT_MEMWB	: in std_logic_vector(N-1 downto 0);	-- Read Data 2
       -- OUTPUT PORTS FOR MEM-WB
       o_JAL_MEMWB 		: out std_logic;							-- Jal Instruction
       o_MEMTOREG_MEMWB	: out std_logic;							-- MemToReg Instruction
       o_PC_PLUS_4_MEMWB 	: out std_logic_vector(N-1 downto 0);	-- PC+4
       o_MEMWR_READ_MEMWB	: out std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
       o_ALU_OUT_MEMWB	: out std_logic_vector(N-1 downto 0));	-- Read Data 2
  end component;
  
  --Signals
  ----------------------------------------------------------------------------------------------------------------
  signal s_i_CLK :std_logic;
  --Signals for if_id
  signal s_i_RST_IFID : std_logic;
  signal s_i_WE_IFID : std_logic;
  signal s_i_PCplusFour : std_logic_vector(31 downto 0);
  signal s_i_MEM_IFID : std_logic_vector(31 downto 0);
  signal s_o_PCplusFOUR : std_logic_vector(31 downto 0);
  signal s_o_MEM_IFID : std_logic_vector(31 downto 0);

  --Signals for id_ex
  signal s_i_RST_IDEX : std_logic;
  signal s_i_WE_IDEX : std_logic;
  signal s_i_JAL_IDEX : std_logic;
  signal s_i_J_IDEX : std_logic;
  signal s_i_BNE_IDEX : std_logic;
  signal s_i_BEQ_IDEX : std_logic;
  signal s_i_MEMTOREG_IDEX : std_logic;
  signal s_i_MEMWR_IDEX : std_logic;
  signal s_i_ALUOP_IDEX : std_logic_vector(3 downto 0);
  signal s_i_ALUSRC_IDEX : std_logic;
  signal s_i_BRANCH_ADDR_IDEX : std_logic_vector(31 downto 0);
  signal s_i_JUMP_ADDR_IDEX : std_logic_vector(31 downto 0);
  signal s_i_SIGN_EXT_IDEX : std_logic_vector(31 downto 0);
  signal s_i_READ_DATA1_IDEX : std_logic_vector(31 downto 0);
  signal s_i_READ_DATA2_IDEX : std_logic_vector(31 downto 0);
  signal s_i_PC_PLUS_4_IDEX : std_logic_vector(31 downto 0);
  signal s_i_instruction : std_logic_vector(31 downto 0);
  signal s_o_JAL_IDEX  : std_logic;
  signal s_o_J_IDEX : std_logic;
  signal s_o_BNE_IDEX : std_logic;
  signal s_o_BEQ_IDEX : std_logic;
  signal s_o_MEMTOREG_IDEX : std_logic;
  signal s_o_MEMWR_IDEX : std_logic;
  signal s_o_ALUOP_IDEX : std_logic_vector(3 downto 0);
  signal s_o_ALUSRC_IDEX : std_logic;
  signal s_o_BRANCH_ADDR_IDEX  : std_logic_vector(31 downto 0);
  signal s_o_JUMP_ADDR_IDEX : std_logic_vector(31 downto 0);
  signal s_o_SIGN_EXT_IDEX : std_logic_vector(31 downto 0);
  signal s_o_READ_DATA1_IDEX : std_logic_vector(31 downto 0);
  signal s_o_READ_DATA2_IDEX : std_logic_vector(31 downto 0);
  signal s_o_PC_PLUS_4_IDEX : std_logic_vector(31 downto 0);
  signal s_o_instruction : std_logic_vector(31 downto 0);

  --Signals for ex_mem
  signal s_i_RST_EXMEM :std_logic;
  signal s_i_WE_EXMEM :std_logic;
  signal s_o_Q_EXMEM :std_logic_vector(31 downto 0);
  signal s_i_JAL_EXMEM :std_logic;
  signal s_i_MEMTOREG_EXMEM :std_logic;
  signal s_i_MEMWR_EXMEM :std_logic;
  signal s_i_PC_PLUS_4_EXMEM :std_logic_vector(31 downto 0);
  signal s_i_ALU_OUT_EXMEM :std_logic_vector(31 downto 0);
  signal s_i_READ_DATA2_EXMEM :std_logic_vector(31 downto 0);
  signal s_o_JAL_EXMEM :std_logic;
  signal s_o_MEMTOREG_EXMEM :std_logic;
  signal s_o_MEMWR_EXMEM :std_logic;
  signal s_o_PC_PLUS_4_EXMEM :std_logic_vector(31 downto 0);
  signal s_o_ALU_OUT_EXMEM :std_logic_vector(31 downto 0);
  signal s_o_READ_DATA2_EXMEM :std_logic_vector(31 downto 0);

  --Signals for mem_wb
  signal s_i_RST_MEMWB : std_logic;
  signal s_i_WE_MEMWB : std_logic;
  signal s_o_Q_MEMWB : std_logic_vector(31 downto 0);
  signal s_i_JAL_MEMWB : std_logic;
  signal s_i_MEMTOREG_MEMWB : std_logic;
  signal s_i_PC_PLUS_4_MEMWB : std_logic_vector(31 downto 0);
  signal s_i_MEMWR_READ_MEMWB : std_logic_vector(31 downto 0);
  signal s_i_ALU_OUT_MEMWB : std_logic_vector(31 downto 0);
  signal s_o_JAL_MEMWB : std_logic;
  signal s_o_MEMTOREG_MEMWB : std_logic;
  signal s_o_PC_PLUS_4_MEMWB : std_logic_vector(31 downto 0);
  signal s_o_MEMWR_READ_MEMWB : std_logic_vector(31 downto 0);
  signal s_o_ALU_OUT_MEMWB : std_logic_vector(31 downto 0);

  --Begin Test Bench logic
  ----------------------------------------------------------------------------------------------------------------
  begin
  DUT1: if_id
  generic map (N => 32)
  port map(
    i_CLK 			 => s_i_CLK,
    i_RST_IFID 	 => s_i_RST_IFID,
    i_WE_IFID 	 => s_i_WE_IFID,
    i_PCplusFOUR => s_i_PCplusFour,
    i_MEM_IFID	 => s_i_MEM_IFID,
    --------------------
    o_PCplusFOUR => s_o_PCplusFOUR,
    o_MEM_IFID	 => s_o_MEM_IFID
  );

  DUT2: id_ex
  generic map (N => 32)
  port map(
    i_CLK 				        => s_i_CLK,
    i_RST_IDEX 		        => s_i_RST_IDEX,
    i_WE_IDEX 	          => s_i_WE_IDEX,
    i_JAL_IDEX 		        => s_i_JAL_IDEX,
    i_J_IDEX 			        => s_i_J_IDEX,
    i_BNE_IDEX			      => s_i_BNE_IDEX,
    i_BEQ_IDEX			      => s_i_BEQ_IDEX,
    i_MEMTOREG_IDEX	      => s_i_MEMTOREG_IDEX,
    i_MEMWR_IDEX		      => s_i_MEMWR_IDEX,
    i_ALUOP_IDEX		      => s_i_ALUOP_IDEX,
    i_ALUSRC_IDEX		      => s_i_ALUSRC_IDEX,
    i_BRANCH_ADDR_IDEX    => s_i_BRANCH_ADDR_IDEX,
    i_JUMP_ADDR_IDEX 	    => s_i_JUMP_ADDR_IDEX,
    i_SIGN_EXT_IDEX	      => s_i_SIGN_EXT_IDEX,
    i_READ_DATA1_IDEX	    => s_i_READ_DATA1_IDEX,
    i_READ_DATA2_IDEX	    => s_i_READ_DATA2_IDEX,
    i_PC_PLUS_4_IDEX 	    => s_i_PC_PLUS_4_IDEX,
    i_Instruction         => s_i_Instruction,
    -------------------- 
    o_JAL_IDEX 		        => s_o_JAL_IDEX ,
    o_J_IDEX 			        => s_o_J_IDEX,
    o_BNE_IDEX		        => s_o_BNE_IDEX,
    o_BEQ_IDEX		        => s_o_BEQ_IDEX,
    o_MEMTOREG_IDEX       => s_o_MEMTOREG_IDEX,
    o_MEMWR_IDEX	        => s_o_MEMWR_IDEX,
    o_ALUOP_IDEX	        => s_o_ALUOP_IDEX,
    o_ALUSRC_IDEX	        => s_o_ALUSRC_IDEX,
    o_BRANCH_ADDR_IDEX    => s_o_BRANCH_ADDR_IDEX ,
    o_JUMP_ADDR_IDEX 	    => s_o_JUMP_ADDR_IDEX,
    o_SIGN_EXT_IDEX	      => s_o_SIGN_EXT_IDEX,
    o_READ_DATA1_IDEX	    => s_o_READ_DATA1_IDEX,
    o_READ_DATA2_IDEX	    => s_o_READ_DATA2_IDEX,
    o_PC_PLUS_4_IDEX 	    => s_o_PC_PLUS_4_IDEX,
    o_Instruction         => s_o_Instruction
  );

  DUT3: ex_mem
  generic map (N => 32)
  port map(
    i_CLK 			          => s_i_CLK,
    i_RST_EXMEM		        => s_i_RST_EXMEM,
    i_WE_EXMEM 		        => s_i_WE_EXMEM,
    o_Q_EXMEM 		        => s_o_Q_EXMEM,
    -- INPUT PORTS
    i_JAL_EXMEM 		      => s_i_JAL_EXMEM,
    i_MEMTOREG_EXMEM	    => s_i_MEMTOREG_EXMEM,
    i_MEMWR_EXMEM		      => s_i_MEMWR_EXMEM,
    i_PC_PLUS_4_EXMEM 	  => s_i_PC_PLUS_4_EXMEM,
    i_ALU_OUT_EXMEM	      => s_i_ALU_OUT_EXMEM,
    i_READ_DATA2_EXMEM	  => s_i_READ_DATA2_EXMEM,
    -- OUTPUT PORTS
    o_JAL_EXMEM 		      => s_o_JAL_EXMEM,
    o_MEMTOREG_EXMEM	    => s_o_MEMTOREG_EXMEM,
    o_MEMWR_EXMEM		      => s_o_MEMWR_EXMEM,
    o_PC_PLUS_4_EXMEM 	  => s_o_PC_PLUS_4_EXMEM,
    o_ALU_OUT_EXMEM	      => s_o_ALU_OUT_EXMEM,
    o_READ_DATA2_EXMEM	  => s_o_READ_DATA2_EXMEM
  );

  DUT4: mem_wb
  generic map(N => 32)
  port map(
    i_CLK 				      => s_i_CLK,
    i_RST_MEMWB		      => s_i_RST_MEMWB,
    i_WE_MEMWB 		      => s_i_WE_MEMWB,
    o_Q_MEMWB 			    => s_o_Q_MEMWB,
    -- INPUT PORTS
    i_JAL_MEMWB 		    => s_i_JAL_MEMWB,
    i_MEMTOREG_MEMWB	  => s_i_MEMTOREG_MEMWB,
    i_PC_PLUS_4_MEMWB   => s_i_PC_PLUS_4_MEMWB,
    i_MEMWR_READ_MEMWB  => s_i_MEMWR_READ_MEMWB,
    i_ALU_OUT_MEMWB	    => s_i_ALU_OUT_MEMWB,
    -- OUTPUT PORTS
    o_JAL_MEMWB 		    => s_o_JAL_MEMWB,
    o_MEMTOREG_MEMWB    => s_o_MEMTOREG_MEMWB,
    o_PC_PLUS_4_MEMWB   => s_o_PC_PLUS_4_MEMWB,
    o_MEMWR_READ_MEMWB  => s_o_MEMWR_READ_MEMWB,
    o_ALU_OUT_MEMWB     => s_o_ALU_OUT_MEMWB
  );


  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_i_CLK <= '0';
    wait for gCLK_HPER;
    s_i_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  P_TB: process
  begin
    --Reset the test bench
    s_i_RST_IFID <= '1';
    s_i_RST_IDEX <= '1';
    s_i_RST_EXMEM<= '1';
    s_i_RST_MEMWB<= '1';
    s_i_WE_IFID  <= '1';
    s_i_WE_IDEX  <= '1';
    s_i_WE_EXMEM <= '1';
    s_i_WE_MEMWB <= '1';
    wait for cCLK_PER;

    --Set IF/ID
    s_i_RST_IFID <= '0';
    s_i_RST_IDEX <= '0';
    s_i_RST_EXMEM<= '0';
    s_i_RST_MEMWB<= '0';
    s_i_WE_IFID  <= '1';
    s_i_WE_IDEX  <= '1';
    s_i_WE_EXMEM <= '1';
    s_i_WE_MEMWB <= '1';
    s_i_PCplusFour <= x"00000004";
    s_i_MEM_IFID <= x"0000000F";
    wait for cCLK_PER;

    --Set ID/EX
    s_i_PC_PLUS_4_IDEX <= s_o_PCplusFOUR;
    s_i_Instruction <= s_o_MEM_IFID;
    ------------
    s_i_JAL_IDEX <= '1';
    s_i_J_IDEX <= '1';
    s_i_BNE_IDEX <= '1';
    s_i_BEQ_IDEX <= '1';
    s_i_MEMTOREG_IDEX <= '1';
    s_i_MEMWR_IDEX <= '1';
    s_i_ALUOP_IDEX <= "1111";
    s_i_ALUSRC_IDEX <= '1';
    s_i_BRANCH_ADDR_IDEX <= x"000000FF";
    s_i_JUMP_ADDR_IDEX <= x"00000FFF";
    s_i_SIGN_EXT_IDEX <= x"FFFF000F";
    s_i_READ_DATA1_IDEX <= x"0000000A";
    s_i_READ_DATA2_IDEX <= x"0000000B";
    wait for cCLK_PER;

    --Set EX/MEM
    s_i_JAL_EXMEM <= s_o_JAL_IDEX;
    s_i_MEMTOREG_EXMEM <= s_o_MEMTOREG_IDEX;
    s_i_MEMWR_EXMEM <= s_o_MEMWR_IDEX;
    s_i_PC_PLUS_4_EXMEM <= s_o_PC_PLUS_4_IDEX;
    s_i_READ_DATA2_EXMEM <= s_o_READ_DATA2_IDEX;
    ------------
    s_i_ALU_OUT_EXMEM <= x"00000F0F";
    wait for cCLK_PER;

    --Set MEM/WB
    s_i_JAL_MEMWB <= s_o_JAL_EXMEM;
    s_i_MEMTOREG_MEMWB <= s_o_MEMTOREG_EXMEM;
    s_i_PC_PLUS_4_MEMWB <= s_o_PC_PLUS_4_EXMEM;
    s_i_ALU_OUT_MEMWB <= s_o_ALU_OUT_EXMEM;
    ------------
    s_i_MEMWR_READ_MEMWB <= x"FFFFFFFF";
    wait for cCLK_PER;

  end process;

end mixed;