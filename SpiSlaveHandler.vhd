library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.SpiSlaveTypes.all;

entity SpiSlaveHandler is
    
    port(ActlClk : in std_logic := '1';
         SpiClk   : in std_logic := '0';
         Reset_n  : in std_logic := '1';
         SO     : out std_logic := '0';
         SI     : in  std_logic := '0';
         CS       : in std_logic := '1';
			Leds  : out std_logic_vector (0 to 7) := "11111111";
         SpiReady : out std_logic := '0');

end SpiSlaveHandler;

architecture rtl of SpiSlaveHandler is

constant SpiBits : integer   := 16;
constant SpiWords : integer := 100;

signal Clk      : std_logic := '0';
signal StartSpi : std_logic := '0';
signal WrEn     : std_logic := '1';
signal WriteDataWord : SpiWord := (others => '0');
signal ReadDataWord  : SpiWord;
signal WriteAddress : std_logic_vector (6 DOWNTO 0) := (others => '0');
signal ReadAddress : std_logic_vector (6 DOWNTO 0) := (others => '0');
signal SpiPllLocked : std_logic := '0';
signal Words : integer := 0;
signal EndSpi : std_logic := '1';
--signal SpiSlaveState : Spi_State;

signal SpiTxWord : SpiWord  := (others => '0');
signal SpiRxWord : SpiWord  := (others => '0');
signal SpiHandlerState : Spi_Handler_State := IDLE_STATE;

begin
	 Spipll:entity work.SpiPll(SYN)
    port map
    (
        areset => Reset_n,
		inclk0 => ActlClk,	
		c0     => Clk,
		locked =>  SpiPllLocked
    );
	 
	 SpiRam:entity work.SpiRam(SYN)
    port map
    (
      clock		=> Clk,
      data		=> WriteDataWord,
      rdaddress	=> ReadAddress,
      wraddress	=> WriteAddress,
      wren		=> WrEn,
      q		    => ReadDataWord
    );
	 
	 SpiSlave:entity work.SpiSlave(rtl)
    port map
    (
        ActlClk       => ActlClk,
        Clk           => Clk,
        SpiClk        => SpiClk,
        Reset_n       => Reset_n,
        SO            => SO, 
        SI            => SI,
        CS            => CS,
        StartSpi      => StartSpi,
        EndSpi        => EndSpi,
        Words         => Words,
        WrEn          => WrEn,
		    WriteDataWord => WriteDataWord,
        WriteAddress   => WriteAddress,
        ReadAddress   => ReadAddress,
        lockedloop  => SpiPllLocked
    );

    process(Clk, Reset_n, SpiPllLocked) is
	 variable memoryPart : std_logic := '0';
    begin
        if (Reset_n = '1') then
				StartSpi <= '0';
				memoryPart := '0';
        SpiHandlerState <= IDLE_STATE;
        SpiReady <= '0';
		  Leds <= "11111111";
        elsif rising_edge(Clk) and SpiPllLocked = '1' then
          case SpiHandlerState is
            when IDLE_STATE =>
              StartSpi <= '1';
              SpiHandlerState <= ACTIVATE_SPI;
              ReadAddress <= (others => '0');

            when ACTIVATE_SPI =>
              SpiReady <= '1';
              SpiHandlerState <= END_STATE;
            
            when END_STATE =>
              if (WrEn = '0') then
                if (memoryPart = '0') then
                  Leds <= ReadDataWord(0 to 7);
                else
                  Leds <= ReadDataWord(8 to 15);
                end if;
                SpiHandlerState <= IDLE_STATE;
              end if;
              if (EndSpi = '1') then
                SpiReady <= '0';
                memoryPart := not memoryPart;
              end if;
          
            when others => NULL;

          end case;
            
		    end if;
    end process;

end architecture;