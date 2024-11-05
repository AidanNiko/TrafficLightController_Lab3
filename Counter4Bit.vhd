--4 bit asynchronous counter
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Counter4Bit IS
	PORT(
		i_reset: IN	STD_LOGIC;
		i_inc: IN	STD_LOGIC;
		i_enable: IN STD_LOGIC;
		o_Value: OUT STD_LOGIC_VECTOR(3 downto 0));
END Counter4Bit;

ARCHITECTURE rtl OF Counter4Bit IS
	SIGNAL int_counterOut: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL int_notCounterOut : STD_LOGIC_VECTOR(3 downto 0);

	COMPONENT enARdFF_2
		PORT(
			i_resetBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;

BEGIN

bit0: enARdFF_2
	PORT MAP (i_resetBar => NOT(i_reset),
			  i_d => int_notCounterOut(0),
			  i_enable => i_enable, 
			  i_clock => i_inc,
			  o_q => int_counterOut(0),
	          o_qBar => int_notCounterOut(0));

genFF: FOR i IN 1 TO 3 GENERATE
	bit2: enARdFF_2
		PORT MAP (i_resetBar => NOT(i_reset),
				i_d => int_notCounterOut(i),
				i_enable => i_enable, 
				i_clock => int_notCounterOut(i-1),
				o_q => int_counterOut(i),
				o_qBar => int_notCounterOut(i));
END GENERATE;

	-- Output Driver
	o_Value <= int_counterOut;

END rtl;
