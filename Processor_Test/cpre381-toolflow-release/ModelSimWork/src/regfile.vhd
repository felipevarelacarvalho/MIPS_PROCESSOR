library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
    port(
        clk, rst, reg_write_en: in std_logic;
        reg_write_dest: in std_logic_vector(4 downto 0); -- 5 bit destination (Input for 5:32 decoder)
        reg_write_data: in std_logic_vector(31 downto 0); --32 bit data in (input for registers)
        reg_read_addrA, reg_read_addrB: in std_logic_vector(4 downto 0); --Select line for 32:1 mux for read address A and B
        reg_out_dataA: out std_logic_vector(31 downto 0); --32 bit output register A
        reg_out_dataB: out std_logic_vector(31 downto 0); -- 32 bit output register B
        reg2_out: out std_logic_vector(31 downto 0)
        );
end regfile;

architecture behavior of regfile is
    --Describe components
    component Decoder_5_32 is
        port(D_IN : in std_logic_vector(4 downto 0);
             F_OUT : out std_logic_vector(31 downto 0));
    end component;

    component mux32to1 is
        port(
        d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12,d13,d14,d15,d16,d17,d18,d19,d20,
        d21,d22,d23,d24,d25,d26,d27,d28,d29,d30,d31  : in  std_logic_vector(31 downto 0); --32 bit bus ionputs
        sel_in  : in  std_logic_vector(4 downto 0); --5 bit select line
        m_out : out std_logic_vector(31 downto 0)); --32 bit output
    end component;

    component Register_Nbits is
        generic(N : integer :=32);
        port(i_CLK        : in std_logic;     -- Clock input
             i_RST        : in std_logic;     -- Reset input
             i_WE         : in std_logic;     -- Write enable input
             i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
             o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
      end component;

	--Component added for jal (11/4/2020)
	  component Reg29 is
        generic(N : integer :=32);
        port(i_CLK        : in std_logic;     -- Clock input
             i_RST        : in std_logic;     -- Reset input
             i_WE         : in std_logic;     -- Write enable input
             i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
             o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
      end component;
	  
    --Create a list of 32 registers
    type reg_list is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal reg_array : reg_list;
    --Output signals
    signal s_decoder5to32out : std_logic_vector(31 downto 0);
	signal fout_Signal : std_logic_vector(31 downto 0);

    begin
	
		s_decoder5to32out <= fout_Signal when reg_write_en = '1' else "00000000000000000000000000000000";	
			
        g_Decoder5to32_1 :  Decoder_5_32
        port map(
            D_IN => reg_write_dest,
            F_OUT => fout_Signal
        );
		
		

        g_reg0 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(0),
            i_D => "00000000000000000000000000000000",
            o_Q => reg_array(0)
        );

        g_reg1 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(1),
            i_D => reg_write_data,
            o_Q => reg_array(1)
        );

        g_reg2 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(2),
            i_D => reg_write_data,
            o_Q => reg_array(2)
        );

        g_reg3 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(3),
            i_D => reg_write_data,
            o_Q => reg_array(3)
        );

        g_reg4 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(4),
            i_D => reg_write_data,
            o_Q => reg_array(4)
        );

        g_reg5 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(5),
            i_D => reg_write_data,
            o_Q => reg_array(5)
        );

        g_reg6 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(6),
            i_D => reg_write_data,
            o_Q => reg_array(6)
        );

        g_reg7 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(7),
            i_D => reg_write_data,
            o_Q => reg_array(7)
        );

        g_reg8 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(8),
            i_D => reg_write_data,
            o_Q => reg_array(8)
        );

        g_reg9 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(9),
            i_D => reg_write_data,
            o_Q => reg_array(9)
        );

        g_reg10 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(10),
            i_D => reg_write_data,
            o_Q => reg_array(10)
        );

        g_reg11 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(11),
            i_D => reg_write_data,
            o_Q => reg_array(11)
        );

        g_reg12 : Register_Nbits
       -- generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(12),
            i_D => reg_write_data,
            o_Q => reg_array(12)
        );

        g_reg13 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(13),
            i_D => reg_write_data,
            o_Q => reg_array(13)
        );

        g_reg14 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(14),
            i_D => reg_write_data,
            o_Q => reg_array(14)
        );

        g_reg15 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(15),
            i_D => reg_write_data,
            o_Q => reg_array(15)
        );

        g_reg16 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(16),
            i_D => reg_write_data,
            o_Q => reg_array(16)
        );

        g_reg17 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(17),
            i_D => reg_write_data,
            o_Q => reg_array(17)
        );

        g_reg18 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(18),
            i_D => reg_write_data,
            o_Q => reg_array(18)
        );

        g_reg19 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(19),
            i_D => reg_write_data,
            o_Q => reg_array(19)
        );

        g_reg20 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(20),
            i_D => reg_write_data,
            o_Q => reg_array(20)
        );

        g_reg21 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(21),
            i_D => reg_write_data,
            o_Q => reg_array(21)
        );

        g_reg22 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(22),
            i_D => reg_write_data,
            o_Q => reg_array(22)
        );

        g_reg23 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(23),
            i_D => reg_write_data,
            o_Q => reg_array(23)
        );

        g_reg24 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(24),
            i_D => reg_write_data,
            o_Q => reg_array(24)
        );

        g_reg25 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(25),
            i_D => reg_write_data,
            o_Q => reg_array(25)
        );

        g_reg26 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(26),
            i_D => reg_write_data,
            o_Q => reg_array(26)
        );

        g_reg27 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(27),
            i_D => reg_write_data,
            o_Q => reg_array(27)
        );

        g_reg28 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(28),
            i_D => reg_write_data,
            o_Q => reg_array(28)
        );

        g_reg29 : Register_Nbits --Pay attention due to jal
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(29),
            i_D => reg_write_data,
            o_Q => reg_array(29)
        );

        g_reg30 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(30),
            i_D => reg_write_data,
            o_Q => reg_array(30)
        );

        g_reg31 : Register_Nbits
        --generic map(N => 32);
        port map(
            i_CLK => clk,
            i_RST => rst,
            i_WE => s_decoder5to32out(31),
            i_D => reg_write_data,
            o_Q => reg_array(31)
        );

        g_mux32to1_1 : mux32to1
        port map(
            d0	=>	reg_array(0)		,
            d1	=>	reg_array(1)		,
            d2	=>	reg_array(2)		,
            d3	=>	reg_array(3)		,
            d4	=>	reg_array(4)		,
            d5	=>	reg_array(5)		,
            d6	=>	reg_array(6)		,
            d7	=>	reg_array(7)		,
            d8	=>	reg_array(8)		,
            d9	=>	reg_array(9)		,
            d10	=>	reg_array(10)		,
            d11	=>	reg_array(11)		,
            d12	=>	reg_array(12)		,
            d13	=>	reg_array(13)		,
            d14	=>	reg_array(14)		,
            d15	=>	reg_array(15)		,
            d16	=>	reg_array(16)		,
            d17	=>	reg_array(17)		,
            d18	=>	reg_array(18)		,
            d19	=>	reg_array(19)		,
            d20	=>	reg_array(20)		,
            d21	=>	reg_array(21)		,
            d22	=>	reg_array(22)		,
            d23	=>	reg_array(23)		,
            d24	=>	reg_array(24)		,
            d25	=>	reg_array(25)		,
            d26	=>	reg_array(26)		,
            d27	=>	reg_array(27)		,
            d28	=>	reg_array(28)		,
            d29	=>	reg_array(29)		,
            d30	=>	reg_array(30)		,
            d31	=>	reg_array(31)       ,
            sel_in =>  reg_read_addrA,
            m_out => reg_out_dataA
        );

        g_mux32to1_2 : mux32to1
        port map(
            d0	=>	reg_array(0)		,
            d1	=>	reg_array(1)		,
            d2	=>	reg_array(2)		,
            d3	=>	reg_array(3)		,
            d4	=>	reg_array(4)		,
            d5	=>	reg_array(5)		,
            d6	=>	reg_array(6)		,
            d7	=>	reg_array(7)		,
            d8	=>	reg_array(8)		,
            d9	=>	reg_array(9)		,
            d10	=>	reg_array(10)		,
            d11	=>	reg_array(11)		,
            d12	=>	reg_array(12)		,
            d13	=>	reg_array(13)		,
            d14	=>	reg_array(14)		,
            d15	=>	reg_array(15)		,
            d16	=>	reg_array(16)		,
            d17	=>	reg_array(17)		,
            d18	=>	reg_array(18)		,
            d19	=>	reg_array(19)		,
            d20	=>	reg_array(20)		,
            d21	=>	reg_array(21)		,
            d22	=>	reg_array(22)		,
            d23	=>	reg_array(23)		,
            d24	=>	reg_array(24)		,
            d25	=>	reg_array(25)		,
            d26	=>	reg_array(26)		,
            d27	=>	reg_array(27)		,
            d28	=>	reg_array(28)		,
            d29	=>	reg_array(29)		,
            d30	=>	reg_array(30)		,
            d31	=>	reg_array(31)       ,
            sel_in =>  reg_read_addrB,
            m_out => reg_out_dataB
        );
    
        reg2_out <= reg_array(2);
        
end behavior;