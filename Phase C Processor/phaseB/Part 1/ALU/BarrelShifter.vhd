library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BarrelShifter is
    port (
      data_in     : in  STD_LOGIC_VECTOR (31 downto 0);
      isSigned : in  STD_LOGIC; -- 0 characterizes an logical shift, 1 characterizes an arithmetic shift
      left_shift  : in  STD_LOGIC; --0 shifts left, 1 shifts right
      shamt   : in  STD_LOGIC_VECTOR (4 downto 0);           
      data_out    : out STD_LOGIC_VECTOR (31 downto 0));
end BarrelShifter;

-----------------------------------------------------------------------------------------------------------------------

architecture structural of BarrelShifter is
   component mux_2to1 is
      port(A,B : in std_logic;
          S : in std_logic;
          Q : out std_logic);
   end component;

   --Signals for output of each "row" of muxes
   signal s_Level1Out : STD_LOGIC_VECTOR(31 downto 0);
   signal s_Level2Out : STD_LOGIC_VECTOR(31 downto 0);
   signal s_Level3Out : STD_LOGIC_VECTOR(31 downto 0);
   signal s_Level4Out : STD_LOGIC_VECTOR(31 downto 0);
   signal s_Level5Out : STD_LOGIC_VECTOR(31 downto 0);
   signal temp : std_logic_vector(31 downto 0);
   signal auxiliar_reverse_in : std_logic_vector(31 downto 0);
   signal auxiliar_reverse_out : std_logic_vector(31 downto 0);
   constant ground : std_logic := '0';
   
   --Begin structural logic for barrel shifter
   begin

      -- If signed, flip bits for logical shift (given two's complement condition). If left shift is desired
      --reverse order of bits.
      -----------------------------------------------------------------------------------------------------------
      G1 : for i in 0 to 31 generate
         auxiliar_reverse_in(i) <= data_in(31-i);
      end generate;

      temp <=not data_in when isSigned = '1' and data_in(data_in 'high) = '1' else
             data_in when isSigned = '1' and data_in(data_in 'high) = '0' else
             auxiliar_reverse_in when isSigned = '0' and left_shift = '1' else
             data_in when isSigned = '0' and left_shift = '0';

      --Create rows of 2to1 muxes and concatenate them accordingly
      -----------------------------------------------------------------------------------------------------------
      GEN_1stMuxRow : for i in 0 to 31 generate
         First30Muxes: if i < 31 generate --Generate the first 30 muxes 
            M0_30 : mux_2to1 port map(
               temp(i), temp(i+1), shamt(0), s_Level1Out(i)
            );
         end generate First30Muxes;

         Mux31: if i = 31 generate --Generate the last mux with ground as B input
            M31 :mux_2to1 port map(
               temp(i), ground, shamt(0), s_Level1Out(i)
            );
         end generate Mux31;

      end generate GEN_1stMuxRow;


      GEN_2ndMuxRow : for i in 0 to 31 generate
         First30Muxes: if i < 30 generate --Generate the first 30 muxes 
            M0_30 : mux_2to1 port map(
               s_Level1Out(i), s_Level1Out(i+2), shamt(1), s_Level2Out(i)
            );
         end generate First30Muxes;

         Mux31: if i > 29 generate --Generate the last mux with ground as B input
            M31 :mux_2to1 port map(
               s_Level1Out(i), ground, shamt(1), s_Level2Out(i)
            );
         end generate Mux31;

      end generate GEN_2ndMuxRow;


      GEN_3rdMuxRow : for i in 0 to 31 generate
         First30Muxes: if i < 28 generate --Generate the first 30 muxes 
            M0_30 : mux_2to1 port map(
               s_Level2Out(i), s_Level2Out(i+4), shamt(2), s_Level3Out(i)
            );
         end generate First30Muxes;

         Mux31: if i > 27 generate --Generate the last mux with ground as B input
            M31 :mux_2to1 port map(
               s_Level2Out(i), ground, shamt(2), s_Level3Out(i)
            );
         end generate Mux31;

      end generate GEN_3rdMuxRow;


      GEN_4thMuxRow : for i in 0 to 31 generate
         First30Muxes: if i < 24 generate --Generate the first 30 muxes 
            M0_30 : mux_2to1 port map(
               s_Level3Out(i), s_Level3Out(i+8), shamt(3), s_Level4Out(i)
            );
         end generate First30Muxes;

         Mux31: if i > 23 generate --Generate the last mux with ground as B input
            M31 :mux_2to1 port map(
               s_Level3Out(i), ground, shamt(3), s_Level4Out(i)
            );
         end generate Mux31;

      end generate GEN_4thMuxRow;


      GEN_5thMuxRow : for i in 0 to 31 generate
         First30Muxes: if i < 16 generate --Generate the first 30 muxes 
            M0_30 : mux_2to1 port map(
               s_Level4Out(i), s_Level4Out(i+16), shamt(4), s_Level5Out(i)
            );
         end generate First30Muxes;

         Mux31: if i > 15 generate --Generate the last mux with ground as B input
            M31 :mux_2to1 port map(
               s_Level4Out(i), ground, shamt(4), s_Level5Out(i)
            );
         end generate Mux31;

      end generate GEN_5thMuxRow;     
      
      --Reverse output given arithmetic/logical, left/right conditionals
      -----------------------------------------------------------------------------------------------------------
      G2 : for i in 0 to 31 generate
         auxiliar_reverse_out(i) <= s_Level5Out(31-i);
      end generate;

      data_out <=not s_Level5Out when isSigned = '1' and data_in(data_in 'high) = '1' else
                 s_Level5Out when isSigned = '1' and data_in(data_in 'high) = '0' else
                 auxiliar_reverse_out when isSigned = '0' and left_shift = '1' else
                 s_Level5Out when isSigned = '0' and left_shift = '0';      

end structural;