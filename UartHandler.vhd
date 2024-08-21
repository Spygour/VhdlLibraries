library work;
use work.UartTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity UartHandler is
    generic(Baudrate : integer := 115200);
    port(ActlClk :          in  std_logic := '1';
         Reset_n :          in std_logic := '0';
         Tx :               out std_logic := '1';
         Rx :               inout std_logic := '1';
         HandlerTxPacket:   in  UartArray := (others => (others => '0'));
         HandlerRxPacket:   out UartArray := (others=> (others=>'0'));
         UartSize:          in integer := 3;
         ReadWrite:         in std_logic :='1';
         StartUartHandler:  in std_logic := '1';
         EndUartHandler:    out std_logic := '1';
         ParityBit :        in std_logic := '0');

end UartHandler;

architecture sim1 of UartHandler is
    signal StartUart: std_logic := '0';
    signal StartUartHandler_prev : std_logic := '1'
    signal EndUart: std_logic := '1'; 
    signal TxPacket : std_logic_vector(0 to 7) := HandlerTxPacket(0)(0 to 7);
    signal RxPacket : std_logic_vector(0 to 7);
    type UART_HANDLER_STATE is
        (IDLE_STATE,
         PREPARE_UART,
         UART_BYTE,
         PREPARE_NEXT_BYTE,
         STOP_STATE);
    signal UartHandlerState : UART_HANDLER_STATE := IDLE_STATE;

begin
    Uart: entity work.Uart(rtl)
    generic map(Baudrate => Baudrate)
    port map(ActlClk   => ActlClk,
             Reset_n   => Reset_n,
             Tx        => Tx,
             Rx        => Rx,
             TxPacket  => TxPacket,
             RxPacket  => RxPacket,
             UartSize  => UartSize,
             ReadWrite => ReadWrite,
             StartUart => StartUart,
             EndUart   => EndUart,
             ParityBit => ParityBit);
    process(ActlClk) is
        variable byteCounter : integer range 0  to UartSize;
    begin
        if Reset_n = '0' then
            byteCounter := 0;
            TxPacket := HandlerTxPacket(0)(0 to 7);
        elsif(ActlClk'event and ActlClk = '1') then
            case UartHandlerState is
                when IDLE_STATE =>
                    if (StartUartHandler = '0' and StartUartHandler_prev = '1') then
                        StartUartHandler_prev <= StartUartHandler;
                        UartHandlerState <= PREPARE_UART;
                    else
                        StartUartHandler_prev <= StartUartHandler;
                    end if;
                
                when PREPARE_UART => 
                    UartHandlerState <= UART_BYTE;
                    StartUart <= '1';

                when UART_BYTE =>
                    if (EndUart = '0') then --Uart send has been started
                        StartUart <= '0';
                        UartHandlerState <= PREPARE_NEXT_BYTE;
                    end if;

                when PREPARE_NEXT_BYTE =>
                    if (EndUart = '1') then --Uart send has been ended
                        HandlerRxPacket(byteCounter)(0 to 7) <= RxPacket(0 to 7); -- store the RxPacket in case readWrite is '0'
                        if (byteCounter + 1) == UartSize then -- end the process
                            UartHandlerState <= STOP_STATE;
                        else
                            TxPacket <= HandlerTxPacket(byteCounter + 1)(0 to 7);
                            byteCounter := byteCounter + 1;
                            UartHandlerState <= PREPARE_UART;
                        end if;
                    end if;

                when STOP_STATE =>
                    byteCounter := 0;
                    TxPacket := HandlerTxPacket(0)(0 to 7);
                    UartHandlerState <= IDLE_STATE;

                when others => null;
                end case;
        end if;
    end process;
end architecture;
