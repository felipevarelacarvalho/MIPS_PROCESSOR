-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a MIPS_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_Processor is
  generic(N : integer := 32);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic; 							--Dont worry about it now
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0); 	--Dont worry about it
       oALUOut         : out std_logic_vector(N-1 downto 0)); 	-- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; 							-- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); 		-- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); 		-- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); 		-- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; 							-- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); 		-- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); 		-- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); 		-- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); 		-- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); 		-- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal v0             : std_logic_vector(N-1 downto 0); 		-- TODO: should be assigned to the output of register 2, used to implement the halt SYSCALL
  signal s_Halt         : std_logic; 							-- TODO: this signal indicates to the simulation that intended program execution has completed. This case happens when the syscall instruction is observed and the V0 register is at 0x0000000A. This signal is active high and should only be asserted after the last register and memory writes before the syscall are guaranteed to be completed.

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment

  -------------------------------------------------------------------------------------------------------
  --Additional Components
  -------------------------------------------------------------------------------------------------------
  component MUX21_structN is
    generic(N : integer);
    port(A,B : in std_logic_vector (N-1 downto 0);
        S : in std_logic;
        Q : out std_logic_vector(N-1 downto 0));
  end component;

  component MIPS_ALU is
    port(
	  shamt           : in std_logic_vector(31 downto 0); 	--Added as a way to keep track of the shifter amount
      i_A             : in std_logic_vector(31 downto 0);	--Input A
      i_B             : in std_logic_vector(31 downto 0); 	--Input B, input that controls immediate value
      select_ALU      : in std_logic_vector( 3 downto 0); 	--Select line ALU
      Zero            : out std_logic;                     	--Zero Output
      data_out        : out std_logic_vector(31 downto 0); 	--ALU output
      c_out           : out std_logic                     	--Carry out
    );
  end component;

  component extender is
    port(
      signal_extend : in std_logic;
      d_in : in std_logic_vector(15 downto 0);
      d_out : out std_logic_vector(31 downto 0)
    );
  end component;

  --component Register_Nbits is
    --generic(N: integer);
    --port(
      --i_CLK        : in std_logic;     -- Clock input
      --i_RST        : in std_logic;     -- Reset input
      --i_WE         : in std_logic;     -- Write enable input
      --i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
      --o_Q          : out std_logic_vector(N-1 downto 0)
    --);
    --end component;

    component CLM is
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
		BranchNotEqual	: out std_logic;
		isExtendSigned	: out std_logic;
        MemRead		: out std_logic
      );    
    end component;

    component regfile is
      port(
        clk, rst, reg_write_en: in std_logic;
        reg_write_dest: in std_logic_vector(4 downto 0); 					-- 5 bit destination (Input for 5:32 decoder)
        reg_write_data: in std_logic_vector(31 downto 0); 					--32 bit data in (input for registers)
        reg_read_addrA, reg_read_addrB: in std_logic_vector(4 downto 0); 	--Select line for 32:1 mux for read address A and B
        reg_out_dataA: out std_logic_vector(31 downto 0); 					--32 bit output register A
        reg_out_dataB: out std_logic_vector(31 downto 0); 					-- 32 bit output register B
        reg2_out: out std_logic_vector(31 downto 0)
      );
    end component;

    component FA_struct is
      generic(N : integer :=32);
      port(Cin : in std_logic;
          A, B : in std_logic_vector (N-1 downto 0);
          Cout : out std_logic;
          Sum : out std_logic_vector (N-1 downto 0));
    end component;

    --Components added for Phase II
    component BarrelShifter is
      port (
        data_in     : in  STD_LOGIC_VECTOR (31 downto 0);
        isSigned : in  STD_LOGIC; 								-- 0 characterizes an logical shift, 1 characterizes an arithmetic shift
        left_shift  : in  STD_LOGIC; 							--0 shifts left, 1 shifts right
        shamt   : in  STD_LOGIC_VECTOR (4 downto 0);           
        data_out    : out STD_LOGIC_VECTOR (31 downto 0));   
    end component;

    component BranchLogic is
      port(
        BranchOnEqual_in    : in std_logic;
        BranchOnNotEqual_in : in std_logic;
        ComparingBit        : in std_logic;
        BranchSignal_out    : out std_logic);
    end component;
	
	--Added new PC Register for jal in phase II (10/4/2020)
	component PC_reg is
		generic(N : integer :=32);
		port(i_CLK   : in std_logic;     						-- Clock input
		i_RST        : in std_logic;     						-- Reset input
		i_WE         : in std_logic;     						-- Write enable input
		i_D          : in std_logic_vector(N-1 downto 0);     	-- Data value input
		o_Q          : out std_logic_vector(N-1 downto 0));   	-- Data value output
	end component;
	
	--Components for Phase C:
	
  component if_id is
    generic(N : integer := 32);
    port(
      i_CLK 				: in std_logic; 						-- Clock Input
      i_RST_IFID 			: in std_logic; 						-- Reset Input (Can be used as the Flush input)
      i_WE_IFID 			: in std_logic; 						-- Write Enable Input
      -- these are specific to IF/ID --------------------------------------------------------
      --i_FLUSH_IFID		: in std_logic;							-- Flush Enable(Comes from CLM)
      i_PCplusFOUR			: in std_logic_vector(N-1 downto 0);	-- PC+4(From PC)
      i_MEM_IFID			: in std_logic_vector(N-1 downto 0);	-- Instruction Memory(From IMEM)
      ---------------------------------------------------------------------------------------
      o_PCplusFOUR			: out std_logic_vector(N-1 downto 0);	-- PC+4(From PC)
      o_MEM_IFID			: out std_logic_vector(N-1 downto 0));	-- Instruction Memory(From IMEM)
  end component;

  component id_ex is
    generic(N : integer := 32);
    port(
      i_CLK 				: in std_logic; 						-- Clock Input
      i_RST_IDEX 			: in std_logic; 						-- Reset Input
      i_WE_IDEX 			: in std_logic; 						-- Write Enable Input
      --These are for just ID/EX ------------------------------------------------------
      i_JAL_IDEX 			: in std_logic;							-- Jal Instruction
      i_J_IDEX 				: in std_logic;							-- J Instruction
      i_BNE_IDEX			: in std_logic;							-- Bne Instruction
      i_BEQ_IDEX			: in std_logic;							-- Beq Instruction
      i_MEMTOREG_IDEX		: in std_logic;							-- MemToReg Instruction
      i_MEMWR_IDEX			: in std_logic;							-- MemWrite Instruction
      i_ALUOP_IDEX			: in std_logic_vector(3 downto 0);		-- ALU_OP Instruction
      i_ALUSRC_IDEX			: in std_logic;							-- ALU_Src Instruction
      i_BRANCH_ADDR_IDEX	: in std_logic_vector(N-1 downto 0);    -- Branch Addr.
      i_JUMP_ADDR_IDEX 		: in std_logic_vector(N-1 downto 0);	-- Jump Addr.
      i_SIGN_EXT_IDEX		: in std_logic_vector(N-1 downto 0);	-- PC+4 and SignExtend
      i_READ_DATA1_IDEX		: in std_logic_vector(N-1 downto 0);	-- Read Data 1
      i_READ_DATA2_IDEX		: in std_logic_vector(N-1 downto 0);	-- Read Data 2
      i_PC_PLUS_4_IDEX 		: in std_logic_vector(N-1 downto 0);	-- PC+4
	  i_Instruction			: in std_logic_vector(N-1 downto 0);    --Instruction coming from Imem
      ---------------------------------------------------------------------------------
      o_JAL_IDEX 			: out std_logic;						-- Jal Instruction
      o_J_IDEX 				: out std_logic;						-- J Instruction
      o_BNE_IDEX			: out std_logic;						-- Bne Instruction
      o_BEQ_IDEX			: out std_logic;						-- Beq Instruction
      o_MEMTOREG_IDEX		: out std_logic;						-- MemToReg Instruction
      o_MEMWR_IDEX			: out std_logic;						-- MemWrite Instruction
      o_ALUOP_IDEX			: out std_logic_vector(3 downto 0);		-- ALU_OP Instruction
      o_ALUSRC_IDEX			: out std_logic;						-- ALU_Src Instruction
      o_BRANCH_ADDR_IDEX 	: out std_logic_vector(N-1 downto 0);  	-- Branch Addr.
      o_JUMP_ADDR_IDEX 		: out std_logic_vector(N-1 downto 0);	-- Jump Addr.
      o_SIGN_EXT_IDEX		: out std_logic_vector(N-1 downto 0);	-- PC+4 and SignExtend
      o_READ_DATA1_IDEX		: out std_logic_vector(N-1 downto 0);	-- Read Data 1
      o_READ_DATA2_IDEX		: out std_logic_vector(N-1 downto 0);	-- Read Data 2
      o_PC_PLUS_4_IDEX 		: out std_logic_vector(N-1 downto 0);	-- PC+4
	  o_Instruction			: out std_logic_vector(N-1 downto 0));   --intruction to be passed to the ALU
  end component;
  component ex_mem is
    generic(N : integer := 32);
    port(
      i_CLK 				: in std_logic;							-- Clock Input
      i_RST_EXMEM			: in std_logic;							-- Reset Input
      i_WE_EXMEM 			: in std_logic;							-- Write Enable Input
      -- INPUT PORTS FOR EX-MEM
      i_JAL_EXMEM 			: in std_logic;							-- Jal Instruction
      i_MEMTOREG_EXMEM		: in std_logic;							-- MemToReg Instruction
      i_MEMWR_EXMEM			: in std_logic;							-- MemWrite Instruction
      i_PC_PLUS_4_EXMEM 	: in std_logic_vector(N-1 downto 0);	-- PC+4
      i_ALU_OUT_EXMEM		: in std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
      i_READ_DATA2_EXMEM	: in std_logic_vector(N-1 downto 0);	-- Read Data 2
      -- OUTPUT PORTS FOR EX-MEM
      o_JAL_EXMEM 			: out std_logic;						-- Jal Instruction
      o_MEMTOREG_EXMEM		: out std_logic;						-- MemToReg Instruction
      o_MEMWR_EXMEM			: out std_logic;						-- MemWrite Instruction
      o_PC_PLUS_4_EXMEM 	: out std_logic_vector(N-1 downto 0);	-- PC+4
      o_ALU_OUT_EXMEM		: out std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
      o_READ_DATA2_EXMEM	: out std_logic_vector(N-1 downto 0));	-- Read Data 2
  end component;

  component mem_wb is
    generic(N : integer := 32);
    port(
       i_CLK 				: in std_logic; 						-- Clock Input
       i_RST_MEMWB			: in std_logic; 						-- Reset Input
       i_WE_MEMWB 			: in std_logic; 						-- Write Enable Input
       -- INPUT PORTS FOR MEM-WB
       i_JAL_MEMWB 			: in std_logic;							-- Jal Instruction
       i_MEMTOREG_MEMWB		: in std_logic;							-- MemToReg Instruction
       i_PC_PLUS_4_MEMWB 	: in std_logic_vector(N-1 downto 0);	-- PC+4
       i_MEMWR_READ_MEMWB	: in std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
       i_ALU_OUT_MEMWB		: in std_logic_vector(N-1 downto 0);	-- Read Data 2
       -- OUTPUT PORTS FOR MEM-WB
       o_JAL_MEMWB 			: out std_logic;						-- Jal Instruction
       o_MEMTOREG_MEMWB		: out std_logic;						-- MemToReg Instruction
       o_PC_PLUS_4_MEMWB 	: out std_logic_vector(N-1 downto 0);	-- PC+4
       o_MEMWR_READ_MEMWB	: out std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
       o_ALU_OUT_MEMWB		: out std_logic_vector(N-1 downto 0));	-- Read Data 2
  end component;
  

  -------------------------------------------------------------------------------------------------------
  --Additional Signals
  -------------------------------------------------------------------------------------------------------
  signal s_ALUout 						: std_logic_vector(31 downto 0);
  signal s_MemToReg 					: std_logic;
  signal s_MemToRegMuxOut 				: std_logic_vector(31 downto 0);
  signal s_RegFileReadAddress1 			: std_logic_vector(31 downto 0);
  signal s_RegFileReadAddress2 			: std_logic_vector(31 downto 0);
  signal s_ALUSrcMuxOut 				: std_logic_vector(31 downto 0);
  signal s_ALUZeroOut 					: std_logic;
  signal s_ALUCarryOut					: std_logic;
  signal s_SignExtendOut				: std_logic_vector(31 downto 0);
  signal s_RegDstMuxOut					: std_logic_vector( 3 downto 0);

  signal s_PCPlusFourOut				: std_logic_vector(31 downto 0); 		--this now is a dummy signal

  signal s_DummyCout					: std_logic;

  --Control Logic Module Signals
  signal s_ALUOp 						: std_logic_vector(3 downto 0);
  signal s_ALUSrc						: std_logic;
  signal s_RegDst						: std_logic;
  signal s_Jump 						: std_logic;
  signal s_BranchOnEqual 				: std_logic; 							--Added for BEQ
  signal s_MemReadEnable 				: std_logic; 							--Not being used in Proj B, here for future reference
  signal s_jr 							: std_logic; 							--Added for jr
  signal s_BranchOnNotEqual 			: std_logic; 							--Added for BNE
  signal s_jal 							: std_logic; 							--Added for jal

  --New signals for Phase II
  signal s_ShiftLeftTwoInstructionOut	: std_logic_vector(31 downto 0);
  signal s_BranchMuxOut 				: std_logic_vector(31 downto 0);
  signal s_JumpMuxOut   				: std_logic_vector(31 downto 0);
  signal s_JrMuxOut 					: std_logic_vector(31 downto 0);
  signal s_ShiftLeftTwoSignExtended 	: std_logic_vector(31 downto 0);
  signal s_groundout 					: std_logic; 							-- Assigned to signals that are not useful
  signal s_BranchAdderOut 				: std_logic_vector(31 downto 0);
  signal s_BranchLogicOut 				: std_logic;
  signal s_isExtendSigned 				: std_logic; 							-- check for sign extension for boolean immediate functions
  signal s_RegWrAddrIntermed 			: std_logic_vector(4 downto 0); 		-- to fix intermediate mux added for jal functionality

  signal s_temp1 						: std_logic_vector(31 downto 0);
  signal s_temp2						: std_logic_vector(31 downto 0);
  
  --add signals for phase C:
  --IF/ID
  --inputs:
  signal s_iMem_toIFID 					: std_logic_vector(31 downto 0); 		-- input from Instruction Memory to IF/ID (Used in IMem)
  signal s_add4_toIFID 					: std_logic_vector(31 downto 0); 		-- PC+4 input for IF/ID (Used in AddFour)
  
  --outputs:
  signal s_iMem_fromIFID 				: std_logic_vector(31 downto 0); 		-- signal for iMem output from IF/ID
  signal s_add4_fromIFID 				: std_logic_vector(31 downto 0); 		-- signal for add4 output from IF/ID
  
  --ID/EX
  --inputs: 
  signal s_regData1_toIDEX 				: std_logic_vector(31 downto 0); 		-- input from Read Data 1 to ID/EX (Used in regFile)
  signal s_regData2_toIDEX 				: std_logic_vector(31 downto 0); 		-- input from Read Data 2 to ID/EX (Used in regFile)
  signal s_signExt_toIDEX 				: std_logic_vector(31 downto 0); 		-- input from Sign Extend to ID/EX
  signal s_Inst_toIDEX 					: std_logic_vector(31 downto 0); 		-- input from Instruction Memory to ID/EX
  signal s_PCPlus4_plusSLL2_toIDEX 		: std_logic_vector(31 downto 0);		-- signal for PC+4 + sll2
  signal s_PCPlus4_toIDEX 				: std_logic_vector(31 downto 0); 		-- signal for PC+4
  signal s_JumpAddr_toIDEX 				: std_logic_vector(31 downto 0);		-- signal for temp2
  signal s_ALUSrc_toIDEX 				: std_logic;							-- signal for ALUSrc
  signal s_ALUOp_toIDEX 				: std_logic_vector(3 downto 0);			-- signal for ALUOp input to ID/EX
  signal s_MemToReg_toIDEX 				: std_logic; 							-- signal for MemToReg input to ID/EX
  signal s_j_toIDEX 					: std_logic;							-- signal for Jump input to ID/EX
  signal s_jal_toIDEX 					: std_logic;							-- signal for JumpAndLink input to ID/EX
  signal s_beq_toIDEX 					: std_logic;							-- signal for BEQ input to ID/EX
  signal s_bne_toIDEX 					: std_logic;							-- signal for BNE input to ID/EX
  signal s_iMem_toIDEX 					: std_logic_vector(31 downto 0);		-- signal for InstrMem input to ID/EX  

  --outputs:
  signal s_jal_fromIDEX 				: std_logic; 							-- signal for jal output from ID/EX
  signal s_j_fromIDEX 					: std_logic; 							-- signal for j output from ID/EX
  signal s_bne_fromIDEX 				: std_logic; 							-- signal for bne output from ID/EX
  signal s_beq_fromIDEX 				: std_logic;							-- signal for beq output from ID/EX
  signal s_MemToReg_fromIDEX 			: std_logic;		 					-- signal for MemtoReg output from ID/EX
  signal s_ALUOp_fromIDEX 				: std_logic_vector(3 downto 0); 		-- signal for ALUOp output from ID/EX
  --THIS SIGNAL(vvv) IS ALWAYS SET TO 1
  --signal s_MemWr_fromIDEX : std_logic; 										-- signal for MemWr output from ID/EX
  signal s_ALUSrc_fromIDEX 				: std_logic;			 				-- signal for ALUSrc output from ID/EX
  signal s_RegData1_fromIDEX 			: std_logic_vector(31 downto 0); 		-- signal for RegData1 output from ID/EX
  signal s_RegData2_fromIDEX 			: std_logic_vector(31 downto 0); 		-- signal for RegData2 output from ID/EX
  signal s_signExt_fromIDEX 			: std_logic_vector(31 downto 0); 		-- signal for signExt output from ID/EX
  signal s_iMem_fromIDEX 				: std_logic_vector(31 downto 0); 		-- signal for InstrMem output from ID/EX
  signal s_PCPlus4_fromIDEX 			: std_logic_vector(31 downto 0);		-- signal for PC+4 output from ID/EX
  signal s_BranchAddr_fromIDEX 			: std_logic_vector(31 downto 0);		-- signal for Branch Address output from ID/EX
  signal s_JumpAddr_fromIDEX 			: std_logic_vector(31 downto 0);		-- signal for Jump Address output from ID/EX
  
  --EX/MEM
  --inputs:
  signal s_jal_toEXMEM 					: std_logic; 							-- signal for jal input from ID/EX output
  signal s_MemToReg_toEXMEM 			: std_logic; 							-- signal for MemtoReg input from ID/EX output
  --THIS SIGNAL(vvv) IS ALWAYS SET TO 1
  signal s_MemWr_toEXMEM 				: std_logic; 							-- signal for MemWr input from ID/EX output
  signal s_PCPlus4_toEXMEM 				: std_logic_vector(31 downto 0);		-- signal for PC+4 input from ID/EX output
  signal s_ALUOut_toEXMEM 				: std_logic_vector(31 downto 0); 		-- signal for ALUOut input
  signal s_RegData2_toEXMEM 			: std_logic_vector(31 downto 0); 		-- signal for regOutB(reg_out2) from ID/EX
	
  --outputs:
  signal s_jal_fromEXMEM 				: std_logic; 							-- signal for jal output from EX/MEM
  signal s_MemToReg_fromEXMEM 			: std_logic; 							-- signal for MemtoReg output from EX/MEM
  --THIS SIGNAL(vvv) IS ALWAYS SET TO 1
  signal s_MemWr_fromEXMEM 				: std_logic; 							-- signal for MemWr output from EX/MEM
  signal s_PCPlus4_fromEXMEM 			: std_logic_vector(31 downto 0);		-- signal for PC+4 output from PC+4
  signal s_ALUOut_fromEXMEM 			: std_logic_vector(31 downto 0); 		-- signal for ALUOut output from EX/MEM
  signal s_RegData2_fromEXMEM 			: std_logic_vector(31 downto 0); 		-- signal for RegOut2 output from EX/MEM
  
  --MEM/WB
  --inputs:
  signal s_jal_toMEMWB 					: std_logic; 							-- signal for jal output from EX/MEM
  signal s_MemtoReg_toMEMWB 			: std_logic; 							-- signal for MemtoReg output from EX/MEM
  signal s_PCPlus4_toMEMWB 				: std_logic_vector(31 downto 0); 		-- signal for PC+4 output from EX/MEM
  signal s_ReadDataMemWr_toMEMWB 		: std_logic_vector(31 downto 0); 		-- signal for Read_Data_MemWr from EX/MEM
  signal s_ALUOut_toMEMWB 				: std_logic_vector(31 downto 0); 		-- signal for ALUOut from EX/MEM
  
  --outputs:
  signal s_jal_fromMEMWB 				: std_logic;							-- signal for jal output from MEM/WB
  signal s_MemtoReg_fromMEMWB 			: std_logic; 							-- signal for MemtoReg output from MEM/WB
  signal s_PCPlus4_fromMEMWB 			: std_logic_vector(31 downto 0); 		-- signal for PC+4 output from MEM/WB
  signal s_ReadDataMemWr_fromMEMWB 		: std_logic_vector(31 downto 0); 		-- signal for Read_Data_MemWr output from MEM/WB 
  signal s_ALUOut_fromMEMWB 			: std_logic_vector(31 downto 0); 		-- signal for ALUOut output from MEM/WB
  
begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;

  IMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  s_iMem_toIFID <= s_Inst; --where do we add this in?
  
  DMem: mem
    generic map(ADDR_WIDTH => 10,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);
			 

  s_Halt <='1' when (s_Inst(31 downto 26) = "000000") and (s_Inst(5 downto 0) = "001100") and (v0 = "00000000000000000000000000001010") else '0';

  -- TODO: Implement the rest of your processor below this comment! 
  MemToReg_Mux: MUX21_structN
  generic map(N => N)
  port map(
    A => s_ReadDataMemWr_fromMEMWB,
    B => s_ALUOut_fromMEMWB,
    S => s_MemtoReg_fromMEMWB,
    Q => s_MemToRegMuxOut --Changed it to fit phase II, changed from s_RegWrData
  );
	
  ALU : MIPS_ALU
  port map(
	shamt => s_iMem_fromIDEX, --Added as a way to keep track of shamt
    i_A => s_RegData1_fromIDEX,
    i_B => s_ALUSrcMuxOut,
    select_ALU => s_ALUOp_fromIDEX,
    Zero => s_ALUZeroOut,
    data_out => s_DMemAddr,
    c_out =>s_ALUCarryOut
  );
  
  --s_DMemAddr <= s_ALUout;
  oALUout <= s_DMemAddr; --Assign ALU output to oALUout for syntheis purposes

  ALUSrc_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_signExt_fromIDEX,
    B => s_RegData2_fromIDEX,
    S => s_ALUSrc_fromIDEX,
    Q => s_ALUSrcMuxOut
  );

  SignExtend : extender
  port map(
    signal_extend => s_isExtendSigned,
    d_in => s_iMem_fromIFID(15 downto 0),
    d_out => s_SignExtendOut
  );

  RegDst_Mux: MUX21_structN
  generic map(N => 5)
  port map(
    A => s_iMem_fromIFID(15 downto 11),
    B => s_iMem_fromIFID(20 downto 16),
    S => s_RegDst,
    Q => s_RegWrAddrIntermed
  );


  RegDst_Final_Mux: MUX21_structN
  generic map(N => 5)
  port map(
	A => "11111",
	B => s_RegWrAddrIntermed,
	S => s_jal,
	Q => s_RegWrAddr
  );
  
  PC : PC_reg --Changed to PC_reg instead of register_Nbits (11/4/2020)
  generic map(N => N)
  port map(
    i_clk => iCLK,
    i_RST => iRST,
    i_WE => '1',
    i_D => s_JrMuxOut,  --Changed to support s_jr, previously s_PCPlusFourOut
    o_Q => s_NextInstAddr
  );

  Control : CLM --TODO update CLM
  port map(
		opcode			=> s_iMem_fromIFID(31 downto 26),
		funct			=> s_iMem_fromIFID(5 downto 0),
		ALUSrc 			=> s_ALUSrc_toIDEX,
		ALUControl 		=> s_ALUOp_toIDEX,
		MemtoReg		=> s_MemToReg_toIDEX,
		s_DMemWr		=> s_DMemWr, 						--leave it b/c DMemWr is hardcoded to 1
		s_RegWr			=> s_RegWr,
		RegDst			=> s_RegDst,
		Jump			=> s_j_toIDEX,
		JumpReg			=> s_jr,
		JumpNLink		=> s_jal, 							--MAKE SIGNAL FOR JAL_TOIDEX(DONE) AND ASSIGN BELOW?
		BranchEqual		=> s_beq_toIDEX,
		BranchNotEqual	=> s_bne_toIDEX,
		isExtendSigned 	=> s_isExtendSigned,
		MemRead 		=> s_MemReadEnable 					--Not being used in Proj B, here for future reference
  ); 
  
  s_jal_toIDEX <= s_jal; --set up input to IDEX with s_jal

  RegisterFile : regfile
  port map(
    clk => iCLK,
    rst => iRST,
    reg_write_en => s_RegWr,
    reg_write_dest => s_RegWrAddr,
    reg_write_data => s_RegWrData,
    reg_read_addrA => s_iMem_fromIFID(25 downto 21),
    reg_read_addrB => s_iMem_fromIFID(20 downto 16),
    reg_out_dataA => s_regData1_toIDEX,
    reg_out_dataB => s_regData2_toIDEX,
    reg2_out => v0
  );

  s_DMemData <= s_RegFileReadAddress2;

  AddFour : FA_struct
  generic map(N => N)
  port map(
    Cin => '0',
    A => s_NextInstAddr,
    B => x"00000004",
    Cout => s_DummyCout,
    Sum => s_add4_toIFID
  );

  --Phase II starts here
  --Beginning of Jump Logic
  s_temp1 <= b"00000011111111111111111111111111" and s_iMem_fromIFID;
  ShiftLeftTwo_Instruction : BarrelShifter
  port map(
    data_in =>  s_temp1,
    isSigned => '0',
    left_shift => '1',
    shamt => b"00010",
    data_out =>  s_ShiftLeftTwoInstructionOut
  );

  s_temp2 <= ( s_add4_fromIFID and x"10000000" ) or s_ShiftLeftTwoInstructionOut;
  Jump_Mux : MUX21_structN 
  generic map(N => N)
  port map(
    A =>  s_JumpAddr_fromIDEX, 	--A represents 1 in the MUX
    B =>  s_BranchMuxOut, 		--B represents 0 in the Mux
    S =>  s_j_fromIDEX,
    Q =>  s_JumpMuxOut
  );
  
  Jr_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_RegFileReadAddress1,
    B => s_JumpMuxOut,
    S => s_jr,
    Q => s_JrMuxOut
  );

  --Beginning of Branch logic
  ShiftLeftTwo_SignExtend : BarrelShifter
  port map(
    data_in =>  s_SignExtendOut,
    isSigned => '0',
    left_shift => '1',
    shamt => b"00010",
    data_out =>  s_ShiftLeftTwoSignExtended
  );

  BranchAdder : FA_struct
  generic map(N => N)
  port map(
    Cin => '0',
    A => s_add4_fromIFID,
    B => s_ShiftLeftTwoSignExtended,
    Cout => s_groundout,
    Sum => s_BranchAdderOut
  );

  BranchLogicBlock : BranchLogic
  port map(
    BranchOnEqual_in    => s_beq_fromIDEX,
    BranchOnNotEqual_in => s_bne_fromIDEX,
    ComparingBit        => s_ALUZeroOut,
    BranchSignal_out    => s_BranchLogicOut
  );

  Branch_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_BranchAddr_fromIDEX,
    B => s_PCPlus4_fromIDEX,
    S => s_BranchLogicOut,
    Q => s_BranchMuxOut
  );

  --Beginning of jal logic
  Jal_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_PCPlus4_fromMEMWB,
    B => s_MemToRegMuxOut,
    S => s_jal_fromMEMWB,
    Q => s_RegWrData
  );
  
  --Phase C Logic: FOR MISSING SIGNALS, ADD IN SIGNALS FROM THIS FILE
  
  g_ifid: if_id
  port map(	i_CLK 				=>	iCLK,							-- Clock Input
			i_RST_IFID 			=>	iRST,							-- Reset Input (Can be used as the Flush input)
			i_WE_IFID 			=>	s_RegWr,						-- Write Enable Input
			-- these are specific to IF/ID --------------------------------------------------------
			i_PCplusFOUR		=>	s_add4_toIFID,					-- PC+4(From PC)
			i_MEM_IFID			=>	s_iMem_toIFID,					-- Instruction Memory(From IMEM)
			--Outputs:-----------------------------------------------------------------------------
			o_PCplusFOUR		=>	s_add4_fromIFID,				-- PC+4(From PC)
			o_MEM_IFID			=>	s_iMem_fromIFID);				-- Instruction Memory(From IMEM)
  
  --make output signals from IF/ID match input signals to ID/EX
  s_PCPlus4_toIDEX	<= s_add4_fromIFID;
  
  --make output signals from EX/MEM match input signals from Diagram
  s_iMem_toIDEX		<=	s_iMem_fromIFID;

  --Prepping for ID/EX:
  s_signExt_toIDEX 	<=	s_SignExtendOut; --set sign extender signal for ID/EX
  
  g_idex: id_ex
  port map(	i_CLK 				=>	iCLK,							-- Clock Input
			i_RST_IDEX 			=>	iRST,							-- Reset Input
			i_WE_IDEX 			=>	s_RegWr,						-- Write Enable Input
			--These are for just ID/EX ----------------------------------------------------------
			i_JAL_IDEX 			=>	s_jal_toIDEX,					-- Jal Instruction
			i_J_IDEX 			=>	s_Jump,							-- J Instruction
			i_BNE_IDEX			=>	s_BranchOnNotEqual,				-- Bne Instruction
			i_BEQ_IDEX			=>	s_BranchOnEqual,				-- Beq Instruction
			i_MEMTOREG_IDEX		=>	s_MemToReg,						-- MemToReg Instruction
			i_MEMWR_IDEX		=>	'1',							-- MemWrite Instruction, don't need stall signal implementation
			i_ALUOP_IDEX		=>	s_ALUOP,						-- ALU_OP Instruction
			i_ALUSRC_IDEX		=>	s_ALUSrc,						-- ALU_Src Instruction
			i_BRANCH_ADDR_IDEX 	=>	s_BranchAdderOut,				-- Branch Addr.
			i_JUMP_ADDR_IDEX 	=>	s_temp2,						-- Jump Addr.
			i_SIGN_EXT_IDEX		=>	s_signExt_toIDEX,				-- PC+4 and SignExtend
			i_READ_DATA1_IDEX	=>	s_regData1_toIDEX,				-- Read Data 1
			i_READ_DATA2_IDEX	=>	s_regData2_toIDEX,				-- Read Data 2
			i_PC_PLUS_4_IDEX 	=>	s_PCPlus4_toIDEX,				-- PC+4
			i_Instruction		=>	s_iMem_fromIFID,				-- Instruction Memory
			--Outputs:---------------------------------------------------------------------------
			o_JAL_IDEX 			=>	s_jal_fromIDEX,					-- Jal Instruction
			o_J_IDEX 			=>	s_j_fromIDEX,					-- J Instruction
			o_BNE_IDEX			=>	s_bne_fromIDEX,					-- Bne Instruction
			o_BEQ_IDEX			=>	s_beq_fromIDEX,					-- Beq Instruction
			o_MEMTOREG_IDEX		=>	s_MemToReg_fromIDEX,			-- MemToReg Instruction
			o_MEMWR_IDEX		=>	s_MemWr_toEXMEM,				-- MemWrite Instruction
			o_ALUOP_IDEX		=>	s_ALUOp_fromIDEX,				-- ALU_OP Instruction
			o_ALUSRC_IDEX		=>	s_ALUSrc_fromIDEX ,				-- ALU_Src Instruction
			o_BRANCH_ADDR_IDEX 	=>	s_BranchAddr_fromIDEX,			-- Branch Addr.
			o_JUMP_ADDR_IDEX 	=>	s_JumpAddr_fromIDEX,			-- Jump Addr.
			o_SIGN_EXT_IDEX		=>	s_signExt_fromIDEX,				-- PC+4 and SignExtend
			o_READ_DATA1_IDEX	=>	s_RegData1_fromIDEX,			-- Read Data 1
			o_READ_DATA2_IDEX	=>	s_RegData2_fromIDEX,			-- Read Data 2
			o_PC_PLUS_4_IDEX 	=>	s_PCPlus4_fromIDEX,				-- PC+4
			o_Instruction		=>	s_iMem_fromIDEX);				-- Instruction Memory(This 
  
    --make output signals from ID/EX match input signals to EX/MEM
	s_jal_toEXMEM 		<= 	s_jal_fromIDEX;
	s_MemToReg_toEXMEM 	<= 	s_MemToReg_fromIDEX;
	s_PCPlus4_toEXMEM	<=	s_PCPlus4_fromIDEX;
	s_RegData2_toEXMEM	<=	s_RegData1_fromIDEX;
	
  g_exmem: ex_mem
  port map(	i_CLK 				=>	iCLK,							-- Clock Input
			i_RST_EXMEM			=>	iRST,							-- Reset Input
			i_WE_EXMEM 			=>	s_RegWr,						-- Write Enable Input
			-- INPUT PORTS FOR EX-MEM--------------------------------------------------------------
			i_JAL_EXMEM 		=>	s_jal_toEXMEM,					-- Jal Instruction
			i_MEMTOREG_EXMEM	=>	s_MemToReg_toEXMEM,				-- MemToReg Instruction
			i_MEMWR_EXMEM		=>	'1',							-- MemWrite Instruction
			i_PC_PLUS_4_EXMEM 	=>	s_PCPlus4_toEXMEM,				-- PC+4
			i_ALU_OUT_EXMEM		=>	s_ALUOut_toEXMEM,				-- input fromt the ALU output
			i_READ_DATA2_EXMEM	=>	s_RegData2_fromIDEX,			-- Read Data 2 
			-- OUTPUT PORTS FOR EX-MEM-------------------------------------------------------------
			o_JAL_EXMEM 		=>	s_jal_fromEXMEM,				-- Jal Instruction
			o_MEMTOREG_EXMEM	=>	s_MemToReg_fromEXMEM,			-- MemToReg Instruction
			o_MEMWR_EXMEM		=>	s_MemWr_fromEXMEM,				-- MemWrite Instruction
			o_PC_PLUS_4_EXMEM 	=>	s_PCPlus4_fromEXMEM,			-- PC+4
			o_ALU_OUT_EXMEM		=>	s_ALUOut_fromEXMEM,				-- input fromt the ALU output
			o_READ_DATA2_EXMEM	=>	s_RegData2_fromEXMEM);			-- Read Data 2
  
    --make output signals from EX/MEM match input signals to MEM/WB
	s_jal_toMEMWB			<=	s_jal_fromEXMEM;
	s_MemtoReg_toMEMWB		<=	s_MemToReg_fromEXMEM;
	s_PCPlus4_toMEMWB		<=	s_PCPlus4_fromEXMEM;
	s_ReadDataMemWr_toMEMWB	<=	s_RegData2_fromEXMEM;
	s_ALUOut_toMEMWB		<=	s_ALUOut_fromEXMEM;
	
	--make output signals from EX/MEM match input signals from Diagram
	s_DMemWr 	<=	s_MemWR_fromEXMEM; 
	s_DMemAddr	<=	s_ALUOut_fromEXMEM;
	s_DMemData	<=	s_RegData2_fromEXMEM;
	--Prep for MEM/WB:
	s_ALUOut_toMEMWB <=	s_DMemOut;
	
  g_memwb: mem_wb
  port map(	i_CLK 				=> 	iCLK,							-- Clock Input
			i_RST_MEMWB			=>	iRST, 							-- Reset Input
			i_WE_MEMWB 			=>	s_RegWr,						-- Write Enable Input
			-- INPUT PORTS FOR MEM-WB--------------------------------------------------------------
			i_JAL_MEMWB 		=>	s_jal_toMEMWB,					-- Jal Instruction
			i_MEMTOREG_MEMWB 	=>	s_MemtoReg_toMEMWB,				-- MemToReg Instruction
			i_PC_PLUS_4_MEMWB 	=>	s_PCPlus4_toMEMWB,				-- PC+4
			i_MEMWR_READ_MEMWB 	=>	s_ReadDataMemWr_toMEMWB,		-- input fromt the ALU output
			i_ALU_OUT_MEMWB		=>	s_ALUOut_toMEMWB,				-- Read Data 2
			-- OUTPUT PORTS FOR MEM-WB-------------------------------------------------------------
			o_JAL_MEMWB 		=> 	s_jal_fromMEMWB,				-- Jal Instruction
			o_MEMTOREG_MEMWB 	=>	s_MemtoReg_fromMEMWB,			-- MemToReg Instruction
			o_PC_PLUS_4_MEMWB 	=>	s_PCPlus4_fromMEMWB,			-- PC+4
			o_MEMWR_READ_MEMWB 	=>	s_ReadDataMemWr_fromMEMWB,		-- input fromt the ALU output
			o_ALU_OUT_MEMWB		=>	s_ALUOut_fromMEMWB);			-- Read Data 
			
  
end structure;
