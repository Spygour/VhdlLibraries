library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;


entity Uart is 
    generic(SystemClk : integer := 50000000;
            Baudrate : integer := 115200);

    port(ActlClk :  in std_logic := '1';
			Clk     :  inout std_logic := '0';
         Reset_n :  in std_logic := '0';
         Tx :       out std_logic := '1';
         Rx :       in std_logic := '1';
         TxPacket:  in std_logic_vector(0 to 7);
         RxPacket:  out std_logic_vector(0 to 7);
         ReadWrite: in std_logic;
         StartUart: in std_logic := '0';
         EndUart :  out std_logic := '1';
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
    signal Tx_reg : std_logic := '1';
    signal ParityCounter : integer := 0;
    Signal UartState : UART_STATE := IDLE_STATE;
    signal BitCounter : integer := 0;
    signal Rw : std_logic;
	 signal ClkStretch : std_logic := '0';
begin
    process(ActlClk,Reset_n) is
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
					if (ClkStretch = '1') then
						Counter := 0;
						Clk <= '0';
					else
                Counter := Counter + 1;
					end if;
            end if;
        end if;
    end process;

    process(ActlClk,Reset_n) is
    begin
        if Reset_n = '0' then
            UartState <= IDLE_STATE;
            EndUart <= '1';
            Rw <= ReadWrite;
            BitCounter <= 0;
            ParityCounter <= 0;
        elsif(ActlClk'event and ActlClk = '1') then
				case UartState is
					when IDLE_STATE =>
					     if (StartUart = '1') then
						   Tx_Packet <= TxPacket;
                       if Rw = '1' then
								 ClkStretch <= '0';
								 EndUart <= '0';
                           UartState <= START_STATE_WRITE;
                       else
								 EndUart <= '0';
                         UartState <= START_STATE_READ;
								 ClkStretch <= '1';
							end if;
						else
							ClkStretch <= '1';
						end if;
					when START_STATE_READ =>
                    if Rx = '0' then
							ClkStretch <= '0';
                       UartState <= DATA_STATE_READ; 
							end if;
						when others => null;
				end case;
            if (Clk = '1' and Clk_prev = '0') then
                case UartState is
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
							  Rw <= ReadWrite;
                       EndUart <= '1';

                    when DATA_STATE_READ =>
                       if BitCounter = 7 then
                        if ParityBit = '0' then
                            UartState <= STOP_STATE_READ;
                        else
                            UartState <= PARITY_STATE_READ;
                        end if;
							  end if;
                       Rx_Packet(7-BitCounter) <= Rx;
                       if Rx = '1' then
                        ParityCounter <= ParityCounter + 1;
                       end if;
                       BitCounter <= BitCounter + 1;

                    when PARITY_STATE_READ =>
                       UartState <= STOP_STATE_READ;


                    when STOP_STATE_READ =>
							  BitCounter <= 0;
                       UartState <= IDLE_STATE;
							  Rw <= ReadWrite;
					   EndUart <= '1';
						
						when others => null;

                end case;
				end if;
        end if;
    end process;
                   
   RxPacket <= Rx_Packet;
   Tx <= Tx_reg;


  
end architecture;