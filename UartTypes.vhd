library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

package UartTypes is
    type UartArray is array (0 to 40) of std_logic_vector(0 to 7);
    type UartMsg is array(0 to 2) of std_logic_vector(0 to 7);
    type UartReg is array(0 to 2) of UartMsg;
end UartTypes;