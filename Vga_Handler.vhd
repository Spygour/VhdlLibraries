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
         R : out std_logic_vector (7 downto 0) := (others => '0');
	 G : out std_logic_vector (7 downto 0) := (others => '0');
	 B : out std_logic_vector (7 downto 0) := (others => '0');
         
	VsyncComplete : out std_logic := '0'
    );
end Vga_Handler;

architecture rtl of Vga_Handler is
    constant SystemFreq : integer := 40000000;
    constant VsyncFreq : integer := 60;
    constant HsyncFreq : integer := 37680;

    signal ColorClk :  std_logic  := '0';
    signal LineBuffer : LineBuffer_t := (others => (others => (others => '0')));
    signal x_axis   : unsigned (9 downto 0) := (others => '0');
    signal y_axis   : unsigned (9 downto 0) := (others => '0');
    signal locked : std_logic := '1';
    signal HsyncComplete : std_logic := '0';
    signal Reset_Sync : std_logic := '1';
    signal Reset_Reg : std_logic := '1';
    signal BufferIndex : integer := 0;
	 signal BufferIndex_tmp: integer := 1; --temp value of BufferIndex
	 
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
                 R         => R,    
                 G         => G,
                 B         => B,  
                 --LineCycle => LineCycle,
                 LineBuffer => LineBuffer,
                 x_axis    => x_axis,
                 y_axis    => y_axis,
		         HsyncComplete => HsyncComplete,
		         VsyncComplete => VsyncComplete,
		         LineBufferIndex => BufferIndex);

    process(ColorClk, Reset_Sync)
    begin
        if (Reset_Sync = '1') then
                LineBuffer <= (others => (others => (others => '0')));
				BufferIndex_tmp <= 1;
				BufferIndex <= 0;
        elsif rising_edge(ColorClk) then
	    -- 0xC7 = 199
            if (y_axis=x"C7") and (HsyncComplete = '0') then
                -- 0x1FF = 255
					 if (x_axis > x"C8" and x_axis < x"190") then
						LineBuffer(BufferIndex_tmp) (to_integer(x_axis)) <= X"FF0000";
					end if;
	        elsif (y_axis=x"C7") and (HsyncComplete = '1') then
		        BufferIndex_tmp <= 0;
		        BufferIndex <= 1;
            elsif ( y_axis=x"C8" and HsyncComplete = '0') then
		        LineBuffer(BufferIndex_tmp) (to_integer(x_axis)) <= X"00FFFF";
	        elsif ( y_axis=x"C8" and HsyncComplete = '1') then
                BufferIndex <= 0;
				BufferIndex_tmp <= 1;
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
