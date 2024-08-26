library work;
use work.SpiTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity SpiMain is
    port(ActlClk  : in std_logic := '1';
		 SpiClk   : inout std_logic := '0';
         Reset_n  : in    std_logic := '0';
         Mosi     : out   std_logic := '1';
			Miso     : in    std_logic := '1';
         Cs       : out   std_logic := '1';
         StartSpi : in    std_logic := '0';
         EndSpi   : out   std_logic := '1');
end SpiMain;


architecture sim of SpiMain is
    constant SystemClk : integer := 50000000;
    constant Baudrate  : integer := 1000000;
    constant Cpol      : std_logic := '1';
    constant Cpha      : std_logic := '0';
    signal SpiTxMsg : SpiArray := (x"A8",x"54",x"35",x"FE",others => (others => '0'));
    signal SpiRxMsg : SpiArray := (others => (others => '0'));
    signal SpiBytes : integer := 4;

begin
    Spi : entity work.Spi(rtl)
    generic map (SystemClk => SystemClk,
                 Baudrate  => Baudrate,
                 Cpol      => Cpol,
                 Cpha      => Cpha)
    port map(ActlClk  => ActlClk,
             SpiClk   => SpiClk,
             Reset_n  => Reset_n,
             Mosi     => Mosi,
             Miso     => Miso,
             CS       => CS,
             SpiTxMsg => SpiTxMsg,
             SpiRxMsg => SpiRxMsg,
             SpiBytes => SpiBytes,
             StartSpi => StartSpi,
             EndSpi   => EndSpi);
end architecture;
