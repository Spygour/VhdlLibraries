use work.UartTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity UartHandler is

end UartHandler;

architecture sim1 of UartHandler is 
    constant Baudrate : integer := 115200;
    signal Tx : std_logic := '1';
    signal Rx : std_logic := '1';
    signal HandlerTxPacket : UartArray := (x"FF",x"43",x"55", others => (others => '0'));
    signal HandlerRxPacket : UartArray := (others=> (others=>'0'));
    Signal UartSize : integer := 3;
    signal ReadWrite : std_logic := '1';
    signal StartUart : std_logic := '0';
    signal EndUart : std_logic := '0';
    signal ParityBit : std_logic := '0';
    signal StartUartHandler : std_logic := '1';
    signal EndUartHandler : std_logic := '1';
    signal TxPacket : std_logic_vector(7 downto 0) := HandlerTxPacket(2)(7 downto 0);
    signal RxPacket : std_logic_vector(7 downto 0);
begin
    Uart: entity work.Uart(rtl)
    generic map(Baudrate => Baudrate)
    port map(Tx        => Tx,
             Rx        => Rx,
             TxPacket  => TxPacket,
             RxPacket  => RxPacket,
             UartSize  => UartSize,
             ReadWrite => ReadWrite,
             StartUart => StartUart,
             EndUart   => EndUart,
             ParityBit => ParityBit);
    process is
    begin
        for i in 0 to (UartSize - 1) loop
            TxPacket <= HandlerTxPacket(i)(7 downto 0);
            StartUart <= '1';
            Wait until EndUart = '1';
            StartUart <= '0';
            wait for 10 us;
        end loop;
        wait for 10 ns;
    end process;
end architecture;