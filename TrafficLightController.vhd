LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY TrafficLightController IS
	PORT(
		i_reset: IN	STD_LOGIC;
		i_clock: IN	STD_LOGIC;
      i_carSensor: IN STD_LOGIC;
      i_SSCmax: IN STD_LOGIC_VECTOR(3 downto 0);
      i_MSCmax: IN STD_LOGIC_VECTOR(3 downto 0);
		o_main: OUT STD_LOGIC_VECTOR(2 downto 0);
      o_side: OUT STD_LOGIC_VECTOR(2 downto 0);
      o_currentState: OUT STD_LOGIC_VECTOR(1 downto 0));
END TrafficLightController;

ARCHITECTURE rtl OF TrafficLightController IS
    SIGNAL int_gClock: STD_LOGIC;
    SIGNAL int_debouncedSSCS: STD_LOGIC;
	SIGNAL int_SSCounter,int_MSCounter: STD_LOGIC_VECTOR(3 downto 0);
    SIGNAL int_MTCounter,int_SSTCounter: STD_LOGIC_VECTOR(1 downto 0);
    SIGNAL int_SSCEqual,int_MSCEqual,int_SSCmem,int_MSCmem,int_MT,int_SST: STD_LOGIC;
    SIGNAL int_enableSSC,int_enableMSC,int_enableMT,int_enableSST: STD_LOGIC;
    SIGNAL int_main,int_side: STD_LOGIC_VECTOR(2 downto 0);
    --The current state signal is only used for testing purposes
    SIGNAL int_currentState: STD_LOGIC_VECTOR(1 downto 0);

   COMPONENT FSMController IS
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
    END COMPONENT;

	COMPONENT enARdFF_2 IS
		PORT(
			i_resetBar	: IN	STD_LOGIC;
			i_d		: IN	STD_LOGIC;
			i_enable	: IN	STD_LOGIC;
			i_clock		: IN	STD_LOGIC;
			o_q, o_qBar	: OUT	STD_LOGIC);
	END COMPONENT;

    COMPONENT debouncer_2 IS
        PORT(
            i_resetBar		: IN	STD_LOGIC;
            i_clock			: IN	STD_LOGIC;
            i_raw			: IN	STD_LOGIC;
            o_clean			: OUT	STD_LOGIC);
    END COMPONENT;

    COMPONENT clk_div IS
        PORT(
            clock_25Mhz				: IN	STD_LOGIC;
            clock_1MHz				: OUT	STD_LOGIC;
            clock_100KHz			: OUT	STD_LOGIC;
            clock_10KHz				: OUT	STD_LOGIC;
            clock_1KHz				: OUT	STD_LOGIC;
            clock_100Hz				: OUT	STD_LOGIC;
            clock_10Hz				: OUT	STD_LOGIC;
            clock_1Hz				: OUT	STD_LOGIC);	
    END COMPONENT;

    COMPONENT Counter4Bit IS
	PORT(
		i_reset: IN	STD_LOGIC;
		i_enable: IN STD_LOGIC;
		i_inc: IN	STD_LOGIC;
		o_Value: OUT STD_LOGIC_VECTOR(3 downto 0));
    END COMPONENT;

    COMPONENT down_counter IS
        PORT(
            i_setBar, i_load	: IN	STD_LOGIC;
            i_clock			: IN	STD_LOGIC;
            o_Value			: OUT	STD_LOGIC_VECTOR(1 downto 0));
    END COMPONENT;

    COMPONENT fourBitComparator IS
	PORT(
		i_Ai, i_Bi			: IN	STD_LOGIC_VECTOR(3 downto 0);
		o_GT, o_LT, o_EQ		: OUT	STD_LOGIC);
    END COMPONENT;

    COMPONENT fourBitMux2to1 IS
        PORT(i0,i1: IN STD_LOGIC_VECTOR(3 downto 0);
        i_select: IN STD_LOGIC;
        o_y: OUT STD_LOGIC_VECTOR(3 downto 0));
    END COMPONENT;

BEGIN
    ClockDiv: clk_div
    PORT MAP (clock_25Mhz => i_clock,
					clock_1Hz => int_gClock);

    Debouncer: debouncer_2
        PORT MAP (
            i_resetBar => NOT(i_reset),
            i_clock => int_gClock,
            i_raw => i_carSensor,
            o_clean => int_debouncedSSCS);

    SSCounter: Counter4Bit
        PORT MAP(
            i_reset => i_reset OR int_SSCMem,
            i_enable => int_enableSSC,
            i_inc => int_gClock,
            o_Value => int_SSCounter);

    CompareSSC: fourBitComparator
        PORT MAP (
            i_Ai => int_SSCounter, 
            i_Bi => i_SSCmax,
            o_EQ => int_SSCEqual);

    --To reset the counter once it is equal to the max value, a DFF is used to memorize the output of compareSSC,
    --so the counter gets reset after one clock cycle. The output of the memory is high during this clock cycle,
    --giving the FSMController one clock cycle to change its state.
    SSCounterEqualMem: enARdFF_2
        PORT MAP(
            i_resetBar => NOT(i_reset),
            i_d => int_SSCEqual,
            i_enable => '1',
            i_clock	=> int_gClock,
            o_q => int_SSCMem);
    
    MTCounter: down_counter
        PORT MAP(
            i_setBar => NOT(i_reset),
            i_load => int_enableMT,
            i_clock => int_gClock,
            o_Value	=> int_MTCounter);
    
    int_MT <= NOT(int_MTCounter(1)) AND NOT(int_MTCounter(0));

    MSCounter: Counter4Bit
        PORT MAP(
            i_reset => i_reset OR int_MSCMem,
            i_enable => int_enableMSC,
            i_inc => int_gClock,
            o_Value => int_MSCounter);

    CompareMSC: fourBitComparator
        PORT MAP (
            i_Ai => int_MSCounter, 
            i_Bi => i_MSCmax,
            o_EQ => int_MSCEqual);

    --Same counter reset mechanism
    MSCounterEqualMem: enARdFF_2
        PORT MAP(
            i_resetBar => NOT(i_reset),
            i_d => int_MSCEqual,
            i_enable => '1',
            i_clock	=> int_gClock,
            o_q => int_MSCMem);

    SSTCounter: down_counter 
        PORT MAP(
            i_setBar => NOT(i_reset),
            i_load => int_enableSST,
            i_clock => int_gClock,
            o_Value	=> int_SSTCounter);
    
    int_SST <= NOT(int_SSTCounter(1)) AND NOT(int_SSTCounter(0));

    Controller: FSMController
    PORT MAP(
        i_reset => i_reset,
        i_SSCS => int_debouncedSSCS,
        i_MSC => int_MSCMem,
        i_MT => int_MT,
        i_SSC => int_SSCMem,
        i_SST => int_SST,
        i_clock => int_gClock,
        o_main => int_main,
        o_side => int_side,
        o_enableMSC => int_enableMSC,
        o_enableMT => int_enableMT,
        o_enableSSC => int_enableSSC,
        o_enableSST => int_enableSST,
        o_Y => int_currentState);


	-- Output Driver
	o_currentState <= int_currentState;
    o_main <= int_main;
    o_side <= int_side;
	
END rtl;
