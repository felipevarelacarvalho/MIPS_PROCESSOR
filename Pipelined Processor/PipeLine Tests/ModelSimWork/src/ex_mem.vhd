--EX/MEM

entity if_id is

port(i_CLK 			: in std_logic; 						-- Clock Input
	 i_RST_EXMEM	: in std_logic; 						-- Reset Input
	 i_WE_EXMEM 	: in std_logic; 						-- Write Enable Input
	 i_D_EXMEM 		: in std_logic_vector(N-1 downto 0); 	-- Data Value Input
	 o_Q_EXMEM 		: out std_logic_vector(N-1 downto 0)); 	-- Data Value Output

end if_id

architecture structure of ex_mem is

component Register_Nbits:

  generic(N : integer :=32);
  port(i_CLK        : in std_logic;     					 -- Clock input
       i_RST        : in std_logic;     					 -- Reset input
       i_WE         : in std_logic;     					 -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
	   
end Register_Nbits;

--add any addt'l components

--add logic here that's specific to IF/ID
begin

if_id_reg : Register_Nbits

	port MAP(i_CLK <= i_CLK,
		 i_RST_EXMEM <= i_RST,
		 i_WE_EXMEM <= i_WE, 
		 i_D_EXMEM <= i_D,
		 o_Q_EXMEM <= o_Q
	);