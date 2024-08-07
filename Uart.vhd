library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;


entity Uart is 
    generic(Baudrate : integer := 115200);

    port(Tx :       out std_logic := '1';
         Rx :       inout std_logic := '1';
         TxPacket:  in std_logic_vector(7 downto 0);
         RxPacket:  out std_logic_vector(7 downto 0);
         UartSize:  in integer := 5;
         ReadWrite: in std_logic :='1';
         StartUart: in std_logic := '0';
         EndUart :  out std_logic := '0';
         ParityBit : in std_logic := '0');
end Uart;

architecture rtl of Uart is
    constant UartPeriod : time := 1000 ms / Baudrate ;
    type UART_STATE is
        (IDLE_STATE,
         START_STATE_WRITE,
         START_STATE_READ,
         DATA_STATE_WRITE,
         DATA_STATE_READ,
         PARITY_STATE_WRITE,
         PARITY_STATE_READ,
         STOP_STATE_WRITE,
         STOP_STATE_READ);

    signal Clk : std_logic := '1';
    signal ParityCounter : integer := 0;
    Signal UartState : UART_STATE := IDLE_STATE;
    signal BitCounter : integer := 7;
begin
    Clock : entity work.ClockFreq(clk)
    generic map(Freq => Baudrate)
    port map(componentClck => Clk);

    process(Clk) is
    begin
        if(rising_edge(Clk)) then
            case UartState is
                when IDLE_STATE => 
                   if StartUart = '1' then
                    EndUart <= '0';
                    if ReadWrite = '1' then
                        BitCounter <= 7;
                        UartState <= START_STATE_WRITE;
                    else
                        BitCounter <= 0;
                        UartState <= START_STATE_READ;
                    end if;
                    end if;
                when START_STATE_WRITE => 
                   Tx <= '0'; 
                   UartState <= DATA_STATE_WRITE;
                when DATA_STATE_WRITE =>
                    Tx <= TxPacket(BitCounter);
                    if TxPacket(BitCounter) = '1' then
                        ParityCounter <= ParityCounter + 1;
                    end if;
                    if BitCounter = 0 then
                        if ParityBit = '0' then
                            UartState <= STOP_STATE_WRITE;
                        else
                            UartState <= PARITY_STATE_WRITE;
                        end if;
                    else
                        BitCounter <= BitCounter - 1;
                    end if;
                when PARITY_STATE_WRITE =>
                   if (ParityCounter mod 2) = 0 then
                    Tx <= '1';
                   else
                    Tx <= '0';
                   end if;
                   UartState <= STOP_STATE_WRITE;
                   ParityCounter <= 0;
                when STOP_STATE_WRITE =>
                   Tx <= '1';
                   UartState <= IDLE_STATE;
                   EndUart <= '1';
                when START_STATE_READ =>
                   if Rx = '0' then
                    UartState <= DATA_STATE_READ;
                   end if;
                when DATA_STATE_READ =>
                   RxPacket(BitCounter) <= Rx;
                   if Rx = '1' then
                    ParityCounter <= ParityCounter + 1;
                   end if;
                   if BitCounter = 7 then
                    if ParityBit = '0' then
                        UartState <= STOP_STATE_READ;
                    else
                        UartState <= PARITY_STATE_READ;
                    end if;
                   else
                    BitCounter <= BitCounter + 1;
                   end if;
                when PARITY_STATE_READ =>
                   UartState <= STOP_STATE_READ;
                when STOP_STATE_READ =>
                   EndUart <= '1';
                   UartState <= IDLE_STATE;
            end case;
        end if;
    end process;
                   



  
end architecture;