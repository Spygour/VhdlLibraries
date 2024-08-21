library work;
use work.UartTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity MainUart is 
    port(ActlClk          : in std_logic := '1';
         Reset_n          : in std_logic := '0';
         StartUartHandler : in std_logic := '0';
         EndUartHandler   : out std_logic := '0';
         Tx               : out std_logic;
         Rx               : in  std_logic);
end MainUart;


architecture sim of MainUart is
    constant SystemClk : integer := 50000000;
    constant Baudrate : integer := 115200;
    signal TxMessage : UartArray := (x"4D", x"41", x"4C", x"41", x"4B", x"41", x"53",others => (others => '0'));
    signal RxMessage : UartArray := (others => (others => '0'));
    signal ReadWrite : std_logic := '1';
    signal ParityBit : std_logic := '0';
    signal UartSize : integer := 7;
	 signal EndHandler : std_logic := '0';

begin
    Uart : entity work.UartHandler(rtl2)
    generic map(SystemClk     => SystemClk,
                Baudrate      => Baudrate)
    port map(ActlClk          => ActlClk,
             Reset_n          => Reset_n,
             Tx               => Tx,
             Rx               => Rx,
             HandlerTxPacket  => TxMessage,
             HandlerRxPacket  => RxMessage,
             UartSize         => UartSize,
             ReadWrite        => ReadWrite,
             StartUartHandler => StartUartHandler,
             EndUartHandler   => EndHandler,
             ParityBit        => ParityBit);
				 
				 
	EndUartHandler <= EndHandler;
	end architecture;
