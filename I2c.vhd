library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity I2c is
    generic(Frequency   : integer := 1000000;
            AddressBit  : integer := 7;
            DataBit     : integer := 8);

    port(I2cAddress  : in std_logic_vector(6 downto 0)  := B"0000000";
         Sda         : inout std_logic := '1';
         Scl         : inout std_logic := '1';
         ReadWrite   : in std_logic := '0';
         StartI2c    : in    std_logic;
         EndI2c      : out std_logic := '0';
         I2cRead     : inout std_logic_vector(7 downto 0);
         I2cWrite    : in std_logic_vector(7 downto 0)  := B"00000000");
end I2c;

architecture rtl of I2c is
    constant SclPeriod : time := 1000 ms /Frequency;
    type I2C_STATE is
       (START_TRANSMIT,
        ADDRESS_FRAME,
        READ_WRITE_BIT,
        ACK_NACK_BIT_ADDRESS,
        DATA_FRAME_READ,
        DATA_FRAME_WRITE,
        ACK_NACK_BIT_END,
        STOP_TRANSMIT);
    signal I2cState : I2C_STATE := START_TRANSMIT;
    signal DataCounter : integer := AddressBit-1;
begin
    Clock : entity work.ClockFreq(clk)
    generic map(Freq => Frequency)
    port map(componentClck => Scl);
    process(Scl) is
    begin
        if I2cState = START_TRANSMIT and Scl = '1' then
          if StartI2c = '1' then
              Sda <= '0';
              EndI2c <= '0';
              I2cState <= ADDRESS_FRAME;
          end if;
         end if;
        if (falling_edge(Scl)) then
            case I2cState is
                when ADDRESS_FRAME =>
                    Sda         <= I2cAddress(DataCounter);
                    DataCounter <= DataCounter - 1;
                    if DataCounter = 0 then
                     I2cState <= READ_WRITE_BIT;
                     DataCounter <= DataBit;
                    end if;
                when READ_WRITE_BIT =>
                   Sda      <= ReadWrite;
                   I2cState <= ACK_NACK_BIT_ADDRESS;
                when ACK_NACK_BIT_ADDRESS =>
                   if Sda = '0' then
                    if ReadWrite = '0' then
                       I2cState <= DATA_FRAME_WRITE;
                    else
                       I2cState <= DATA_FRAME_READ;
                    end if;
                   else
                    I2cState <= START_TRANSMIT;
                    Sda      <= '1';
                    DataCounter <= AddressBit-1;
                   end if;
                when DATA_FRAME_WRITE =>
                   if DataCounter = 0 then
                    I2cState <= ACK_NACK_BIT_END;
                   else 
                    Sda <= I2cWrite(DataCounter - 1);
                    DataCounter <= DataCounter - 1;
                   end if;
                when DATA_FRAME_READ =>
                   if DataCounter = 0 then
                    I2cState <= ACK_NACK_BIT_END;
                   else
                    I2cRead(DataCounter - 1) <= Sda;
                    DataCounter <= DataCounter - 1;
                   end if;
                when ACK_NACK_BIT_END =>
                   if Sda = '0' then
                    I2cState <= STOP_TRANSMIT;
                    Sda      <= '1';
                   else
                    I2cState <= START_TRANSMIT;
                    Sda      <= '1';
                    DataCounter <= AddressBit-1;
                   end if;
                when STOP_TRANSMIT =>
                    I2cState <= START_TRANSMIT;
                    EndI2c <= '1';
                    DataCounter <= AddressBit-1;
                when others =>
                end case;
        end if;
    end process;
end architecture;
