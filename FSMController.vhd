LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY FSMController IS
	PORT(
		i_reset: IN	STD_LOGIC;
        i_SSCS,i_MSC,i_MT,i_SSC,i_SST: IN STD_LOGIC;
		i_clock: IN	STD_LOGIC;
		o_main: OUT STD_LOGIC_VECTOR(2 downto 0);
        o_side: OUT STD_LOGIC_VECTOR(2 downto 0);
        o_enableMSC: OUT STD_LOGIC;
        o_enableMT: OUT STD_LOGIC;
        o_enableSSC: OUT STD_LOGIC;
        o_enableSST: OUT STD_LOGIC;
		  o_Y: OUT STD_LOGIC_VECTOR(1 downto 0));
END FSMController;

ARCHITECTURE rtl OF FSMController IS
	SIGNAL int_y0,int_y1,int_Y0In,int_Y1In: STD_LOGIC;

	COMPONENT enARdFF_2
		PORT(
			i_resetBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;

BEGIN

int_Y1In <= (int_y1 AND NOT(int_y0)) OR (int_y1 AND int_y0 AND NOT(i_SST)) OR (NOT(int_y1) AND (int_y0) AND i_MT);
int_Y0In <= (NOT(int_y1) AND int_y0 AND NOT(i_MT)) OR (int_y1 AND int_y0 AND NOT(i_SST)) 
OR (NOT(int_y1) AND NOT(int_y0) AND i_SSCS AND i_MSC) OR (int_y1 AND NOT(int_y0) AND i_SSC);

Y0: enARdFF_2
	PORT MAP (i_resetBar => NOT(i_reset),
			  i_d => int_Y0In,
			  i_enable => '1', 
			  i_clock => i_clock,
			  o_q => int_y0);

Y1: enARdFF_2
	PORT MAP (i_resetBar => NOT(i_reset),
			i_d => int_Y1In,
			i_enable => '1', 
			i_clock => i_clock,
			o_q => int_y1);


	-- Output Driver
	o_main(2) <= NOT(int_y1) AND NOT(int_y0);
    o_main(1) <= NOT(int_y1) AND int_y0;
    o_main(0) <= int_y1;
    
    o_side(2) <= int_y1 AND NOT(int_y0);
    o_side(1) <= int_y1 AND int_y0;
    o_side(0) <= NOT(int_y1);

    o_enableMSC <= NOT(int_y1) AND NOT(int_y0);
    o_enableMT <= NOT(int_y1) AND int_y0;
    o_enableSSC <= int_y1 AND NOT(int_y0);
    o_enableSST <= int_y1 AND int_y0;
	 
	 o_Y(1) <= int_y1;
	 o_Y(0) <= int_y0;
END rtl;
