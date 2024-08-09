library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity MainPwm is

end MainPwm;

architecture sim of MainPwm is
    constant ActualPeriod : time := 1000 ms / 50000000;
    signal ActlClk : std_logic := '1';
    signal PwmSignal1 : std_logic := '0';
    signal PwmFreq1 : integer := 1000000;
    signal DutyCycle1 : integer := 130;
    signal PhaseShift1 : integer := 0;

    signal PwmSignal2 : std_logic := '0';
    signal PwmFreq2 : integer := 1000000;
    signal DutyCycle2 : integer := 130;
    signal PhaseShift2 : integer := 35;

    signal PwmSignal3 : std_logic := '0';
    signal PwmFreq3 : integer := 1000000;
    signal DutyCycle3 : integer := 130;
    signal PhaseShift3 : integer := 70;

begin
   Pwm1 : entity work.Pwm(rtl)
   port map (ActlClk    => ActlClk,
             PwmSignal  => PwmSignal1,
             PwmFreq    => PwmFreq1,
             DutyCycle  => DutyCycle1,
             PhaseShift => PhaseShift1);

   Pwm2 : entity work.Pwm(rtl)
   port map (ActlClk    => ActlClk,
             PwmSignal  => PwmSignal2,
             PwmFreq    => PwmFreq2,
             DutyCycle  => DutyCycle2,
             PhaseShift => PhaseShift2);

    Pwm3 : entity work.Pwm(rtl)
    port map (ActlClk    => ActlClk,
             PwmSignal  => PwmSignal3,
             PwmFreq    => PwmFreq3,
             DutyCycle  => DutyCycle3,
             PhaseShift => PhaseShift3);

    process(ActlClk) is
    begin
    ActlClk <= not ActlClk after ActualPeriod/2;
    end process;
   
end architecture;
