library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;


entity MainUart is 

end MainUart;

architecture sim of MainUart is
    type UartArray is array (7 downto 0,49 downto 0) of unsigned;
    constant Baudrate        : integer := 115200;
    signal Tx                : std_logic := '1';
    signal Rx                : std_logic := '1';
    signal TxMessage         : UartArray;
    signal RxMessage         : UartArray;
    signal UartSize          : integer := 2;
    signal ReadWrite         : std_logic := '1';
    signal StartUart         : std_logic := '0';
    signal EndUart           : std_logic := '0';
    signal ParityBit         : std_logic := '0';
    signal StartUartHandler  : std_logic := '0';
    signal EndUartHandler    : std_logic := '0';

begin
    Uart: entity work.UartHandler(sim1)
    generic map(Baudrate      => Baudrate)
    port map(Tx               => Tx,
             Rx               => Rx,
             HandlerTxPacket  => TxMessage,
             HandlerRxPacket  => RxMessage,
             UartSize         => UartSize,
             ReadWrite        => ReadWrite,
             StartUart        => StartUart,
             EndUart          => EndUart,
             ParityBit        => ParityBit,
             StartUartHandler => StartUartHandler,
             EndUartHandler   => EndUartHandler);
    
    TxMessage(7 downto 0,0) <= B"01010101";
    TxMessage(7 downto 0,1) <= B"10101010";
    process is
    begin
        StartUartHandler <= '1';
        wait until EndUartHandler = '1';
        StartUartHandler <= '0';
        wait for 20 us;
    end process;
end architecture;