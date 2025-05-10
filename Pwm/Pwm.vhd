library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity Pwm is
generic (ClkFreq : integer := 50000000; 
         PwmFreq : integer := 1000000);
port(
    Clk        : in std_logic := '1';
    PwmSignal  : out std_logic;
    DutyCycle  : in integer range 0 to 255;
    PhaseShift : in integer range 0 to 100;
    Reset_n    : in std_logic := '0'
);
end Pwm;

architecture rtl of Pwm is
    constant ActlPeriod : integer := ClkFreq / PwmFreq;
    signal Cm0 : integer;
    signal Cm1 : integer;
    signal PwmSignal_reg : std_logic := '0';
begin
    PwmSignal <= PwmSignal_reg;
    process(Clk)
	 begin
	     if falling_edge(Clk) then
			Cm0 <= (PhaseShift * ActlPeriod) / 100;
			Cm1 <= ((PhaseShift * ActlPeriod) / 100 + (DutyCycle * ActlPeriod) / 255) mod ActlPeriod;
		 end if;
	 END PROCESS;

	 process(Clk, Reset_n)
		variable Counter : integer range 0 to ActlPeriod;
	begin
		if rising_edge(Clk) then
			if Reset_n = '0' then
				Counter := 0;
				PwmSignal_reg <= '0';
			else
			   If Cm0 < Cm1 then
					if Counter = ActlPeriod then
						Counter := 0;
					elsif Counter < Cm0  then
						PwmSignal_reg <= '0';
					elsif Counter < Cm1 then
						PwmSignal_reg <= '1';
					else
						PwmSignal_reg <= '0';
					end if;
				else
					if Counter = ActlPeriod then
						Counter := 0;
					elsif Counter < Cm1  then
						PwmSignal_reg <= '1';
					elsif Counter < Cm0 then
						PwmSignal_reg <= '0';
					else
						PwmSignal_reg <= '1';
					end if;	
            end if;					
				
				Counter := Counter + 1;
			end if;
		end if;
	end process;
	 

end architecture;