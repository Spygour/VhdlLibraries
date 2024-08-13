library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity I2c is
    generic(SystemFreq  : integer := 50000000;
            Frequency   : integer := 1000000;
            DataBit     : integer := 8;
				BytesNumber : integer := 1);

    port(ActlClk     : in std_logic := '1'; 
         Reset_n     : in std_logic := '0'; 
         I2cAddress  : in std_logic_vector(0 to 6);
         Sda         : inout std_logic;
         Scl         : inout std_logic;
         ReadWrite   : in std_logic;
         StartI2c    : in std_logic;
         EndI2c      : out std_logic;
         I2cRead     : inout std_logic_vector(0 to 7);
         I2cWrite    : in std_logic_vector(0 to 7));
end I2c;

architecture rtl of I2c is
    constant DivideVal : integer := SystemFreq/ (4*Frequency);
	 signal Scl_ena : std_logic;
	 signal Scl_reg : std_logic := '0';
    Signal Scl_regPrev : std_logic := '0';
    signal Sda_reg : std_logic := '1';
	 signal Sda_output : std_logic := '0';
    signal SdaClk_reg : std_logic := '0';
    signal SdaClk_regPrev : std_logic := '0';
    signal Extend : std_logic := '0';
    signal I2cAdrRw : std_logic_vector(0 to 7);
    signal I2cWr : std_logic_vector(0 to 7);
    type I2C_STATE is
       (IDLE_STATE,
        START_TRANSMIT,
        ADDRESS_FRAME,
        ACK_NACK_BIT_ADDRESS,
        DATA_FRAME_READ,
        DATA_FRAME_WRITE,
        ACK_NACK_BIT_END,
		  STOP_TRANSMIT);
    signal I2cState : I2C_STATE := IDLE_STATE;
    signal DataCounter : integer range 0 to 10 := 0;
	 signal StartI2c_prev : std_logic := '1';
    
begin
	process (ActlClk, Reset_n)
        variable Counter : integer range 0 to 4*DivideVal;
	begin
    if Reset_n = '0' then
      Counter := 0;
      Scl_reg <= '0';
      Scl_regPrev <= '0';
      SdaClk_reg <= '0';
      SdaClk_regPrev <= '0';
    elsif (ActlClk'event and ActlClk = '1') then
        Scl_regPrev <= Scl_reg;
        SdaClk_regPrev <= SdaClk_reg;
        if Counter = DivideVal then
          SdaClk_reg <= '1';
        elsif Counter = 2*DivideVal then
          Scl_reg <= '1';
        elsif Counter = 3*DivideVal then
          SdaClk_reg <= '0';
        elsif Counter = 4*DivideVal-1 then
          Scl_reg <= '0';
          Counter := 0;
        end if;
        if Counter > 2*DivideVal and Scl = '0' then
          Extend <= '1';
        else
          Extend <= '0';
        end if;
        if Extend = '0' then
          Counter := Counter + 1;
        end if;
    end if;
	 end process;

     
     
   process(ActlClk, Reset_n)
	variable BytesCounter : integer range 0 to BytesNumber;
   begin
    if Reset_n = '0' then
      Sda_reg <= '1';
      I2cState <= IDLE_STATE;
      EndI2c <= '0';
      DataCounter <= 0;
      BytesCounter := 0;
		StartI2c_prev <= StartI2c;
    elsif (ActlClk'event and ActlClk = '1') then
      if (SdaClk_reg = '0' and SdaClk_regPrev = '1') then
        case I2cState is
          when IDLE_STATE =>
            if (StartI2c = '0' and StartI2c_prev = '1') then
				      StartI2c_prev <= StartI2c;
              BytesCounter := 0;
              I2cAdrRw <= I2cAddress & ReadWrite;
              I2cWr <= I2cWrite;
              I2cState <= START_TRANSMIT;
            else
				      StartI2c_prev <= StartI2c;
              EndI2c <= '0';
            end if;

         when START_TRANSMIT =>
			   DataCounter <= 0;
            Sda_reg <= '0';  -- Drive SDA low for start condition
            I2cState <= ADDRESS_FRAME;

          when ACK_NACK_BIT_ADDRESS =>
            if Sda = '0' then
                if ReadWrite = '0' then
                    DataCounter <= 0;
                    I2cState <= DATA_FRAME_WRITE;
                else
                    DataCounter <= 0;
                    I2cState <= DATA_FRAME_READ;
                end if;
            else 
                I2cState <= START_TRANSMIT;
            end if;

          when DATA_FRAME_READ =>
            if DataCounter = 8 then
                I2cState <= ACK_NACK_BIT_END;
                BytesCounter := BytesCounter + 1;
            else
                I2cRead(DataCounter) <= Sda;  -- Read data bits
                DataCounter <= DataCounter + 1;
					      I2cState <= DATA_FRAME_READ;
            end if;

          when ACK_NACK_BIT_END =>
            if Sda = '0' then
                if (BytesCounter = BytesNumber or ReadWrite = '0')  then
                  I2cState <= STOP_TRANSMIT;
                else 
                  DataCounter <= 0;
                  I2cState <= DATA_FRAME_READ;
                end if;
            else
                I2cState <= START_TRANSMIT;
            end if;
            
          when STOP_TRANSMIT =>
			   Sda_reg <= '1';
            I2cState <= IDLE_STATE;
            EndI2c <= '1';
          when others => null;
          end case;

     elsif (SdaClk_reg = '1' and SdaClk_regPrev = '0') then
        case I2cState is
          when ADDRESS_FRAME =>
            if DataCounter = 8 then
              I2cState <= ACK_NACK_BIT_ADDRESS;
            else
              Sda_reg <= I2cAdrRw(DataCounter);
              DataCounter <= DataCounter + 1;
            end if;

          when DATA_FRAME_WRITE =>
             if DataCounter = DataBit then
				  	   I2cState <= ACK_NACK_BIT_END;
             else
                 Sda_reg <= I2cWr(DataCounter);  -- Write data bits
                 DataCounter <= DataCounter + 1;
             end if;

          when others =>  null;
        end case;
      end if;
end if;
  end process;
with I2cState SELECT 
  Scl_ena <= '0' when IDLE_STATE,
             '0' when STOP_TRANSMIT,
             '1'  when others;
				 
with I2cState SELECT
  Sda_output <= '0' when DATA_FRAME_READ,
                '0' when ACK_NACK_BIT_ADDRESS,
                '0' when ACK_NACK_BIT_END,
					      '1' when others;

  Scl <= Scl_reg when Scl_ena = '1'  else 'Z';
  Sda <= Sda_reg when Sda_output = '1' else 'Z';
END architecture;
