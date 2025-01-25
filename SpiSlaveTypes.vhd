library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

package SpiSlaveTypes is
    subtype SpiWord is std_logic_vector(0 to 15);
	 
	 type Spi_State is
    (IDLE_STATE,
	 READ_BIT,
     DECEIDE_STATE,
     WRITE_BIT,
     END_STATE);

     type Spi_Handler_State is
    (IDLE_STATE,
     ACTIVATE_SPI,
     RUN_STATE,
     READING_STATE,
     END_STATE
    );
end SpiSlaveTypes;