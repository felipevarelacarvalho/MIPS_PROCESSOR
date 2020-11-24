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
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal v0             : std_logic_vector(N-1 downto 0); -- TODO: should be assigned to the output of register 2, used to implement the halt SYSCALL
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. This case happens when the syscall instruction is observed and the V0 register is at 0x0000000A. This signal is active high and should only be asserted after the last register and memory writes before the syscall are guaranteed to be completed.

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
    port(i_CLK 			    : in std_logic; 						-- Clock Input
      i_RST_IFID 	    : in std_logic; 						-- Reset Input (Can be used as the Flush input)
      i_WE_IFID 		    : in std_logic; 						-- Write Enable Input
      -- these are specific to IF/ID --------------------------------------------------------
      --i_FLUSH_IFID	: in std_logic;							-- Flush Enable(Comes from CLM)
      i_PCplusFOUR_IFID	: in std_logic_vector(N-1 downto 0);	-- PC+4(From PC)
      i_MEM_IFID		    : in std_logic_vector(N-1 downto 0);	-- Instruction Memory(From IMEM)
      ---------------------------------------------------------------------------------------
      o_PCplusFOUR_IFID	: out std_logic_vector(N-1 downto 0);	-- PC+4(From PC)
      o_MEM_IFID		    : out std_logic_vector(N-1 downto 0));	-- Instruction Memory(From IMEM)
  end component;

  component id_ex is
    generic(N : integer := 32);
    port(i_CLK 				: in std_logic; 						-- Clock Input
      i_RST_IDEX 		: in std_logic; 						-- Reset Input
      i_WE_IDEX 			: in std_logic; 						-- Write Enable Input
      --These are for just ID/EX ------------------------------------------------------
      i_JAL_IDEX 		: in std_logic;							-- Jal Instruction
      i_MEMTOREG_IDEX	: in std_logic;							-- MemToReg Instruction
      i_MEMWR_IDEX		: in std_logic;							-- MemWrite Instruction
      i_ALUOP_IDEX		: in std_logic_vector(3 downto 0);		-- ALU_OP Instruction
      i_ALUSRC_IDEX		: in std_logic;							-- ALU_Src Instruction
      i_RegWr_IDEX       : in std_logic;							-- Register Write to go to Write phase (Added 11/19/20)
      i_SIGN_EXT_IDEX	: in std_logic_vector(N-1 downto 0);	-- PC+4 and SignExtend
      i_READ_DATA1_IDEX	: in std_logic_vector(N-1 downto 0);	-- Read Data 1
      i_READ_DATA2_IDEX	: in std_logic_vector(N-1 downto 0);	-- Read Data 2
      i_PC_PLUS_4_IDEX 	: in std_logic_vector(N-1 downto 0);	-- PC+4
      i_Instruction_IDEX : in std_logic_vector(N-1 downto 0);    --Instruction coming from Imem
      i_WriteRegAddr_IDEX: in std_logic_vector(4 downto 0);   --Write register address
      ---------------------------------------------------------------------------------
      o_JAL_IDEX 		: out std_logic;							-- Jal Instruction
      o_MEMTOREG_IDEX	: out std_logic;							-- MemToReg Instruction
      o_MEMWR_IDEX		: out std_logic;							-- MemWrite Instruction
      o_ALUOP_IDEX		: out std_logic_vector(3 downto 0);		-- ALU_OP Instruction
      o_ALUSRC_IDEX		: out std_logic;							-- ALU_Src Instruction
      o_RegWr_IDEX       : out std_logic;							-- Register Write to go to Write phase (Added 11/19/20
      o_SIGN_EXT_IDEX	: out std_logic_vector(N-1 downto 0);	-- PC+4 and SignExtend
      o_READ_DATA1_IDEX	: out std_logic_vector(N-1 downto 0);	-- Read Data 1
      o_READ_DATA2_IDEX	: out std_logic_vector(N-1 downto 0);	-- Read Data 2
      o_PC_PLUS_4_IDEX 	: out std_logic_vector(N-1 downto 0);	-- PC+4
      o_Instruction_IDEX : out std_logic_vector(N-1 downto 0);   --intruction to be passed to the ALU
      o_WriteRegAddr_IDEX: out std_logic_vector(4 downto 0));   --Write register address
  end component;

  component ex_mem is
    generic(N : integer := 32);
    port(i_CLK 			: in std_logic; 						-- Clock Input
      i_RST_EXMEM	: in std_logic; 						-- Reset Input
      i_WE_EXMEM     : in std_logic; 						-- Write Enable Input
      -- INPUT PORTS FOR EX-MEM
      i_JAL_EXMEM 		: in std_logic;							-- Jal Instruction
      i_MEMTOREG_EXMEM	: in std_logic;							-- MemToReg Instruction
      i_MEMWR_EXMEM		: in std_logic;							-- MemWrite Instruction
      i_RegWr_EXMEM      : in std_logic;							-- Register Write to go to Write phase (Added 11/19/20)
      i_PC_PLUS_4_EXMEM 	: in std_logic_vector(N-1 downto 0);	-- PC+4
      i_ALU_OUT_EXMEM	: in std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
      i_READ_DATA2_EXMEM	: in std_logic_vector(N-1 downto 0);	-- Read Data 2
      i_WriteRegAddr_EXMEM: in std_logic_vector(4 downto 0);   --Write register address
      -- OUTPUT PORTS FOR EX-MEM
      o_JAL_EXMEM 		: out std_logic;							-- Jal Instruction
      o_MEMTOREG_EXMEM	: out std_logic;							-- MemToReg Instruction
      o_MEMWR_EXMEM		: out std_logic;							-- MemWrite Instruction
      o_RegWr_EXMEM      : out std_logic;							-- Register Write to go to Write phase (Added 11/19/20
      o_PC_PLUS_4_EXMEM 	: out std_logic_vector(N-1 downto 0);	-- PC+4
      o_ALU_OUT_EXMEM	: out std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
      o_READ_DATA2_EXMEM	: out std_logic_vector(N-1 downto 0);	-- Read Data 2
      o_WriteRegAddr_EXMEM: out std_logic_vector(4 downto 0));   --Write register address 
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
	    i_RegWr_MEMWB        : in std_logic;							-- Register Write to go to Write phase (Added 11/19/20)
      i_PC_PLUS_4_MEMWB 	: in std_logic_vector(N-1 downto 0);	-- PC+4
      i_MEM_READ_MEMWB	: in std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
      i_ALU_OUT_MEMWB		: in std_logic_vector(N-1 downto 0);	-- Read Data 2
	    i_WriteRegAddr_MEMWB : in std_logic_vector(N-1 downto 0);    --Write register address
      -- OUTPUT PORTS FOR MEM-WB
      o_JAL_MEMWB 			: out std_logic;						-- Jal Instruction
      o_MEMTOREG_MEMWB		: out std_logic;						-- MemToReg Instruction
	    o_RegWr_MEMWB        : out std_logic;					    -- Register Write to go to Write phase (Added 11/19/20
      o_PC_PLUS_4_MEMWB 	: out std_logic_vector(N-1 downto 0);	-- PC+4
      o_MEM_READ_MEMWB	: out std_logic_vector(N-1 downto 0);	-- input fromt the ALU output
      o_ALU_OUT_MEMWB		: out std_logic_vector(N-1 downto 0);	-- Read Data 2
	    o_WriteRegAddr_MEMWB : out std_logic_vector(N-1 downto 0));  --Write register address
  end component;

  -------------------------------------------------------------------------------------------------------
  --Additional Signals
  -------------------------------------------------------------------------------------------------------
  --IF stage signals
  signal s_RegFileReadAddress1Out           : std_logic_vector(31 downto 0); --Output of ALU Register A (aka register 1)
  signal s_RegFileReadAddress2Out           : std_logic_vector(31 downto 0); --Output of ALU Register B (aka register 2)
  signal s_JumpMuxOut                       : std_logic_vector(31 downto 0); --Output of Jump mux
  signal s_JrMuxOut                         : std_logic_vector(31 downto 0); --Output of Jump Register mux
  signal s_PCPlusFourOut                    : std_logic_vector(31 downto 0); --Output of PC+4
  signal s_PCPlusFour_from_IFID             : std_logic_vector(31 downto 0); --Output from IFID pipeline with PC+4 data
  signal s_Instruction_from_IFID            : std_logic_vector(31 downto 0); --Output from IFID pipeline with Instruction data
  signal s_PCsrcMuxOut                      : std_logic_vector(31 downto 0); --Output from PCsrc Mux
      
  --ID stage signals      
  signal s_ShiftTwo_Input                   : std_logic_vector(31 downto 0); -- Input for shift left two of instruction that only get the 26 least signinficant bits
  signal s_ShiftLeftTwoInstructionOut       : std_logic_vector(31 downto 0); -- Output from shift left two of instruction
  signal s_JumpAddress_Input                : std_logic_vector(31 downto 0); -- Input for jump mux select 1. This has the four most significant bits of PC+4
  signal s_BranchMuxOut                     : std_logic_vector(31 downto 0); -- Output of branch mux with branch address. Serves as input for jump mux select 0
  signal s_ShiftLeftTwoSignExtendedOut      : std_logic_vector(31 downto 0); -- Output of Shift left two of sign extended.
  signal s_BranchAdderOut                   : std_logic_vector(31 downto 0); -- Output of Branch adder
  signal s_SignExtendOut                    : std_logic_vector(31 downto 0); -- Output of Sign Extender
  signal s_AreOutputsEqual                  : std_logic;                     -- Signal that carries information 1 if outputs of the ALU are equal
  signal s_BranchLogicOut                   : std_logic;                     -- Output of Branch Logic block
  signal s_RegDstMuxOut                     : std_logic_vector(4  downto 0); -- Output of Register Destination Mux. Serves as 0 input for the jump and link register mux
  signal s_JalRegisterMuxOut                : std_logic_vector(4  downto 0); -- Output from the mux right before register. This contains the register write address
  signal s_JAL_from_IDEX                    : std_logic;                     
  signal s_MemToReg_from_IDEX               : std_logic;
  signal s_DMemWr_from_IDEX                 : std_logic;
  signal s_ALUOp_from_IDEX                  : std_logic_vector(3  downto 0);
  signal s_ALUSrc_from_IDEX                 : std_logic;
  signal s_RegWr_from_IDEX                  : std_logic;
  signal s_SignExtend_from_IDEX             : std_logic_vector(31 downto 0);
  signal s_RegFileReadAddress1Out_from_IDEX : std_logic_vector(31 downto 0);
  signal s_RegFileReadAddress2Out_from_IDEX : std_logic_vector(31 downto 0);
  signal s_PCPlusFour_from_IDEX             : std_logic_vector(31 downto 0);
  signal s_Instruction_from_IDEX            : std_logic_vector(31 downto 0);
  signal s_RegWrAddr_from_IDEX              : std_logic_vector(4  downto 0);

  --EX stage signals
  signal s_ALUSrcMuxOut                     : std_logic_vector(31 downto 0);
  signal s_ALUout                           : std_logic_vector(31 downto 0);
  signal s_JAL_from_EXMEM                   : std_logic;
  signal s_MemToReg_from_EXMEM              : std_logic;
  signal s_DMemWr_from_EXMEM                : std_logic;
  signal s_RegWr_from_EXMEM                 : std_logic;
  signal s_PCPlusFour_from_EXMEM            : std_logic_vector(31 downto 0);
  signal s_ALUOut_from_EXMEM                : std_logic_vector(31 downto 0);
  signal s_RegFileReadAddress2Out_from_EXMEM: std_logic_vector(31 downto 0);
  signal s_RegWrAddr_from_EXMEM             : std_logic_vector(4  downto 0);

  --MEM stage signals
  signal s_JAL_from_MEMWB                   : std_logic;
  signal s_MemToReg_from_MEMWB              : std_logic;
  signal s_RegWr_from_MEMWB                 : std_logic;
  signal s_PCPlusFour_from_MEMWB            : std_logic_vector(31 downto 0);
  signal s_DMemOut_from_MEMWB               : std_logic_vector(31 downto 0);
  signal s_ALUOut_from_MEMWB                : std_logic_vector(31 downto 0);
  signal s_RegWrAddr_from_MEMWB             : std_logic_vector(4  downto 0);

  --WB stage signals
  signal s_MemToRegMuxOut                   : std_logic_vector(31 downto 0);

  --CLM Signals
  signal s_Jr                          : std_logic;                     --Signal for select line jump register mux 
  signal s_J                           : std_logic;                     --Signal for select line jump mux
  signal s_BNE                         : std_logic;                     --Signal for Branch on not equal
  signal s_BEQ                         : std_logic;                     --Signal for Branch on equal
  signal s_ALUSrc                      : std_logic;                     --Signal for ALU Source
  signal s_ALUOp                       : std_logic_vector(3 downto 0);  --Signal for the Op code going to the ALU
  signal s_MemToReg                    : std_logic;                     --Signal for Memory to Register
  signal s_DMemWr_CLM                  : std_logic;                     --Signal from Memory Write Enable
  signal s_RegWr_CLM                   : std_logic;                     --Signal for Register Write Enable
  signal s_RegDst                      : std_logic;                     --Signal for register destination Mux
  signal s_JAL                         : std_logic;                     --Signal gor jump and Link    
  signal s_isExtendSigned              : std_logic;                     --Signal if Extension is Signed
  signal s_MemReadEnable               : std_logic;                     --Not being used in ProjC

  
  
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
  
  --IF stage
  -------------------------------------------------------------------------------------------------------
  Jr_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_RegFileReadAddress1Out,
    B => s_JumpMuxOut,
    S => s_jr,
    Q => s_JrMuxOut
  );

  PCsrc_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_JrMuxOut, 
    B => s_PCPlusFourOut,
    S => (s_J or s_Jr or s_BranchLogicOut),
    Q => s_PCsrcMuxOut
  );

  PC : PC_reg --Changed to PC_reg instead of register_Nbits (11/4/2020)
  generic map(N => N)
  port map(
    i_clk => iCLK,
    i_RST => iRST,
    i_WE  => '1',
    i_D   => s_PCsrcMuxOut,  
    o_Q   => s_NextInstAddr
  );

  --Imem block declared up above in the code

  AddFour : FA_struct
  generic map(N => N)
  port map(
    Cin    => '0',
    A     => s_NextInstAddr,
    B     => x"00000004",
    Cout  => open,
    Sum   => s_PCPlusFourOut
  );

  IFID : if_id
  generic map(N => N)
  port map(
    i_CLK             => iCLK,
    i_RST_IFID        => iRST,
    i_WE_IFID         =>'1',
    -----------------------------------
    i_PCplusFOUR_IFID	=> s_PCPlusFourOut,
    i_MEM_IFID        => s_Inst,
    ------------------------------------
    o_PCplusFOUR_IFID	=> s_PCPlusFour_from_IFID,
    o_MEM_IFID		    => s_Instruction_from_IFID
    );


  --ID stage
  -------------------------------------------------------------------------------------------------------
  --Control Logic Module
  Control : CLM
  port map(
		opcode		    	=> s_Instruction_from_IFID(31 downto 26),
		funct			      => s_Instruction_from_IFID(5 downto 0),
		ALUSrc 		    	=> s_ALUSrc, 
		ALUControl     	=> s_ALUOp,
		MemtoReg	    	=> s_MemToReg,
		s_DMemWr	    	=> s_DMemWr_CLM, 						--leave it b/c DMemWr is hardcoded to 1
		s_RegWr		    	=> s_RegWr_CLM,
		RegDst		    	=> s_RegDst,
		Jump			      => s_J,
		JumpReg		    	=> s_Jr,
		JumpNLink	    	=> s_JAL, 							
		BranchEqual		  => s_BEQ,
		BranchNotEqual	=> s_BNE,
		isExtendSigned 	=> s_isExtendSigned,
		MemRead 		    => s_MemReadEnable 					--Not being used in Proj B, here for future reference
  ); 
  

  --Jump Logic
  s_ShiftTwo_Input  <= b"00000011111111111111111111111111" and s_Instruction_from_IFID;
  ShiftLeftTwo_Instruction : BarrelShifter
  port map(
    data_in    =>  s_ShiftTwo_Input,
    isSigned   => '0',
    left_shift => '1',
    shamt      => b"00010",
    data_out   =>  s_ShiftLeftTwoInstructionOut
  );

  s_JumpAddress_Input <= (s_PCPlusFour_from_IFID and x"10000000" ) or s_ShiftLeftTwoInstructionOut;
  Jump_Mux : MUX21_structN 
  generic map(N => N)
  port map(
    A =>  s_JumpAddress_Input, 	--A represents 1 in the MUX
    B =>  s_BranchMuxOut, 		  --B represents 0 in the Mux
    S =>  s_J,
    Q =>  s_JumpMuxOut
  );

  --Branch Logic
  ShiftLeftTwo_SignExtend : BarrelShifter
  port map(
    data_in    =>  s_SignExtendOut,
    isSigned   => '0',
    left_shift => '1',
    shamt      => b"00010",
    data_out   =>  s_ShiftLeftTwoSignExtendedOut
  );

  BranchAdder : FA_struct
  generic map(N => N)
  port map(
    Cin  => '0',
    A    => s_PCPlusFour_from_IFID,
    B    => s_ShiftLeftTwoSignExtendedOut,
    Cout => open,
    Sum  => s_BranchAdderOut
  );

  s_AreOutputsEqual <= '1' when s_RegFileReadAddress1Out = s_RegFileReadAddress2Out else '0'; --Signal use to compare both inputs as equal for the branch logic
  BranchLogicBlock : BranchLogic
  port map(
    BranchOnEqual_in    => s_BEQ,
    BranchOnNotEqual_in => s_BNE,
    ComparingBit        => s_AreOutputsEqual, 
    BranchSignal_out    => s_BranchLogicOut
  );

  Branch_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_BranchAdderOut,
    B => s_PCPlusFour_from_IFID,
    S => s_BranchLogicOut,
    Q => s_BranchMuxOut
  );

  --Sign Extension Logic
  SignExtend : extender
  port map(
    signal_extend => s_isExtendSigned,
    d_in          => s_Instruction_from_IFID(15 downto 0),
    d_out         => s_SignExtendOut
  );

  --Register File Logic
  RegDst_Mux: MUX21_structN
  generic map(N => 5)
  port map(
    A => s_Instruction_from_IFID(15 downto 11),
    B => s_Instruction_from_IFID(20 downto 16),
    S => s_RegDst,
    Q => s_RegDstMuxOut
  );

  Jal_Register_Mux: MUX21_structN
  generic map(N => 5)
  port map(
	A => "11111",
	B => s_RegDstMuxOut,
	S => s_JAL,
	Q => s_JalRegisterMuxOut
  );

  RegisterFile : regfile
  port map(
    clk            => iCLK,
    rst            => iRST,
    reg_write_en   => s_RegWr,      -- This data will come from the WB stage
    reg_write_dest => s_RegWrAddr,  -- This data will come from the WB stage
    reg_write_data => s_RegWrData,  -- This data will come from the WB stage
    reg_read_addrA => s_Instruction_from_IFID(25 downto 21),
    reg_read_addrB => s_Instruction_from_IFID(20 downto 16),
    reg_out_dataA  => s_RegFileReadAddress1Out,
    reg_out_dataB  => s_RegFileReadAddress2Out,
    reg2_out       => v0
  );

  --IDEX pipeline logic
  IDEX : id_ex
  generic map(N => N)
  port map(
    i_CLK 				       => iCLK,
    i_RST_IDEX 		       => iRST,
    i_WE_IDEX 	         => '1',
    --------------------------------------------
    i_JAL_IDEX 		       => s_JAL,
    i_MEMTOREG_IDEX	     => s_MemToReg,
    i_MEMWR_IDEX		     => s_DMemWr_CLM,
    i_ALUOP_IDEX		     => s_ALUOp,
    i_ALUSRC_IDEX		     => s_ALUSrc,
    i_RegWr_IDEX         => s_RegWr_CLM,
    i_SIGN_EXT_IDEX	     => s_SignExtendOut,
    i_READ_DATA1_IDEX	   => s_RegFileReadAddress1Out,
    i_READ_DATA2_IDEX	   => s_RegFileReadAddress2Out,
    i_PC_PLUS_4_IDEX 	   => s_PCPlusFour_from_IFID,
    i_Instruction_IDEX   => s_Instruction_from_IFID,
    i_WriteRegAddr_IDEX  => s_JalRegisterMuxOut,
    --------------------------------------------
    o_JAL_IDEX 		       => s_JAL_from_IDEX,
    o_MEMTOREG_IDEX	     => s_MemToReg_from_IDEX,
    o_MEMWR_IDEX		     => s_DMemWr_from_IDEX,
    o_ALUOP_IDEX		     => s_ALUOp_from_IDEX,
    o_ALUSRC_IDEX		     => s_ALUSrc_from_IDEX,
    o_RegWr_IDEX         => s_RegWr_from_IDEX,
    o_SIGN_EXT_IDEX	     => s_SignExtend_from_IDEX,
    o_READ_DATA1_IDEX	   => s_RegFileReadAddress1Out_from_IDEX,
    o_READ_DATA2_IDEX	   => s_RegFileReadAddress2Out_from_IDEX,
    o_PC_PLUS_4_IDEX 	   => s_PCPlusFour_from_IDEX,
    o_Instruction_IDEX   => s_Instruction_from_IDEX,
    o_WriteRegAddr_IDEX  => s_RegWrAddr_from_IDEX
    );   

  --EX stage
  -------------------------------------------------------------------------------------------------------
  ALUSrc_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_SignExtend_from_IDEX,
    B => s_RegFileReadAddress2Out_from_IDEX,
    S => s_ALUSrc_from_IDEX,
    Q => s_ALUSrcMuxOut
  );

  ALU : MIPS_ALU
  port map(
	  shamt      => s_Instruction_from_IDEX, --Added as a way to keep track of shamt
    i_A        => s_RegFileReadAddress1Out_from_IDEX,
    i_B        => s_ALUSrcMuxOut,
    select_ALU => s_ALUOp_from_IDEX,
    Zero       => open,
    data_out   => s_ALUOut,
    c_out      => open
  );
  oALUout <= s_ALUOut; --Assign ALU output to oALUout for syntheis purposes

  EXMEM : ex_mem
  generic map(N => N)
  port map(
    i_CLK 			         => iCLK,
    i_RST_EXMEM	         => iRST,
    i_WE_EXMEM           => '1',
    --------------------------------------------
    i_JAL_EXMEM          => s_JAL_from_IDEX,
    i_MEMTOREG_EXMEM     => s_MemToReg_from_IDEX,
    i_MEMWR_EXMEM	       => s_DMemWr_from_IDEX,
    i_RegWr_EXMEM        => s_RegWr_from_IDEX,
    i_PC_PLUS_4_EXMEM 	 => s_PCPlusFour_from_IFID,
    i_ALU_OUT_EXMEM      => s_ALUOut,
    i_READ_DATA2_EXMEM	 => s_RegFileReadAddress2Out_from_IDEX,
    i_WriteRegAddr_EXMEM => s_RegWrAddr_from_IDEX,
    --------------------------------------------
    o_JAL_EXMEM 	       => s_JAL_from_EXMEM,
    o_MEMTOREG_EXMEM     => s_MemToReg_from_EXMEM,
    o_MEMWR_EXMEM	       => s_DMemWr_from_EXMEM,
    o_RegWr_EXMEM        => s_RegWr_from_EXMEM,
    o_PC_PLUS_4_EXMEM 	 => s_PCPlusFour_from_EXMEM,
    o_ALU_OUT_EXMEM	     => s_ALUOut_from_EXMEM,
    o_READ_DATA2_EXMEM	 => s_RegFileReadAddress2Out_from_EXMEM,
    o_WriteRegAddr_EXMEM => s_RegWrAddr_from_EXMEM
  );

  --MEM stage
  -------------------------------------------------------------------------------------------------------
  --DMem has already been connected properly at the beggining of the code.
  s_DMemAddr <= s_ALUOut_from_EXMEM;
  s_DMemData <= s_RegFileReadAddress2Out_from_EXMEM;
  s_DMemWr   <= s_DMemWr_from_EXMEM;

  MEMWB : mem_wb
  generic map(N => N)
  port map(
    i_CLK 				       => iCLK,
    i_RST_MEMWB			     => iRST,
    i_WE_MEMWB 			     => '1',
    --------------------------------------------
    i_JAL_MEMWB 	       => s_JAL_from_EXMEM,
    i_MEMTOREG_MEMWB		 => s_MemToReg_from_EXMEM,
    i_RegWr_MEMWB        => s_RegWr_from_EXMEM,
    i_PC_PLUS_4_MEMWB 	 => s_PCPlusFour_from_EXMEM,
    i_MEM_READ_MEMWB	 => s_DMemOut,
    i_ALU_OUT_MEMWB	     => s_ALUOut_from_EXMEM,
    i_WriteRegAddr_MEMWB => s_RegWrAddr_from_EXMEM,
    -------------------------------------------- 
    o_JAL_MEMWB 		     => s_JAL_from_MEMWB,
    o_MEMTOREG_MEMWB		 => s_MemToReg_from_MEMWB,
    o_RegWr_MEMWB        => s_RegWr_from_MEMWB,
    o_PC_PLUS_4_MEMWB 	 => s_PCPlusFour_from_MEMWB,
    o_MEM_READ_MEMWB	 => s_DMemOut_from_MEMWB,
    o_ALU_OUT_MEMWB	     => s_ALUOut_from_MEMWB,
    o_WriteRegAddr_MEMWB => s_RegWrAddr_from_MEMWB
  );

  --MEM stage
  -------------------------------------------------------------------------------------------------------
  MemToReg_Mux: MUX21_structN
  generic map(N => N)
  port map(
    A => s_DMemOut_from_MEMWB,
    B => s_ALUOut_from_MEMWB,
    S => s_MemToReg_from_MEMWB,
    Q => s_MemToRegMuxOut
  );

  Jal_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_PCPlusFour_from_MEMWB,
    B => s_MemToRegMuxOut,
    S => s_JAL_from_MEMWB,
    Q => s_RegWrData
  );

  s_RegWr     <= s_RegWr_from_MEMWB;
  s_RegWrAddr <= s_RegWrAddr_from_MEMWB;

end structure;
