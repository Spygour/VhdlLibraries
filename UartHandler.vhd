use work.UartTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity UartHandler is
    generic(Baudrate : integer := 115200);
    port(ActlClk :          inout  std_logic := '1';
         Tx :               out std_logic := '1';
         Rx :               inout std_logic := '1';
         HandlerTxPacket:   in  UartArray := (x"FF",x"43",x"55", others => (others => '0'));
         HandlerRxPacket:   out UartArray := (others=> (others=>'0'));
         UartSize:          in integer := 3;
         ReadWrite:         in std_logic :='1';
         StartUartHandler:  in std_logic := '0';
         EndUartHandler:    out std_logic := '0';
         ParityBit :        in std_logic := '0');

end UartHandler;

architecture sim1 of UartHandler is
    signal StartUart: std_logic := '0';
    signal EndUart: std_logic := '0'; 
    signal TxPacket : std_logic_vector(7 downto 0) := HandlerTxPacket(UartSize - 1)(7 downto 0);
    signal RxPacket : std_logic_vector(7 downto 0);
begin
    Uart: entity work.Uart(rtl)
    generic map(Baudrate => Baudrate)
    port map(ActlClk   => ActlClk,
             Tx        => Tx,
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
        if StartUartHandler = '1' and ReadWrite = '1' then
            for i in 0 to (UartSize - 1) loop
                TxPacket <= HandlerTxPacket(i)(7 downto 0);
                StartUart <= '1';
                Wait until EndUart = '1';
                StartUart <= '0';
                wait for 10 us;
            end loop;
            EndUartHandler <= '1';
        elsif StartUartHandler = '1' and ReadWrite = '0' then
            for i in 0 to (UartSize - 1) loop
                StartUart <= '1';
                Wait until EndUart = '1';
                StartUart <= '0';
                HandlerRxPacket(i)(7 downto 0) <= RxPacket;
                wait for 10 us;
            end loop;
            EndUartHandler <= '1';
        else
            EndUartHandler <= '0';
        end if;
        wait for 10 ns;
    end process;
end architecture;