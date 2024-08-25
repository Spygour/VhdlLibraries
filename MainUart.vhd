library work;
use work.UartTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity MainUart is 
    port(ActlClk          : in std_logic := '1';
         Reset_n          : in std_logic := '0';
         EndHandler       : out std_logic := '0';
         Tx               : out std_logic := '1';
         Rx               : in  std_logic :='1');
end MainUart;


architecture sim of MainUart is
    constant SystemClk : integer := 50000000;
    constant Baudrate : integer := 115200;
    signal TxMessage : UartArray := (x"F3", x"41", x"A5", x"41", x"C6", x"41", x"97",others => (others => '0'));
    signal RxMessage : UartArray := (others => (others => '0'));
    signal ReadWrite : std_logic := '1';
    signal ParityBit : std_logic := '0';
    signal UartSize : integer := 7;
	signal StartUartHandler : std_logic := '0';
	signal EndUartHandler : std_logic := '1';
    signal Clk : std_logic := '1';
    signal Delay : std_logic := '0';
    signal ClkStretch : std_logic := '0';
    signal Counter : integer := 0;
    type Uart_State is 
        (START_TRANSMIT,
         WAIT_END,
         RESTART);
    signal MainUarState : Uart_State := START_TRANSMIT;

begin
    Uart : entity work.Uart(rtl)
    generic map(SystemClk     => SystemClk,
                Baudrate      => Baudrate)
    port map(ActlClk          => ActlClk,
             Clk              => Clk,
             Reset_n          => Reset_n,
             Tx               => Tx,
             Rx               => Rx,
             HandlerTxPacket  => TxMessage,
             HandlerRxPacket  => RxMessage,
             UartSize         => UartSize,
             ReadWrite        => ReadWrite,
             StartUart        => StartUartHandler,
             EndUart          => EndUartHandler,
             ParityBit        => ParityBit);
				 
    EndHandler <= EndUartHandler;

process(ActlClk)
begin
    if(ActlClk'event and ActlClk = '1') then
        if ClkStretch = '1' then
            Counter <= 0;
        else
            if Counter > SystemClk then
                Counter <= 0;
                Delay <= '1';
            else
                Counter <= Counter + 1;
                Delay <= '0';
            end if;
        end if;
    end if;
end process;

process(ActlClk)
begin
    if (ActlClk'event and ActlClk='1') then
        case MainUarState is
            when START_TRANSMIT =>
                if (StartUartHandler = '0' and EndUartHandler = '1' and Delay = '1') then
                    StartUartHandler <= '1';
						  ClkStretch <= '1';
                    MainUarState <= WAIT_END;
                end if;
            when WAIT_END =>
                IF (EndUartHandler = '0' and StartUartHandler = '1') then
                    StartUartHandler <= '0';
                    MainUarState <= RESTART;
                end if;
            when RESTART =>
                if (EndUartHandler = '1') then
                    ClkStretch <= '0';
                    MainUarState <= START_TRANSMIT;
                end if;
            when others => null;
            end case;
        end if;
                    
end process;
	end architecture;