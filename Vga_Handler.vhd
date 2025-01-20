library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.VgaTypes.all;


entity Vga_Handler is 
    port(Reset_n  : in std_logic := '0';
         InputClk : in std_logic := '0';
         HsyncClk : out std_logic := '1';
         VsyncClk : out std_logic := '1';
         R_0 : out std_logic := '0';
         R_1 : out std_logic := '0';
         R_2 : out std_logic := '0';
         G_0 : out std_logic := '0';
         G_1 : out std_logic := '0';
         G_2 : out std_logic := '0';
         B_0 : out std_logic := '0';
         B_1 : out std_logic := '0';
         B_2 : out std_logic := '0';
		VsyncComplete : out std_logic := '0'
    );
end Vga_Handler;

architecture rtl of Vga_Handler is
    constant SystemFreq : integer := 40000000;
    constant VsyncFreq : integer := 60;
    constant HsyncFreq : integer := 37680;

    signal ColorClk :  std_logic  := '0';
    signal LineColor : LineColor_t := (others => (others => '0'));
    signal x_axis   : unsigned (9 downto 0) := (others => '0');
    signal y_axis   : unsigned (9 downto 0) := (others => '0');
    signal x_axis_write   : unsigned (9 downto 0) := (others => '0');
    signal locked : std_logic := '1';
	signal HsyncComplete : std_logic := '0';
    signal Reset_Sync : std_logic := '1';
    signal Reset_Reg : std_logic := '1';
	 
begin
	VgaPll:entity work.VgaPll(SYN)
	port map
	(
		areset => Reset_n,
		inclk0 => InputClk,	
		c0     => ColorClk,
		locked =>  locked
	);

    
    Vga: entity work.Vga(rtl)
        generic map(SystemFreq => SystemFreq, 
                    VsyncFreq  => VsyncFreq, 
                    HsyncFreq  => HsyncFreq)
        port map(Reset_n   => Reset_Sync,
                 ColorClk  => ColorClk,
                 HsyncClk  => HsyncClk,
                 VsyncClk  => VsyncClk,
                 R_0       => R_0,    
                 R_1       => R_1,    
                 R_2       => R_2,    
                 G_0       => G_0,    
                 G_1       => G_1,    
                 G_2       => G_2,    
                 B_0       => B_0,    
                 B_1       => B_1,    
                 B_2       => B_2,
                 --LineCycle => LineCycle,
                 LineColor => LineColor,
                 x_axis    => x_axis,
                 y_axis    => y_axis,
				 HsyncComplete => HsyncComplete,
				 VsyncComplete => VsyncComplete);

    process(ColorClk, Reset_Sync)
    begin
        if (Reset_Sync = '1') then
            LineColor <= (others => (others => '0'));
			x_axis_write <= (others => '0');
        elsif rising_edge(ColorClk) then
			   -- 0xC7 = 199
            if ( (y_axis=x"C7") and (x_axis>x_axis_write)) then
					 -- 0xC8 = 200 0X190 = 400
                if (x_axis_write > x"C8" and x_axis_write<X"190") then
                    -- 0x1FF = 255
                    LineColor(to_integer(x_axis_write)) <= X"1FF";
                    x_axis_write <= x_axis_write + 1;
					 -- 0x320 = 800
                elsif (x_axis= x"320") then
                    x_axis_write <= (others => '0');
                end if;
			   -- 500 = 0x1F4
            elsif ( (y_axis=X"1F4") and (x_axis>x_axis_write) ) then
					 -- 0xC8 = 200
                if (x_axis_write > x"C8" and x_axis_write<x"190") then
                    -- 0x000 = 0
                    LineColor(to_integer(x_axis_write)) <= X"000";
                    x_axis_write <= x_axis_write + 1;
					 -- 0x320 = 800
                elsif (x_axis= x"320") then
                    x_axis_write <= (others => '0');
                end if;
            end if;
        end if;
    end process;


    process (ColorClk, Reset_n) is
    begin
        if (Reset_n = '1') then
            Reset_Sync <= '1';
        elsif rising_edge(ColorClk) then
            Reset_Sync <= '0';
        end if;
    end process;

end architecture;