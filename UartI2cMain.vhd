library work;
use work.UartTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity UartI2cMain is

end UartI2cMain;

architecture sim of UartI2cMain is
    constant Frequency    : integer := 1000000;
    constant AddressBit   : integer := 7;
    constant DataBit      : integer := 8;
    signal ActlClk : std_logic := '1';

    signal I2cAddress     : std_logic_vector(6 downto 0) := B"0010101";
    signal Sda            : std_logic := '1';
    signal Scl            : std_logic;
    signal I2cReadWrite      : std_logic := '0';
    signal StartI2c       : std_logic := '0';
    signal EndI2c         : std_logic := '0';
    signal I2cWrite       : std_logic_vector(7 downto 0) := B"01011000";
    signal I2cRead        : std_logic_vector(7 downto 0) := x"00";
   
   
    constant Baudrate              : integer := 115200;
    signal Tx                      : std_logic := '1';
    signal Rx                      : std_logic := '1';
    signal HandlerTxPacket         : UartArray := (x"FA",x"0F",x"AA", others => (others => '0'));
    signal HandlerRxPacket         : UartArray := (others=> (others=>'0'));
    signal UartSize                : integer := 3;
    signal UartReadWrite               : std_logic := '1';
    signal ParityBit               : std_logic := '0';
    signal StartUartHandler        : std_logic := '0';
    signal EndUartHandler          : std_logic := '0';

begin
    I2c1 : entity work.I2c(rtl)
    generic map(Frequency  => Frequency,
               AddressBit  => AddressBit,
               DataBit     => DataBit)
    port map(ActlClk     => ActlClk,
             I2cAddress  => I2cAddress,
             Sda         => Sda,
             Scl         => Scl,
             ReadWrite   => I2cReadWrite,
             StartI2c    => StartI2c,
             EndI2c      => EndI2c,
             I2cRead     => I2cRead,
             I2cWrite    => I2cWrite);

    Uart: entity work.UartHandler(sim1)
    generic map(Baudrate      => Baudrate)
    port map(ActlClk          => ActlClk,
             Tx               => Tx,
             Rx               => Rx,
             HandlerTxPacket  => HandlerTxPacket,
             HandlerRxPacket  => HandlerRxPacket,
             UartSize         => UartSize,
             ReadWrite        => UartReadWrite,
             StartUartHandler => StartUartHandler,
             EndUartHandler   => EndUartHandler,
             ParityBit        => ParityBit);
             
    process is
    begin
        I2cWrite <= B"11111110";
        I2cReadWrite<= '0';
        I2cAddress <= B"1110000";
        StartI2c <= '1';
        wait until EndI2c = '1';
        StartI2c <= '0';
         wait for 50 us;
    end process;

    process is
    begin
        StartUartHandler <= '1';
        wait until EndUartHandler = '1';
        StartUartHandler <= '0';
        wait for 20 us;
    end process;

end architecture;