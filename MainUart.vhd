use work.UartTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;


entity MainUart is 

end MainUart;

architecture sim of MainUart is
    constant ActualPeriod : time := 1000 ms / 50000000;
    constant Baudrate              : integer := 115200;
    signal ActlClk                 : std_logic := '1';
    signal Tx                      : std_logic := '1';
    signal Rx                      : std_logic := '1';
    signal HandlerTxPacket         : UartArray := (x"FA",x"0F",x"AA", others => (others => '0'));
    signal HandlerRxPacket         : UartArray := (others=> (others=>'0'));
    signal UartSize                : integer := 3;
    signal ReadWrite               : std_logic := '1';
    signal ParityBit               : std_logic := '0';
    signal StartUartHandler        : std_logic := '0';
    signal EndUartHandler          : std_logic := '0';

begin
    Uart: entity work.UartHandler(sim1)
    generic map(Baudrate      => Baudrate)
    port map(ActlClk          => ActlClk,
             Tx               => Tx,
             Rx               => Rx,
             HandlerTxPacket  => HandlerTxPacket,
             HandlerRxPacket  => HandlerRxPacket,
             UartSize         => UartSize,
             ReadWrite        => ReadWrite,
             StartUartHandler => StartUartHandler,
             EndUartHandler   => EndUartHandler,
             ParityBit        => ParityBit);

    process(ActlClk) is
    begin
    ActlClk <= not ActlClk after ActualPeriod/2;
    end process;
    
    process is
    begin
        StartUartHandler <= '1';
        wait until EndUartHandler = '1';
        StartUartHandler <= '0';
        wait for 20 us;
    end process;
end architecture;