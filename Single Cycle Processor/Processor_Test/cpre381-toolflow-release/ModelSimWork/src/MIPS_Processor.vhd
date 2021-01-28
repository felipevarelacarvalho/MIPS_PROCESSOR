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
       iInstLd         : in std_logic; --Dont worry about it now
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0); --Dont worry about it
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
	  shamt           : in std_logic_vector(31 downto 0); --Added as a way to keep track of the shifter amount
      i_A             : in  std_logic_vector(31 downto 0); --Input A
      i_B             : in  std_logic_vector(31 downto 0); --Input B, input that controls immediate value
      select_ALU      : in  std_logic_vector( 3 downto 0); --Select line ALU
      Zero            : out std_logic;                     --Zero Output
      data_out        : out std_logic_vector(31 downto 0); --ALU output
      c_out           : out std_logic                      --Carry out
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
        reg_write_dest: in std_logic_vector(4 downto 0); -- 5 bit destination (Input for 5:32 decoder)
        reg_write_data: in std_logic_vector(31 downto 0); --32 bit data in (input for registers)
        reg_read_addrA, reg_read_addrB: in std_logic_vector(4 downto 0); --Select line for 32:1 mux for read address A and B
        reg_out_dataA: out std_logic_vector(31 downto 0); --32 bit output register A
        reg_out_dataB: out std_logic_vector(31 downto 0); -- 32 bit output register B
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
        isSigned : in  STD_LOGIC; -- 0 characterizes an logical shift, 1 characterizes an arithmetic shift
        left_shift  : in  STD_LOGIC; --0 shifts left, 1 shifts right
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
		port(i_CLK   : in std_logic;     -- Clock input
		i_RST        : in std_logic;     -- Reset input
		i_WE         : in std_logic;     -- Write enable input
		i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
		o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
	end component;
	

  -------------------------------------------------------------------------------------------------------
  --Additional Signals
  -------------------------------------------------------------------------------------------------------
  signal s_ALUout :             std_logic_vector(31 downto 0);
  signal s_MemToReg :           std_logic;
  signal s_MemToRegMuxOut :     std_logic_vector(31 downto 0);
  signal s_RegFileReadAddress1: std_logic_vector(31 downto 0);
  signal s_RegFileReadAddress2: std_logic_vector(31 downto 0);
  signal s_ALUSrcMuxOut :       std_logic_vector(31 downto 0);
  signal s_ALUZeroOut :         std_logic;
  signal s_ALUCarryOut:         std_logic;
  signal s_SignExtendOut:       std_logic_vector(31 downto 0);
  signal s_RegDstMuxOut:        std_logic_vector( 3 downto 0);

  signal s_PCPlusFourOut:       std_logic_vector(31 downto 0);

  signal s_DummyCout:           std_logic;

  --Control Logic Module Signals
  signal s_ALUOp :              std_logic_vector(3 downto 0);
  signal s_ALUSrc:              std_logic;
  signal s_RegDst:              std_logic;
  signal s_Jump :               std_logic;
  signal s_BranchOnEqual :      std_logic; --Added for BEQ
  signal s_MemReadEnable :      std_logic; --Not being used in Proj B, here for future reference
  signal s_jr :                 std_logic; --Added for jr
  signal s_BranchOnNotEqual :   std_logic; --Added for BNE
  signal s_jal :                std_logic; --Added for jal

  --New signals for Phase II
  signal s_ShiftLeftTwoInstructionOut : std_logic_vector(31 downto 0);
  signal s_BranchMuxOut : std_logic_vector(31 downto 0);
  signal s_JumpMuxOut   :std_logic_vector(31 downto 0);
  signal s_JrMuxOut : std_logic_vector(31 downto 0);
  signal s_ShiftLeftTwoSignExtended : std_logic_vector(31 downto 0);
  signal s_groundout : std_logic; --Assinged to signals that are not usefull
  signal s_BranchAdderOut : std_logic_vector(31 downto 0);
  signal s_BranchLogicOut : std_logic;
  signal s_isExtendSigned : std_logic; --check for sign extension for boolean immediate functions
  signal s_RegWrAddrIntermed : std_logic_vector(4 downto 0); --to fix intermediate mux added for jal functionality

  signal s_temp1 : std_logic_vector(31 downto 0);
  signal s_temp2: std_logic_vector(31 downto 0);
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
  MemToReg_Mux: MUX21_structN
  generic map(N => N)
  port map(
    A => s_DMemOut,
    B => s_DMemAddr,
    S => s_MemToReg,
    Q => s_MemToRegMuxOut --Changed it to fit phase II, changed from s_RegWrData
  );

	
  ALU : MIPS_ALU
  port map(
	shamt => s_Inst, --Added as a way to keep track of shamt
    i_A => s_RegFileReadAddress1,
    i_B => s_ALUSrcMuxOut,
    select_ALU => s_ALUOp,
    Zero => s_ALUZeroOut,
    data_out => s_DMemAddr,
    c_out =>s_ALUCarryOut
  );
  
  --s_DMemAddr <= s_ALUout;
  oALUout <= s_DMemAddr; --Assign ALU output to oALUout for syntheis purposes

  ALUSrc_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_SignExtendOut,
    B => s_RegFileReadAddress2,
    S => s_AluSrc,
    Q => s_ALUSrcMuxOut
  );

  SignExtend : extender
  port map(
    signal_extend => s_isExtendSigned,
    d_in => s_Inst(15 downto 0),
    d_out => s_SignExtendOut
  );

  RegDst_Mux: MUX21_structN
  generic map(N => 5)
  port map(
    A => s_Inst(15 downto 11),
    B => s_Inst(20 downto 16),
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
		opcode		=> s_Inst(31 downto 26),
		funct		=> s_Inst(5 downto 0),
		ALUSrc 		=> s_AluSrc,
		ALUControl 	=> s_ALUOp,
		MemtoReg	=> s_MemToReg,
		s_DMemWr	=> s_DMemWr,
		s_RegWr		=> s_RegWr,
		RegDst		=> s_RegDst,
		Jump		=> s_Jump,
		JumpReg		=> s_jr,
		JumpNLink	=> s_jal,
		BranchEqual	=> s_BranchOnEqual,
		BranchNotEqual => s_BranchOnNotEqual,
		isExtendSigned => s_isExtendSigned,
		MemRead 			=> s_MemReadEnable --Not being used in Proj B, here for future reference
  ); 

  RegisterFile : regfile
  port map(
    clk => iCLK,
    rst => iRST,
    reg_write_en => s_RegWr,
    reg_write_dest => s_RegWrAddr,
    reg_write_data => s_RegWrData,
    reg_read_addrA => s_Inst(25 downto 21),
    reg_read_addrB => s_Inst(20 downto 16),
    reg_out_dataA => s_RegFileReadAddress1,
    reg_out_dataB => s_RegFileReadAddress2,
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
    Sum => s_PCPlusFourOut
  );

  --Phase II starts here
  --Beginning of Jump Logic
  s_temp1 <= b"00000011111111111111111111111111" and s_Inst;
  ShiftLeftTwo_Instruction : BarrelShifter
  port map(
    data_in =>  s_temp1,
    isSigned => '0',
    left_shift => '1',
    shamt => b"00010",
    data_out =>  s_ShiftLeftTwoInstructionOut
  );

  s_temp2 <= ( s_PCPlusFourOut and x"10000000" ) or s_ShiftLeftTwoInstructionOut;
  Jump_Mux : MUX21_structN 
  generic map(N => N)
  port map(
    A =>  s_temp2, --A represents 1 in the MUX
    B =>  s_BranchMuxOut, --B represents 0 in the Mux
    S =>  s_Jump,
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
    A => s_PCPlusFourOut,
    B => s_ShiftLeftTwoSignExtended,
    Cout => s_groundout,
    Sum => s_BranchAdderOut
  );

  BranchLogicBlock : BranchLogic
  port map(
    BranchOnEqual_in    => s_BranchOnEqual,
    BranchOnNotEqual_in => s_BranchOnNotEqual,
    ComparingBit        => s_ALUZeroOut,
    BranchSignal_out    => s_BranchLogicOut
  );

  Branch_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_BranchAdderOut,
    B => s_PCPlusFourOut,
    S => s_BranchLogicOut,
    Q => s_BranchMuxOut
  );

  --Beginning of jal logic
  Jal_Mux : MUX21_structN
  generic map(N => N)
  port map(
    A => s_PCPlusFourOut,
    B => s_MemToRegMuxOut,
    S => s_jal,
    Q => s_RegWrData
  );
end structure;
