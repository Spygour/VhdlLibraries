library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity ClockFreq is
    generic(Freq : integer := 1000000);
    port(componentClck : inout std_logic := '1');

end ClockFreq;


architecture clk of ClockFreq is
    constant ActualPeriod : time := 1000 ms / 50000000;
    constant MaxCount : integer := 50000000 / Freq;

    signal ActlClk : std_logic := '0';

begin
    ActlClk <= not ActlClk after ActualPeriod/2;

    process(ActlClk)
        variable Counter : integer := 0;
    begin
        if(rising_edge(ActlClk)) then
            if Counter = MaxCount then
                Counter := 0;
                componentClck <= not componentClck;
            else
                Counter := Counter + 1;
            end if;
        end if;
    end process;

end architecture;