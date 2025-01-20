library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package VgaTypes is 
    type SpriteColor_t is array (0 to 15, 0 to 15) of std_logic_vector(8 downto 0);
    type LineColor_t is array (0 to 800) of std_logic_vector(8 downto 0);


    type Sprite_t is record
        x_start : unsigned (9 downto 0);
        y_start : unsigned (9 downto 0);
        sprite_depth : unsigned (4 downto 0);
        sprite_width : unsigned (4 downto 0);
        Colors : SpriteColor_t;
    end record;

end VgaTypes;