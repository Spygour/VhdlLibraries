use work.I2cTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity MainI2c is 
    port (  ActlClk  : in  std_logic;
	        Sda      : inout std_logic;
		   Scl      : inout std_logic;
           StartI2c : in std_logic;
		   EndI2c   : out std_logic := '0';
           ResetI2c : in std_logic);
end MainI2c;

architecture sim of MainI2c is
    constant SystemFreq   : integer := 50000000;
    constant Frequency    : integer := 100000;
	 constant BytesNumber  : integer := 4;
    constant DataBit      : integer := 8;
    signal I2cAddress     : std_logic_vector(0 to 6) := B"0010010";
    signal ReadWrite      : std_logic := '1';
    signal I2cWrite       : I2cArray := (B"01011000",B"11110001", B"11100011", B"00011100",others => (others => '0'));
    signal I2cRead        : I2cArray := (others => (others => '0'));
	 signal EndI2csignal   : std_logic := '0';
begin
    I2c1 : entity work.I2c(rtl)
    generic map(SystemFreq  => systemFreq,
                Frequency   => Frequency,
                DataBit     => DataBit,
				BytesNumber => BytesNumber)
    port map(ActlClk     => ActlClk,
             Reset_n     => ResetI2c,
             I2cAddress  => I2cAddress,
             Sda         => Sda,
             Scl         => Scl,
             ReadWrite   => ReadWrite,
             StartI2c    => StartI2c,
             EndI2c      => EndI2c,
             I2cRead     => I2cRead,
             I2cWrite    => I2cWrite);
				 
				 

end architecture;