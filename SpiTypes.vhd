library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

package SpiTypes is
    type SpiArray is array (0 to 20) of std_logic_vector(0 to 7);
end SpiTypes;