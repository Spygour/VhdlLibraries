library work;
library work;
use work.SpiTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity Spi is
    generic(SystemClk : integer := 50000000;
            Baudrate  : integer := 1000000;
            Cpol      : std_logic := '0';
            Cpha      : std_logic := '1');
    
    port(ActlClk  : in std_logic := '1';
         SpiClk   : inout std_logic := '0';
         Reset_n  : in std_logic := '0';
         Mosi     : out std_logic := '1';
         Miso     : in  std_logic := '1';
         CS       : out std_logic := '1';
         SpiTxMsg : in  SpiArray  := (others => (others => '0'));
         SpiRxMsg : out SpiArray  := (others => (others => '0'));
         SpiBytes : in  integer   := 3;
         StartSpi : in  std_logic := '1';
         EndSpi   : out std_logic := '1');

end Spi;

architecture rtl of Spi is

constant SpiPeriodDiv : integer := SystemClk / (2*Baudrate);

signal SpiClk_prev    : std_logic := '1';
signal StartClk       : std_logic := '0';
signal SpiClkCounter  : integer := 0;
signal SpiBitCounter  : integer := 0;
signal SpiByteCounter : integer := 0;
signal StartSpi_prev  : std_logic := '0';
signal SpiTxByte      : std_logic_vector(0 to 7) := (others => '0');
signal SpiRxByte      : std_logic_vector(0 to 7) := (others => '0');
signal Mosi_reg       : std_logic := '1';
signal Cs_reg         : std_logic := '1';
signal Mosi_Clk       : std_logic := '0';
signal Mosi_Clk_prev  : std_logic := '0';

type Spi_State is
    (IDLE_STATE,
     WRITE_SPI,
	  READ_SPI,
     EVALUATE_BYTE,
     END_STATE);
signal SpiState : Spi_State := IDLE_STATE;

begin
    process(ActlClk,Reset_n) is
    begin
        if (Reset_n = '0') then
            SpiClkCounter <= 0;
            SpiClk <= Cpol;
            Mosi_Clk <= '1';
            Mosi_Clk_prev <= '1';
        elsif rising_edge(ActlClk) then
            SpiClk_prev <= SpiClk;
            Mosi_Clk_prev <= Mosi_Clk;
            if (StartClk = '0') then
                SpiClkCounter <= 0;
                SpiClk <= Cpol;
                Mosi_Clk <= '1';
                Mosi_Clk_prev <= '1';
            else
                if (SpiClkCounter = SpiPeriodDiv) then
                    SpiClkCounter <= 0;
                    SpiClk <= not SpiClk;
                elsif (SpiClkCounter = (SpiPeriodDiv/2)) then
                    Mosi_Clk <= SpiClk;
                    SpiClkCounter <= SpiClkCounter + 1;
                else
                    SpiClkCounter <= SpiClkCounter + 1;
                end if;
            end if;
        end if;
    end process;

    process(ActlClk,Reset_n) is
    begin
        if (Reset_n = '0') then
            SpiBitCounter <= 0;
            SpiByteCounter <= 0;
            StartClk <= '0';
            SpiState <= IDLE_STATE;
            Cs_reg <= '1';
            Mosi_reg <= '1';
        elsif rising_edge(ActlClk) then
            case SpiState is
                when IDLE_STATE =>
                   if(StartSpi = '0' and StartSpi_prev = '1') then
                        Cs_reg <= '0';
                        StartSpi_prev <= StartSpi;
                        SpiBitCounter <= 0;
                        SpiByteCounter <= 0;
                        SpiTxByte(0 to 7) <= SpiTxMsg(0)(0 to 7); 
                        SpiRxByte(0 to 7) <= (others => '0');
                        StartClk <= '1';
                        EndSpi <= '0';
                        SpiState <= WRITE_SPI;
                   else
                        StartSpi_prev <= StartSpi;
                   end if;

                when EVALUATE_BYTE =>
                   SpiBitCounter <= 0;
                   SpiRxMsg(SpiByteCounter - 1)(0 to 7) <= SpiRxByte;
                   if (SpiByteCounter = SpiBytes) then
                        SpiState <= END_STATE;
                   else
                        SpiTxByte(0 to 7) <= SpiTxMsg(SpiByteCounter)(0 to 7);
                        SpiState <= WRITE_SPI;
                   end if;
                   
                when END_STATE =>
                   if (SpiClk = Cpol) then
                        StartClk <= '0';
                        EndSpi <= '1';
                        Cs_reg <= '1';
                        Mosi_reg<= '1';
                        SpiState <= IDLE_STATE;
                   end if;

                when others => null;
            end case;

            if  (Mosi_Clk = '0' and Mosi_Clk_prev = '1') then
                case SpiState is
                    when WRITE_SPI =>
                        Mosi_reg <= SpiTxByte(SpiBitCounter);
						SpiState <= READ_SPI;

                    when others => null;
                end case;
			end if;
            
            if (SpiClk = (not Cpha) and SpiClk_prev = Cpha) then
                case SpiState is
                    when READ_SPI =>
                        SpiRxByte(SpiBitCounter) <= Miso;
                        if (SpiBitCounter + 1) = 8 then
                            SpiRxMsg(SpiByteCounter)(0 to 7) <= SpiRxByte;
                            SpiByteCounter <= SpiByteCounter + 1;
                            SpiState <= EVALUATE_BYTE;
                        else
                            SpiBitCounter <= SpiBitCounter + 1;
							SpiState <= WRITE_SPI;
                        end if;

                    when others => null;
                end case;
            end if;
        end if;

    end process;

    Mosi <= Mosi_reg;
    Cs   <= Cs_reg;
end architecture;