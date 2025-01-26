library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.SpiSlaveTypes.all;

entity SpiSlave is
    
    port(ActlClk : in std_logic := '1';
         Clk      : in std_logic := '1';
         SpiClk   : in std_logic := '0';
         Reset_n  : in std_logic := '1';
         SO     : out std_logic := '0';
         SI     : in  std_logic := '0';
         CS       : in std_logic := '1';
         StartSpi : in  std_logic := '0';
         EndSpi   : inout std_logic := '1';
         Words : out integer := 0;
         WrEn : inout std_logic := '0';
		 WriteDataWord : inout SpiWord := (others => '0');
         WriteAddress  : inout std_logic_vector (6 DOWNTO 0);
         ReadAddress : in std_logic_vector (6 DOWNTO 0));

end SpiSlave;

architecture rtl of SpiSlave is

constant SpiBits : integer   := 16;
constant SpiWords : integer := 100;

signal SpiBitCnt  : unsigned (4 downto 0) := (others => '0');
signal SpiWordCounter : integer := 0;
signal CS_reg : std_logic := '0';
signal SI_reg : std_logic := '0';
signal SpiClk_reg : std_logic := '0';
signal Words_reg : integer := 0;
signal SpiSlaveState : Spi_State := IDLE_STATE;


signal SpiTxWord : SpiWord  := (others => '0');
signal SpiRxWord : SpiWord  := (others => '0');

begin

    CS_reg <= CS;
    SI_reg <= SI;
    SpiClk_reg <= SpiClk;

    process(Clk, Reset_n) is
    begin
        if (Reset_n = '1') then
            SpiBitCnt <= (others => '0');
            SpiWordCounter <= 0;
            SpiSlaveState <= IDLE_STATE;
            WriteAddress <= (others => '0');
            SO <= '0';
            WrEn <= '1';
            Words <= 0;
				Words_reg <= 0;
        elsif rising_edge(Clk) then
            case SpiSlaveState is
                when IDLE_STATE =>
                    if ( (CS_reg = '0') and (StartSpi = '1') )  then
                        Words_reg <= 0;
                        SpiSlaveState <= READ_BIT;
                        EndSpi <= '0';
                        SpiBitCnt <= (others => '0');
                        SpiWordCounter <= 0;
                        SO <= '0';
                        -- Store Word
                        WrEn <= '1';
                    end if;
                
                when READ_BIT =>
                    if (CS_reg = '1') then
                        WriteDataWord <= SpiRxWord;
                        SpiSlaveState <= END_STATE;
                    elsif (SpiClk_reg = '1') then
                        SpiRxWord(to_integer(SpiBitCnt)) <= SI_reg;
                        SpiSlaveState <= DECEIDE_STATE;
                    end if;
                    WrEn <= '1';
                
                when DECEIDE_STATE =>
                    if (SpiBitCnt=x"10") then
                        SpiBitCnt <= (others => '0');
                        WriteDataWord <= SpiRxWord;
                        SpiTxWord <= SpiRxWord;
                        if (SpiWordCounter = SpiWords) then
                            SpiSlaveState <= END_STATE;
                        elsif SpiWordCounter < SpiWords then
                            -- End
                            SpiWordCounter <= SpiWordCounter + 1;
                            Words_reg <= Words_reg + 1;
                            SpiSlaveState <= WRITE_BIT; 
                        end if;
                    else
                        SO <= SpiTxWord(to_integer(SpiBitCnt));
                        SpiBitCnt <= SpiBitCnt + 1;
                        SpiSlaveState <= READ_BIT;
                    end if;
                    
                
                when WRITE_BIT =>
                    if (SpiClk_reg = '0') then
                        if (CS_reg = '0') then
                            WrEn <= '0';
                            -- Update Write Address
                            WriteAddress <= std_logic_vector(unsigned(WriteAddress) + 1);
                            SO <= '0';
                            SpiBitCnt <= (others => '0');
                            SpiSlaveState <= READ_BIT;
                        elsif (StartSpi = '0') then
                            -- Store Word
                            WrEn <= '1';
                            WriteDataWord <= SpiRxWord;
                            SpiSlaveState <= END_STATE;
                        else
                            -- Store Word
                            WrEn <= '1';
                            WriteDataWord <= SpiRxWord;
                            SpiSlaveState <= END_STATE;
                        end if;
                    end if;


                when END_STATE =>
                    if (CS_reg = '1') then
						      Words <= Words_reg;
                        -- Deactivate Write Enable
                        WrEn <= '0';
                        -- Reset the Write Address
                        WriteAddress <= (others => '0');
                        SpiSlaveState <= IDLE_STATE;
                        EndSpi <= '1';
                    end if;

                when others => NULL;
            
            end case;
				end if;
    end process;
	 
end architecture;