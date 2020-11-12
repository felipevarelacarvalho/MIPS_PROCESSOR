library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS_ALU is
    port(
		shamt           : in std_logic_vector(31 downto 0);  --Added as a way to keep track of the shifter amount
        i_A             : in  std_logic_vector(31 downto 0); --Input A
        i_B             : in  std_logic_vector(31 downto 0); --Input B, input that controls immediate value
        select_ALU      : in  std_logic_vector( 3 downto 0); --Select line ALU
        Zero            : out std_logic;                     --Zero Output
        data_out        : out std_logic_vector(31 downto 0); --ALU output
        c_out           : out std_logic                      --Carry out
    );
end MIPS_ALU;

architecture behaviour of MIPS_ALU is
    --Declare components
    ----------------------------------------------------------------------
    component ALU32 is
        port(
		iA				: in std_logic_vector (31 downto 0);
		iB				: in std_logic_vector (31 downto 0);
		s1				: in std_logic;
		s2				: in std_logic;
		s3				: in std_logic;
		oC				: out std_logic;		
        oOut			: out std_logic_vector (31 downto 0));
    end component;

    component BarrelShifter is
        port (
        data_in         : in  STD_LOGIC_VECTOR (31 downto 0);
        isSigned        : in  STD_LOGIC; -- 0 characterizes an logical shift, 1 characterizes an arithmetic shift
        left_shift      : in  STD_LOGIC; --0 shifts left, 1 shifts right
        shamt           : in  STD_LOGIC_VECTOR (4 downto 0);           
        data_out        : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    --Signals
    ----------------------------------------------------------------------
    signal s_shiftedOut0 : std_logic_vector (31 downto 0);
    signal s_isSigned    : std_logic;
    signal s_left_shift  : std_logic;
    signal s_shamt       : std_logic_vector(4 downto 0);
    signal s_i_A_Barrel  : std_logic_vector(31 downto 0);
    signal s_ALU_out     : std_logic_vector (31 downto 0);

    --Behaviour
    ----------------------------------------------------------------------
    begin
        --Multiplexers to determine shifts and operations
        s_shamt <= shamt(10 downto 6) when select_ALU = "1010" or select_ALU = "1001" or select_ALU = "1011" else --Shift four bits given R inst srl, sll, sra
				i_A(4 downto 0) when select_ALU = "0110" or select_ALU ="1100" or select_ALU = "1101" else --Shift last four bits of iB when instruction is srav, sllv, srlv
                "10000" when select_ALU = "1000" else --Special case where shift is 16 for "lui" instruction
                "00000"; --No shift

        s_left_shift <= '1' when select_ALU = "1001" or select_ALU = "1100" or select_ALU = "1000" else
                        '0';
        
        s_isSigned <= '1' when select_ALU = "0110" or select_ALU = "1011" else
                      '0';
               
        s_i_A_Barrel <= s_ALU_out when select_ALU = "1000" else --Special mux for "lui"
                        i_B;

		
        g_BarrelShifter0: BarrelShifter
        port map(
            data_in => s_i_A_Barrel,
            isSigned => s_isSigned,
            left_shift => s_left_shift,
            shamt => s_shamt,
            data_out => s_shiftedOut0
        );

        g_ALU : ALU32
        port map(
            iA => i_A,
            iB => i_B,
            s1 => select_ALU(2),
            s2 => select_ALU(1),
            s3 => select_ALU(0),
            oC => c_out,
            oOut => s_ALU_out
        );    
        
        data_out <= s_ALU_out when s_shamt = "00000" else
                    s_shiftedOut0;

        zero <= not( s_ALU_out(31) OR s_ALU_out(30) OR s_ALU_out(29) OR s_ALU_out(28)
        OR s_ALU_out(27) OR s_ALU_out(26) OR s_ALU_out(25) OR s_ALU_out(24)
        OR s_ALU_out(23) OR s_ALU_out(22) OR s_ALU_out(21) OR s_ALU_out(20)
        OR s_ALU_out(19) OR s_ALU_out(18) OR s_ALU_out(17) OR s_ALU_out(16)
        OR s_ALU_out(15) OR s_ALU_out(14) OR s_ALU_out(13) OR s_ALU_out(12)
        OR s_ALU_out(11) OR s_ALU_out(10) OR s_ALU_out(9) OR s_ALU_out(8)
        OR s_ALU_out(7) OR s_ALU_out(6) OR s_ALU_out(5) OR s_ALU_out(4)
        OR s_ALU_out(3) OR s_ALU_out(2) OR s_ALU_out(1) OR s_ALU_out(0) );


end behaviour;