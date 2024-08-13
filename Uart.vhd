library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;


entity Uart is 
    generic(SystemClk : integer := 50000000;
            Baudrate : integer := 115200);

    port(ActlClk :  in std_logic := '1';
         Reset_n :  in std_logic := '0';
         Tx :       out std_logic := '1';
         Rx :       in std_logic;
         TxPacket:  in std_logic_vector(0 to 7);
         RxPacket:  out std_logic_vector(0 to 7);
         ReadWrite: in std_logic :='1';
         StartUart: in std_logic := '0';
         EndUart :  out std_logic := '0';
         ParityBit : in std_logic := '0');
end Uart;

architecture rtl of Uart is
    constant UartPeriod : integer := SystemClk / (2*Baudrate) ;
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
    signal Tx_Packet : std_logic_vector(0 to 7);
    signal Rx_Packet : std_logic_vector(0 to 7);
    signal Clk_prev : std_logic := '1';
    signal Clk : std_logic := '1';
    signal Tx_reg : std_logic := '1';
	signal Rx_reg : std_logic := '1';
    signal ParityCounter : integer := 0;
    Signal UartState : UART_STATE := IDLE_STATE;
    signal BitCounter : integer := 0;
    signal Rw : std_logic;
	 signal StartUart_prev : std_logic;
begin
    process(ActlClk, Reset_n) is
        variable Counter : integer range 0 to UartPeriod;
    begin
        if Reset_n = '0' then
            Counter := 0;
        elsif(ActlClk'event and ActlClk = '1') then
            Clk_prev <= Clk;
            if Counter = UartPeriod then
                Counter := 0;
                Clk <= not Clk;
            else
                Counter := Counter + 1;
            end if;
        end if;
    end process;

    process(ActlClk, Reset_n) is
    begin
        if Reset_n = '0' then
            UartState <= IDLE_STATE;
            EndUart <= '0';
            Rw <= ReadWrite;
            BitCounter <= 0;
            Tx_Packet <= TxPacket;
            ParityCounter <= 0;
				StartUart_prev <= StartUart;
        elsif(ActlClk'event and ActlClk = '1') then
            if (Clk = '1' and Clk_prev = '0') then
                case UartState is
                    when IDLE_STATE => 
                       if (StartUart = '0' and StartUart_prev = '1') then
						StartUart_prev <= StartUart;
                        EndUart <= '0';
                        if Rw = '1' then
                            UartState <= START_STATE_WRITE;
                        else
                            UartState <= START_STATE_READ;
                        end if;
                       else
						StartUart_prev <= StartUart;
                        EndUart <= '0';
                        end if;

                    when START_STATE_WRITE => 
                       Tx_reg <= '0'; 
                       UartState <= DATA_STATE_WRITE;

                    when DATA_STATE_WRITE =>
                        if BitCounter = 7 then
                            if ParityBit = '0' then
                                UartState <= STOP_STATE_WRITE;
                            else
                                UartState <= PARITY_STATE_WRITE;
                            end if;
                        end if;
                        Tx_reg <= Tx_Packet(7 - BitCounter);
                        if Tx_Packet(7- BitCounter) = '1' then
                            ParityCounter <= ParityCounter + 1;
                        end if;
                        BitCounter <= BitCounter + 1;

                    when PARITY_STATE_WRITE =>
                       if (ParityCounter mod 2) = 0 then
                        Tx_reg <= '1';
                       else
                        Tx_reg <= '0';
                       end if;
                       UartState <= STOP_STATE_WRITE;
                       ParityCounter <= 0;

                    when STOP_STATE_WRITE =>
                       Tx_reg <= '1';
							  BitCounter <= 0;
                       UartState <= IDLE_STATE;
                       EndUart <= '1';

                    when START_STATE_READ =>
                       if Rx_reg = '0' then
                        UartState <= DATA_STATE_READ;
                       end if;

                    when DATA_STATE_READ =>
                       if BitCounter = 7 then
                        if ParityBit = '0' then
                            UartState <= STOP_STATE_READ;
                        else
                            UartState <= PARITY_STATE_READ;
                        end if;
							  end if;
                       Rx_Packet(BitCounter) <= Rx_reg;
                       if Rx_reg = '1' then
                        ParityCounter <= ParityCounter + 1;
                       end if;
                       BitCounter <= BitCounter + 1;

                    when PARITY_STATE_READ =>
                       UartState <= STOP_STATE_READ;


                    when STOP_STATE_READ =>
                       EndUart <= '1';
							  BitCounter <= 0;
                       UartState <= IDLE_STATE;

                end case;
            end if;
        end if;
    end process;
                   
   RxPacket <= Rx_Packet;
   Tx <= Tx_reg;
	Rx_reg <= Rx;


  
end architecture;