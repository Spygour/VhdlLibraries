library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

package I2cTypes is
    type I2cArray is array (0 to 10) of std_logic_vector(0 to 7);
end I2cTypes;