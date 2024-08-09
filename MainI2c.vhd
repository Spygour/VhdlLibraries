library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity MainI2c is 

end MainI2c;

architecture sim of MainI2c is
    constant ActualPeriod : time := 1000 ms / 50000000;
    constant Frequency    : integer := 1000000;
    constant AddressBit   : integer := 7;
    constant DataBit      : integer := 8;
    signal ActlClk        : std_logic := '1';
    signal I2cAddress     : std_logic_vector(6 downto 0) := B"0010101";
    signal Sda            : std_logic := '1';
    signal Scl            : std_logic;
    signal ReadWrite      : std_logic := '0';
    signal StartI2c       : std_logic := '0';
    signal EndI2c         : std_logic := '0';
    signal I2cWrite       : std_logic_vector(7 downto 0) := B"01011000";
    signal I2cRead        : std_logic_vector(7 downto 0) := x"00";
begin
    I2c1 : entity work.I2c(rtl)
    generic map(Frequency  => Frequency,
               AddressBit  => AddressBit,
               DataBit     => DataBit)
    port map(ActlClk     => ActlClk,
             I2cAddress  => I2cAddress,
             Sda         => Sda,
             Scl         => Scl,
             ReadWrite   => ReadWrite,
             StartI2c    => StartI2c,
             EndI2c      => EndI2c,
             I2cRead     => I2cRead,
             I2cWrite    => I2cWrite);

    process(ActlClk) is
    begin
    ActlClk <= not ActlClk after ActualPeriod/2;
    end process;

    process is
    begin
     I2cWrite <= B"11111110";
     ReadWrite<= '0';
     I2cAddress <= B"1110000";
     StartI2c <= '1';
     wait until EndI2c = '1';
     StartI2c <= '0';
     wait for 50 us;
    end process;
end architecture;
