library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library Packages;
use Packages.Processor.all;

entity mM_toplevel is
	port(
		CLOCK_50 : in std_logic;
		KEY : in std_logic_vector(3 downto 0);
		SW : std_logic_vector(9 downto 0);
		VGA_HS : out std_logic;
		VGA_VS : out std_logic;
		VGA_R : out std_logic_vector(3 downto 0);
		VGA_G : out std_logic_vector(3 downto 0);
		VGA_B : out std_logic_vector(3 downto 0);
		LEDR : out std_logic_vector(9 downto 0);
		LEDG : out std_logic_vector(7 downto 0)
	);
end mM_toplevel;

architecture a_mM_toplevel of mM_toplevel is
		signal clk, reset, mclk, pcld, pcinc, irwr, statwr, dmwr, dmrd, dm2dbus,
			alu2dbus, reg2io, io2reg, regwr, vgablank, vgapixel, vgaHS, vgaVS: std_logic;
			
		signal pc, ir, dbus, rs1, rs2 : std_logic_vector(31 downto 0);
		signal stat : std_logic_vector(3 downto 0);
		
begin
	reset <= not KEY(3);
	mclk <= not KEY(0);
	
	CLOCKDIVISOR: freqdiv
		generic map(1)
		port map(CLOCK_50, reset, clk);

	m1ps_Monitor: mM
		generic map("dmemory.mif")
		port map(clk, reset, pc, ir, dbus, rs1, rs2, stat, pcld, pcinc, irwr, regwr, statwr, dmwr, dmrd, dm2dbus,
			alu2dbus, reg2io, io2reg, ir(27 downto 26), SW(0), vgaHS, vgaVS, vgablank, vgapixel);
			
	m1ps: processor
		port map  (
			clock => mclk,
			reset => reset,
			--IO_IN => (others => '0'),
			DBus => dbus,
			RSource1 => rs1,			
			RSource2 => rs2, 			
			-- IO_OUT => ,				
			IM_address => pc,			
			-- IM_instruction_out => ,	
			instruction => ir,			
			stat_CVNZ => stat,	
			Pc_Ld	=> pcld,	
			--IR_Ld	=> irwr,		
			--Pc_Inc	=> pcinc,			
			--ALU_2_DBus	=> alu2dbus,		
			--DM_Rd => dmrd,				
			DM_Wr => dmwr,				
			-- PC_Ld_En ,		
		    --Reg_2_IO => reg2io,			
			--IO_2_Reg => io2reg,	
			Reg_Wr	=> regwr
			--Stat_Wr	=> statwr			
			--DM_2_DBus => dm2dbus		
		);
		
	VGA_R <= "0000";
	VGA_B <= "0000";
	VGA_G(1 downto 0) <= "00";
	process(clk, reset)
	begin
		if reset = '1' then
			VGA_G(3 downto 2) <= "00";
		elsif clk'event and clk = '1' then
			VGA_HS <= vgaHS;
			VGA_VS <= vgaVS;
			VGA_G(3 downto 2) <= "00";
			if vgablank = '0' then
				VGA_G(3 downto 2) <= (others => vgapixel);	
			end if;
		end if;
	end process;
		
end a_mM_toplevel;
