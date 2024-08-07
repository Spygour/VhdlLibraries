library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

package StdTypes is
    type uint8 is array(7 downto 0) of std_logic;
    type uint16 is array(15 downto 0) of std_logic;
    type uint32 is array(31 downto 0) of std_logic;
    type sint16 is array(15 downto 0) of std_logic;
    type float32 is array(31 downto 0) of std_logic;
    type size_of is array(15 downto 0) of std_logic;
end StdTypes;