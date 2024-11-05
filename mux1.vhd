LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux1 IS
	PORT(
        i_input: IN STD_LOGIC_VECTOR(1 downto 0);
        i_select: IN STD_LOGIC;
        o_output: OUT STD_LOGIC);
END mux1;

ARCHITECTURE structural OF mux1 IS
    SIGNAL int_notselect,int_and1,int_and2:STD_LOGIC;

    BEGIN
        int_notselect <= NOT(i_select);
        int_and1 <= i_input(0) AND int_notselect;
        int_and2 <= i_input(1) AND i_select;
        o_output <= int_and1 OR int_and2;
END structural;
