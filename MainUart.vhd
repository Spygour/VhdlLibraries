library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity MainUart is 
    port(ActlClk   : in std_logic := '1';
         Reset_n   : in std_logic := '0';
         StartUart : in std_logic := '0';
         EndUart   : out std_logic := '0';
         Tx        : out std_logic := '1';
         Rx        : in  std_logic := '1');
end MainUart;


architecture sim of MainUart is
    constant SystemClk : integer := 50000000;
    constant Baudrate : integer := 115200;
    signal TxPacket : std_logic_vector(0 to 7) := B"01000001";
    signal RxPacket : std_logic_vector(0 to 7);
    signal ReadWrite : std_logic := '0';
    signal ParityBit : std_logic := '0';

begin
    Uart : entity work.Uart(rtl)
    generic map(SystemClk => SystemClk,
                Baudrate  => Baudrate)
    port map(ActlClk   => ActlClk,
             Reset_n   => Reset_n,
             Tx        => Tx,
             Rx        => Rx,
             TxPacket  => TxPacket,
             RxPacket  => RxPacket,
             ReadWrite => ReadWrite,
             StartUart => StartUart,
             EndUart   => EndUart,
             ParityBit => ParityBit);
    

end architecture;