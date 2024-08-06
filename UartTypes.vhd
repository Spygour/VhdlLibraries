library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

package UartTypes is
    type UartArray is array (0 to 49) of std_logic_vector(7 downto 0);
end UartTypes;