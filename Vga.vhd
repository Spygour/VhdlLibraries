library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.VgaTypes.all;


entity Vga is 
    generic(SystemFreq : integer := 40000000;
            VsyncFreq : integer := 60;
            HsyncFreq : integer := 37680);

    port(Reset_n : in std_logic := '1';
         ColorClk : in std_logic  := '0';
         HsyncClk : out std_logic := '1';
         VsyncClk : out std_logic := '1';
         R    : out std_logic_vector (7 downto 0) := (others => '0');
         G    : out std_logic_vector (7 downto 0) := (others => '0');
         B    : out std_logic_vector (7 downto 0) := (others => '0');
         LineBuffer : in LineBuffer_t := (others => (others => (others => '0')));
         x_axis   : inout unsigned (9 downto 0) := (others => '0');
         y_axis   : inout unsigned (9 downto 0) := (others => '0');
	 HsyncComplete : inout std_logic := '0';
         VsyncComplete  : out std_logic := '0';
	 LineBufferIndex : in integer  := 0);

end Vga;

architecture rtl of Vga is
    constant VsyncDuty : integer := 4;
    constant VsyncBackPort : integer := 27;
    constant VsyncActive : integer := 627;
    constant VsyncPeriod : integer := 628;

    constant HsyncDuty : integer := 128;
    constant HsyncBackPorch: integer := 168;
    constant HsyncPixel : integer := 974;
    constant HsyncPeriod : integer := 1062;

    signal HsyncCounter : integer := 0;
    signal VsyncCounter : integer := 0;
    signal HsyncClk_reg : std_logic := '1';
    signal VsyncClk_reg : std_logic := '1';


    type Sync_State is 
        (
            IDLE_STATE,
            PULSE_STATE,
            BACK_PORCH_STATE,
            ACTIVE_STATE,
            EXTEND_STATE,
            FRONT_PORCH,
	    PREPARE_PULSE
        );

    signal HsyncState : Sync_State := IDLE_STATE;
    signal VsyncState : Sync_State := IDLE_STATE;

begin
    --Update the actual signals
    HsyncClk <= HsyncClk_reg;
    VsyncClk <= VsyncClk_reg;
    --Hsync pulse process
    process(ColorClk, Reset_n) is
    begin
        if (Reset_n = '1') then
            HsyncClk_reg <= '1';
            HsyncState <= IDLE_STATE;
        elsif rising_edge(ColorClk) then --Here we should increase the counter
            case HsyncState is
                when IDLE_STATE =>
                    HsyncState <= PULSE_STATE;
                    HsyncCounter <= 0;
                    HsyncClk_reg <= not HsyncClk_reg;
                    x_axis <= (others => '0');
                    HsyncComplete <= '0';
                    VsyncCounter <= 0;

                when PULSE_STATE =>
                    if (HsyncCounter = HsyncDuty) then
                        HsyncState <= BACK_PORCH_STATE;
                        HsyncClk_reg <= not HsyncClk_reg;
                        x_axis <= (others => '0');
                    else
                        HsyncComplete <= '0';
                    end if;
                    HsyncCounter <= HsyncCounter+1;

                when BACK_PORCH_STATE =>
                    if (HsyncCounter = HsyncBackPorch) then
                        HsyncState <= ACTIVE_STATE;
                    end if;
                    HsyncCounter <= HsyncCounter+1;


                when ACTIVE_STATE =>
                    if (HsyncCounter = HsyncPixel ) then
                        HsyncState <= FRONT_PORCH;
                    else
                        -- 0x320 = 800
                        if ((x_axis < X"320") and (VsyncState <= ACTIVE_STATE)) then
                            x_axis <= x_axis + 1;
                        end if;
                    end if;
                    HsyncCounter <= HsyncCounter+1;

                when FRONT_PORCH =>
		    -- Prepare to start the new pulse (We need to check the HsyncComplete inside the VsyncProcess thats why we need an extra state)
                    if (HsyncCounter = (HsyncPeriod - 1) ) then
                        VsyncCounter <= VsyncCounter + 1;
                        HsyncComplete <= '1';
                        HsyncCounter <= 0;
                        HsyncState <= PREPARE_PULSE;
                    else
                        HsyncCounter <= HsyncCounter+1;
                    end if;

		when PREPARE_PULSE =>
		  HsyncClk_reg <= not HsyncClk_reg;
		  HsyncState <= PULSE_STATE;
		  -- Here we reset the VsyncCounter at the exact time of the pulse that will be generated by Vsync and Hsync
		  if (VsyncCounter = VsyncPeriod) then
		       VsyncCounter <= 0;
		 end if;
						
                when others => null;
            end case;
        end if;
    end process;

    --Vsync pulse process
    process(ColorClk, Reset_n) is
    begin
        if (Reset_n = '1') then
            VsyncClk_reg <= '1';
            VsyncState <= IDLE_STATE;
	    VsyncComplete <= '0';
        elsif rising_edge(ColorClk) then --Here we should increase the counter
            case VsyncState is
                when IDLE_STATE =>
                    VsyncState <= PULSE_STATE;
                    VsyncClk_reg <= not VsyncClk_reg;
                    y_axis <=  (others => '0');
                    VsyncComplete <= '0';
                when PULSE_STATE =>
                    if (VsyncCounter = VsyncDuty) then
                        VsyncState <= BACK_PORCH_STATE;
                        VsyncClk_reg <= not VsyncClk_reg;
			VsyncComplete <= '0';
                    end if;

                when BACK_PORCH_STATE =>
                    if (VsyncCounter = VsyncBackPort) then
                        VsyncState <= ACTIVE_STATE;
                    end if;
                
                when ACTIVE_STATE =>
                    if (VsyncCounter = VsyncActive) then
			VsyncComplete <= '1';
                        VsyncState <= FRONT_PORCH;
                    elsif HsyncComplete = '1' then
                        y_axis <= y_axis + 1;
                    end if;
                
                when FRONT_PORCH =>
                    if ((VsyncCounter = VsyncPeriod) and (HsyncState = PREPARE_PULSE))  then
                        y_axis <=  (others => '0');
                        VsyncState <= PULSE_STATE;
                        VsyncClk_reg <= not VsyncClk_reg;
                    end if;

                when others => null;
            end case;
        end if;
    end process;
	
    --color pulse process much more complicated
    process(ColorClk, Reset_n) is
    begin
        if (Reset_n = '1') then
            R <= (others => '0');
	    G <= (others => '0');
	    B <= (others => '0');
        elsif rising_edge(ColorClk) then --Here we should increase the counter
            if (HsyncState = ACTIVE_STATE and VsyncState = ACTIVE_STATE) then
                R <= LineBuffer(LineBufferIndex) (to_integer(x_axis)) (23 downto 16);
                G <= LineBuffer(LineBufferIndex) (to_integer(x_axis)) (15 downto 8);
                B <= LineBuffer(LineBufferIndex) (to_integer(x_axis)) (7 downto 0);
            else
                R <= (others => '0');
		G <= (others => '0');
		B <= (others => '0');
            end if;
        end if;
    end process;


end architecture;
