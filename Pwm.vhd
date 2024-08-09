library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity Pwm is
port(ActlClk   : in std_logic := '1';
     PwmSignal : inout std_logic := '0';
     PwmFreq   : in integer := 1000000;
     DutyCycle : in integer range 0 to 255;
     PhaseShift : in integer range 0 to 100);
end Pwm;


architecture rtl of Pwm is
    constant ActlPeriod : integer := 50000000 / PwmFreq;
    signal Cm0 : integer := 0;
    signal Cm1 : integer := 100;
    signal Init : std_logic := '0';
    signal Counter : integer := 0;
begin
    process(ActlClk) is
        variable Cm0Var : integer := (PhaseShift*ActlPeriod) / 100;
        variable Cm1Var : integer := (PhaseShift*ActlPeriod) / 100 + (DutyCycle*ActlPeriod) / 255;
    begin
        If Init = '1' then
            if (rising_edge(ActlClk)) then
                Counter <= Counter + 1;
                if Counter = ActlPeriod then
                    Counter <= 0;
                elsif Counter = Cm0 then
                    PwmSignal <= '1';
                elsif Counter = Cm1 then
                    PwmSignal <= '0';
                end if;
            end if;
        else
            while (Cm0Var > ActlPeriod) loop
                Cm0Var := Cm0Var - ActlPeriod;
            end loop;
    
            while (Cm1Var > ActlPeriod) loop
                Cm1Var := Cm1Var - ActlPeriod;
            end loop;
            Cm0 <= Cm0Var;
            Cm1 <= Cm1Var;
            Init <= '1';
        end if;
    end process;

end architecture;