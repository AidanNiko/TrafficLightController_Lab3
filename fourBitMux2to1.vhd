LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY fourBitMux2to1 IS
    PORT(i0,i1: IN STD_LOGIC_VECTOR(3 downto 0);
    i_select: IN STD_LOGIC;
    o_y: OUT STD_LOGIC_VECTOR(3 downto 0));
END fourBitMux2to1;

architecture design of fourBitMux2to1 IS

COMPONENT mux1
	PORT(
        i_input: IN STD_LOGIC_VECTOR(1 downto 0);
        i_select: IN STD_LOGIC;
        o_output: OUT STD_LOGIC);
END COMPONENT mux1;

BEGIN
	bit3: mux1 PORT MAP(
        i_input(0) => i0(3),
        i_input(1) => i1(3),
        i_select => i_select,
        o_output => o_y(3));
	
    bit2: mux1 PORT MAP(
        i_input(0) => i0(2),
        i_input(1) => i1(2),
        i_select => i_select,
        o_output => o_y(2));

    bit1: mux1 PORT MAP(
        i_input(0) => i0(1),
        i_input(1) => i1(1),
        i_select => i_select,
        o_output => o_y(1));

    bit0: mux1 PORT MAP(
        i_input(0) => i0(0),
        i_input(1) => i1(0),
        i_select => i_select,
        o_output => o_y(0));
END design;