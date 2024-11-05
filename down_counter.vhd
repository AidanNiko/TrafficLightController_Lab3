LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY down_counter IS
	PORT(
		i_setBar, i_load	: IN	STD_LOGIC;
		i_clock			: IN	STD_LOGIC;
		o_Value			: OUT	STD_LOGIC_VECTOR(1 downto 0));
END down_counter;

ARCHITECTURE rtl OF down_counter IS
	SIGNAL int_a, int_na, int_b, int_nb : STD_LOGIC;
	SIGNAL int_notA, int_notB : STD_LOGIC;

	COMPONENT enASdFF
		PORT(
			i_setBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;

BEGIN

	-- Concurrent Signal Assignment
	int_na <= (not(int_a) and not(int_b)) or (int_b and int_a) ;
	int_nb <= not(int_b);

msb: enASdFF
	PORT MAP (i_setBar => i_setBar,
			  i_d => int_na,
			  i_enable => i_load, 
			  i_clock => i_clock,
			  o_q => int_a,
	          o_qBar => int_notA);

lsb: enASdFF
	PORT MAP (i_setBar => i_setBar,
			  i_d => int_nb, 
			  i_enable => i_load,
			  i_clock => i_clock,
			  o_q => int_b,
	          o_qBar => int_notB);

	-- Output Driver
	o_Value		<= int_a & int_b;

END rtl;
