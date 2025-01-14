library work;
use work.VgaTypes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;


entity Vga is 
    generic(SystemFreq : integer := 40000000;
            VsyncFreq : integer := 60;
            HsyncFreq : integer := 37680);

    port(Reset_n : in std_logic := '0';
         ColorClk : in std_logic  := '0';
         HsyncClk : out std_logic := '0';
         VsyncClk : out std_logic := '0';
         R_0      : out std_logic := '0';
         R_1      : out std_logic := '0';
         R_2      : out std_logic := '0';
         G_0      : out std_logic := '0';
         G_1      : out std_logic := '0';
         G_2      : out std_logic := '0';
         B_0      : out std_logic := '0';
         B_1      : out std_logic := '0';
         B_2      : out std_logic := '0');

end Vga;

architecture rtl of Vga is
    constant VsyncPeriod : integer := 666666;
    constant HsyncPeriod : integer := 1062;
    constant VsyncDuty : integer := 4267;
    constant HsyncDuty : integer := 127;

    signal HsyncCounter : integer := 0;
    signal VsyncCounter : integer := 0;
    signal x_axis : unsigned(8 downto 0) := (others => '0'); /* 800 pixels */
    signal y_axis : unsigned(8 downto 0) := (others => '0'); /* 600 pixels */
    signal ColorClk_reg : std_logic := '0';
    signal HsyncClk_reg : std_logic := '0';
    signal VsyncClk_reg : std_logic := '0';

    type Sync_State is 
        (
            IDLE_STATE,
            PULSE_STATE,
            WAIT_STATE,
            EXTEND_STATE
        )

    signal HsyncState : Sync_State := IDLE_STATE;
    signal VsyncState : Sync_State := IDLE_STATE;

begin
    /* Hsync pulse process */
    process(ColorClk, Reset_n) is
    begin
        if (Reset_n = '0') then
            HsyncCounter <= 0;
            HsyncClk_reg <= '0';
        elsif rising_edge(ColorClk) then /* Here we should increase the counter */
            case HsyncState is
                when IDLE_STATE =>
                    HsyncState <= PULSE_STATE;
                    HsyncClk_reg <= '1';

                when PULSE_STATE =>
                    if (x_axis = 800) or (HsyncCounter = HsyncDuty) then
                        HsyncState <= WAIT_STATE;
                        HsyncClk_reg <= '0';
                    else
                        x_axis <= x_axis+1;
                        HsyncCounter <= HsyncCounter+1;
                    end if;

                when WAIT_STATE =>
                    if (HsyncCounter = HsyncPeriod ) then
                        if (VsyncCounter >= VsyncPeriod)  then
                            y_axis <= (others => '0');
                        else
                            if (y_axis <600) then
                                y_axis <= y_axis+1;
                            else
                                y_axis <= (others => '0');
                            end if;
                        end if;
                        HsyncCounter <= 0;
                        x_axis <= (others => '0');
                        HsyncState <= PULSE_STATE;
                        HsyncClk_reg <= '1';
                    else
                        HsyncCounter <= HsyncCounter+1;
                    end if;
                when others => null;
            end case;
        end if;
    end process;

    /* Vsync pulse process */
    process(ColorClk, Reset_n) is
    begin
        if (Reset_n = '0') then
            VyncCounter <= 0;
            VsyncClk_reg <= '0';
        elsif (ColorClk'event and ColorClk = '1') then /* Here we should increase the counter */
            case VsyncState is
                when IDLE_STATE =>
                    VsyncState <= PULSE_STATE;
                    VsyncClk_reg <= '1';

                when PULSE_STATE =>
                    if (VsyncCounter = VsyncDuty) then
                        VsyncState <= WAIT_STATE;
                        VsyncClk_reg <= '0';
                    else
                        VsyncCounter <= VsyncCounter+1;
                    end if;

                when WAIT_STATE =>
                    if (VsyncCounter = VsyncPeriod) then
                        if (HsyncCounter < HsyncPeriod) then
                            VsyncState <= EXTEND_STATE;
                        else
                            VsyncCounter <= 0;
                            VsyncState <= PULSE_STATE;
                            VsyncClk_reg <= '1';
                        end if;
                    else
                        VsyncCounter <= VsyncCounter+1;
                    end if;
                    
                when EXTEND_STATE =>
                    if (HsyncCounter = HsyncPeriod) then
                        VsyncCounter <= 0;
                        VsyncState <= PULSE_STATE;
                        VsyncClk_reg <= '1'
                    end if;

                when others => null;
            end case;
        end if;
    end process;
	
    /* color pulse process much more complicated */
    process(ColorClk, Reset_n) is
    begin
        if (Reset_n = '0') then
            R_0 <= '0';
            R_1 <= '0';
            R_2 <= '0';
            G_0 <= '0';
            G_1 <= '0';
            G_2 <= '0';
            B_0 <= '0';
            B_1 <= '0';
            B_2 <= '0';
        elsif (ColorClk'event and ColorClk = '1') then /* Here we should increase the counter */

        end if;
    end process;
    /* Update the actual signals */
    HsyncClk <= HsyncClk_reg;
    VsyncClk <= VsyncClk_reg;
end architecture;