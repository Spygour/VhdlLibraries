library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity ClockFreq is
    generic(Freq : integer := 1000000);
    port(ActlClk      : in std_logic := '1';
        componentClck : inout std_logic := '1');

end ClockFreq;


architecture clk of ClockFreq is
    constant MaxCount : integer := 25000000 / Freq;


begin

    process(ActlClk) is
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