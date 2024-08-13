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
    constant Frequency    : integer := 1000000;
	 constant BytesNumber  : integer := 4;
    constant DataBit      : integer := 8;
    signal I2cAddress     : std_logic_vector(0 to 6) := B"0010101";
    signal ReadWrite      : std_logic := '0';
    signal I2cWrite       : std_logic_vector(0 to 7) := B"01011000";
    signal I2cRead        : std_logic_vector(0 to 7) := x"00";
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