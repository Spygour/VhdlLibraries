library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

package Sprite_t is record
    x_start : unsigned (8 downto 0);
    y_start : unsigned (8 downto 0);
    depth : unsigned (4 downto 0);
    width : unsigned (4 downto 0);
    Colors : array (0 to 15, 0 to 15) of std_logic_vector(8 downto 0);
end SpiTypes;