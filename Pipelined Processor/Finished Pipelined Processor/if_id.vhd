--IF/ID
-- By Trevor, Muhamed, Felipe
library IEEE;
use IEEE.std_logic_1164.all;

entity if_id is
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
end if_id;

architecture structure of if_id is

component Register_Nbits is
  generic(N : integer);
  port(i_CLK            : in std_logic;     					 -- Clock input
       i_RST            : in std_logic;     					 -- Reset input
       i_WE             : in std_logic;     					 -- Write enable input
       i_D              : in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q              : out std_logic_vector(N-1 downto 0));   -- Data value output
	   
end component;

--add any addt'l components

--32 bit signals for Instruction Memory and PC+4 Outputs
--signal s_iMem_IFID	: std_logic_vector(31 downto 0); -- Instruction Memory
--signal s_PC4_IFID	: std_logic_vector(31 downto 0); -- PC+4

--1 bit signal for the Flush
--signal s_flush_IFID		: std_logic; -- Flush

--add logic here that's specific to IF/ID
--No hazard Detection
--
begin

--32 bit registers for Instruction Mem and PC+4

-- Instruction Memory
if_id_iMem_reg : Register_Nbits
	generic MAP(N => 32)
	port MAP(i_CLK => i_CLK,
		 i_RST => i_RST_IFID,
		 i_WE => i_WE_IFID, 
		 i_D => i_MEM_IFID,
		 o_Q => o_MEM_IFID
	);
	
-- PC+4
if_id_pc4_reg : Register_Nbits
	generic MAP(N => 32)
	port MAP(i_CLK => i_CLK,
			 i_RST => i_RST_IFID,
			 i_WE => i_WE_IFID, 
			 i_D => i_PCplusFOUR_IFID,
			 o_Q => o_PCplusFOUR_IFID
	);
	
--1 bit register for Flush Signal (Not needed for this phase of the project)
--if_id_Flush_Reg : Register_Nbits
--	generic MAP(N => 1);
--	port MAP(i_CLK => i_CLK,
--			 i_RST => i_RST_IFID,
--			 i_WE => i_WE_IFID, 
--			 i_D => i_FLUSH_IFID,
--			 o_Q => s_flush_IFID
--	);
	
end structure;