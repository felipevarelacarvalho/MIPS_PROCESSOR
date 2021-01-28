--This is the logic to handle branch on equal and branch on not equal for the MIPS processor
--This consists of two "and" gates and an "or" gate
--One of the input in the "and" gates is negated
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity BranchLogic is

	port(
        BranchOnEqual_in    : in std_logic;
        BranchOnNotEqual_in : in std_logic;
        ComparingBit        : in std_logic;
        BranchSignal_out     : out std_logic
    );
end BranchLogic;
-----------------------------------------------------------------------------------------------------------------------
architecture behavioural of BranchLogic is
    --Signals
    signal s_Negate_ComparingBit   : std_logic; --Signal for the negated input of the BNE and gate
    signal s_BNE_AND_OUT : std_logic; --Signal for the "and" gate Branch not equal
    signal s_BEQ_AND_OUT : std_logic; --Signal for the "and" gate Branch on equal

    --Begin behavioural logic for BranchLogic
    begin
        s_Negate_ComparingBit <= not ComparingBit;
        s_BEQ_AND_OUT <= BranchOnEqual_in and ComparingBit;
        s_BNE_AND_OUT <= s_Negate_ComparingBit and BranchOnNotEqual_in;
        BranchSignal_out <= s_BEQ_AND_OUT or s_BNE_AND_OUT;
end behavioural;