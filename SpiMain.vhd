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
			Miso     : in    std_logic := 'Z';
         Cs       : out   std_logic := '1';
			StartSpiMan : in std_logic := '1');
end SpiMain;


architecture sim of SpiMain is
    constant SystemClk : integer := 50000000;
    constant Baudrate  : integer := 1000000;
    constant Cpol      : std_logic := '0';
    constant Cpha      : std_logic := '1';
    signal SpiTxMsg : SpiArray := (x"A8",x"F3",X"15",others => (others => '0'));
    signal SpiRxMsg : SpiArray := (others => (others => '0'));
    signal SpiBytes : integer := 3;
    signal StartSpi : std_logic := '0';
    signal EndSpi : std_logic := '1';
    signal DelayCounter : integer := 0;
    signal Delay : std_logic := '1';
    signal ClkStretch : std_logic := '0';
	 signal StartSpiMan_prev : std_logic := '1';

    type Spi_Transmit is
        (
				Spi_Idle,
            Spi_Start,
            Spi_Stop,
            Spi_Wait
        );
    signal SpiStateTransmit : Spi_Transmit := Spi_Start;

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


    process(ActlClk,Reset_n)
    begin
        if Reset_n = '0' then
            DelayCounter <= 0;
            Delay <= '1';
        elsif(rising_edge(ActlClk)) then
            if ClkStretch = '0' then
                DelayCounter <= 0;
            else
                if DelayCounter > SystemClk then
                    DelayCounter <= 0;
                    Delay <= '1';
                else
                    DelayCounter <= DelayCounter + 1;
                    Delay <= '0';
                end if;
            end if;
        end if;
    end process;

    process(ActlClk,Reset_n)
    begin
        if Reset_n = '0' then
            SpiBytes <= 3;
            SpiTxMsg <= (x"A8",x"54",x"35",others => (others => '0'));
            StartSpi <= '0';
			ClkStretch <= '0';
			SpiStateTransmit <= Spi_Idle; -- this is the default state
        elsif (rising_edge(ActlClk)) then
            case SpiStateTransmit is
				when Spi_Idle =>
				 if (StartSpiMan = '0' and StartSpiMan_prev = '1') then
				   StartSpiMan_prev <= StartSpiMan;
					ClkStretch <= '1'; --delay before start to avoid any bug
                    SpiStateTransmit <= Spi_Start;
				 else
					StartSpiMan_prev <= StartSpiMan;
				 end if;

                when Spi_Start =>
                    if (Delay = '1') then
                        ClkStretch <= '0';
                        StartSpi <= '1';
                        SpiStateTransmit <= Spi_Stop;
                    end if;
                
                when Spi_Stop =>
                    if (EndSpi = '0') then
                        StartSpi <= '0';
                        SpiStateTransmit <= Spi_Wait;
                    end if;
                
                when Spi_wait =>
                    if (EndSpi = '1') then
						ClkStretch <= '1';
                        SpiStateTransmit <= Spi_Idle;
                        SpiTxMsg <= SpiRxMsg;
                    end if;
                
                when others => null;
            end case;
        end if;
    end process;
end architecture;
