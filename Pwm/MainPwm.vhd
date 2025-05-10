library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity MainPwm is
    port ( ActlClk    : in std_logic;
	        PwmSignal1 : out std_logic := '1';
			  PwmSignal2 : out std_logic := '1';
			  Reset      : in std_logic := '0');
end MainPwm;

architecture sim of MainPwm is
    constant ClkFreq : integer := 50000000; 
    constant PwmFreq1 : integer := 1000000;
	 signal PwmSignal1_reg : std_logic := '1';
	 signal PwmSignal2_reg : std_logic := '1';
    signal DutyCycle1 : integer := 130;
    signal PhaseShift1 : integer := 0;
	 signal DutyCycle2 : integer := 200;
    signal PhaseShift2 : integer := 35;

begin
   Pwm1 : entity work.Pwm(rtl)
	generic map (ClkFreq => ClkFreq,
	             PwmFreq => PwmFreq1)
					 
   port map (Clk        => ActlClk,
             PwmSignal  => PwmSignal1_reg,
             DutyCycle  => DutyCycle1,
             PhaseShift => PhaseShift1,
			    Reset_n    => Reset);
				 
	Pwm2 : entity work.Pwm(rtl)
	generic map (ClkFreq => ClkFreq,
	             PwmFreq => PwmFreq1)
					 
   port map (Clk        => ActlClk,
             PwmSignal  => PwmSignal2_reg,
             DutyCycle  => DutyCycle2,
             PhaseShift => PhaseShift2,
			    Reset_n    => Reset);
				 
   PwmSignal1 <= PwmSignal1_reg;
	PwmSignal2 <= PwmSignal2_reg;
end architecture;
