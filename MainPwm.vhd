library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity MainPwm is

end MainPwm;

architecture sim of MainPwm is
    constant ActualPeriod : time := 1000 ms / 50000000;
    signal ActlClk : std_logic := '1';
    signal PwmSignal : std_logic := '0';
    signal PwmFreq : integer := 1000000;
    signal DutyCycle : integer := 130;
    signal PhaseShift : integer := 0;

begin
   Pwm : entity work.Pwm(rtl)
   port map (ActlClk    => ActlClk,
             PwmSignal  => PwmSignal,
             PwmFreq    => PwmFreq,
             DutyCycle  => DutyCycle,
             PhaseShift => PhaseShift);
    process(ActlClk) is
    begin
    ActlClk <= not ActlClk after ActualPeriod/2;
    end process;
   
end architecture;
