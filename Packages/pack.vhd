LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE Processor IS
	TYPE states_UC IS (FETCH, DECODE, EX);

	COMPONENT memory IS
		GENERIC (
			WORDSIZE		: NATURAL	:= 8;
			BITS_OF_ADDR	: NATURAL	:= 16;
			MIF_FILE		: STRING	:= ""
		);
		PORT (
			clock   : IN	STD_LOGIC;
			we      : IN	STD_LOGIC;
			re		: IN	STD_LOGIC;
			address : IN	STD_LOGIC_VECTOR(BITS_OF_ADDR-1 DOWNTO 0);
			datain  : IN	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
			dataout : OUT	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg IS
		GENERIC (
			WORDSIZE	: NATURAL := 32
		);
		PORT (
			clock,
			load,
			clear	: IN	STD_LOGIC;
			datain	: IN	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
			dataout : OUT	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT bank IS
		GENERIC (
			WORDSIZE : NATURAL := 32
		);
		PORT (
			WR_EN, RD_EN,
			clear,
			clock		: IN 	STD_LOGIC;
			WR_ADDR,
			RD_ADDR1,
			RD_ADDR2	: IN	STD_LOGIC_VECTOR (4 DOWNTO 0);
			DATA_IN		: IN	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
			DATA_OUT1,
			DATA_OUT2	: OUT	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT ALU IS
		GENERIC (
			WORDSIZE	: NATURAL := 4
		);
		PORT (
			A, B		: IN		STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
			Op			: IN		STD_LOGIC_VECTOR (1 DOWNTO 0);
			F			: BUFFER	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
			Z, C, V, N	: OUT		STD_LOGIC
		);
	END COMPONENT;

	COMPONENT PC IS
		GENERIC (
			increment	: NATURAL := 4;
			WORDSIZE	: NATURAL := 32
		);
		PORT (
			clock,
			clear,
			En,
			PC_Ld,
			PC_Inc		: IN		STD_LOGIC;
			DATA_IN		: IN		STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0);
			DATA_OUT	: BUFFER	STD_LOGIC_VECTOR (WORDSIZE-1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT UC IS
		PORT (
			clear,
			clock			: IN	STD_LOGIC;
			instruction		: IN	STD_LOGIC_VECTOR (5 DOWNTO 0);
			Stat			: IN	STD_LOGIC_VECTOR (3 DOWNTO 0); --C, V, N, Z
			Jump_En, DM_Wr, DM_Rd, PC_Ld_En, Reg_Wr, IF_Flush, Immediate, 
			MemToReg		: OUT	STD_LOGIC		
		);
	END COMPONENT;
	
	COMPONENT processor
		PORT (
			clock				:	 IN STD_LOGIC;
			reset				:	 IN STD_LOGIC;
			--IO_IN				:	 IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			DBus				:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			RSource1			:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			RSource2			:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			--IO_OUT				:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			IM_address			:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			--IM_instruction_out	:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			instruction			:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			stat_CVNZ			:	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			Pc_Ld				:	 OUT STD_LOGIC;
			--IR_Ld				:	 OUT STD_LOGIC;
			--Pc_Inc				:	 OUT STD_LOGIC;
			--ALU_2_DBus			:	 OUT STD_LOGIC;
			--DM_Rd				:	 OUT STD_LOGIC;
			DM_Wr				:	 OUT STD_LOGIC;
			--PC_Ld_En			:	 OUT STD_LOGIC;
			--Reg_2_IO			:	 OUT STD_LOGIC;
			--IO_2_Reg			:	 OUT STD_LOGIC;
			Reg_Wr				:	 OUT STD_LOGIC
			--Stat_Wr				:	 OUT STD_LOGIC
			--DM_2_DBus			:	 OUT STD_LOGIC
		);
	END COMPONENT;
	
	-- COMPONENTES ADICIONAIS PARA O nM
	component ram is
		generic(
			depth : natural := 12;
			width: natural := 32;
			init_file : string := ""
		);
		port(
			clk : in std_logic;
			memwrite:  in std_logic;
			ra, wa : in std_logic_vector(depth-1 downto 0);
			writedata : in std_logic_vector(width-1 downto 0);
			memdata : out std_logic_vector(width-1 downto 0)
		);
	end component;
	
	component rom is
		generic (
			depth : natural   := 32;
			width : natural   := 32; 
			init_file : string := ""
		);
		port(
		  clk : in std_logic;
		  adr: in std_logic_vector(depth-1 downto 0);
		  memdata: out std_logic_vector(width-1 downto 0)
	    );
	end component;
	
	component vga_text_mode is
		generic (
			init_file1 : string := "";
			init_file2 : string := ""
		);	
		port(
			clk : in std_logic;
			reset : in std_logic;
			write: in std_logic_vector(1 downto 0);
			showmem : in std_logic;
			wa : in std_logic_vector(11 downto 0);
			wd : in std_logic_vector(7 downto 0);
			HS : out std_logic;
			VS : out std_logic;
			blank : out std_logic;
			column : out std_logic_vector(6 downto 0);
			row : out std_logic_vector(5 downto 0);
			pixel : out std_logic
		);
	end component;
	
	component vga_timing is
		port(
			clk : in std_logic;
			reset : in std_logic;
			HS : out std_logic;
			VS : out std_logic;
			pixel_x : out std_logic_vector(9 downto 0);
			pixel_y : out std_logic_vector(9 downto 0);
			last_column : out std_logic;
			last_row : out std_logic;
			blank : out std_logic
		);
	end component;
	
	component flopar is
		generic(
			width: natural := 32
		);
		port(
			clk, reset: in std_logic;
			d: in  std_logic_vector(width-1 downto 0);
			q: out std_logic_vector(width-1 downto 0)
		);
	end component;
	
	component bin2hexascii is
		port(
			bin   : in std_logic_vector(3 downto 0);
			ascii : out std_logic_vector(7 downto 0)
		);
	end component;
	
	component m1ps2vga is
		port(
			clk : in std_logic;
			reset : in std_logic;
			start : in std_logic;
			pc, ir, dbus, rs1, rs2 : in std_logic_vector(31 downto 0); 
			stat : in std_logic_vector(3 downto 0);
			pcld, pcinc, irwr, regwr, statwr, dmwr, dmrd, dm2dbus,
				alu2dbus, reg2io, io2reg : in std_logic;
			aluop : in std_logic_vector(1 downto 0);
			memdata : in std_logic_vector(31 downto 0);
			regdata : in std_logic_vector(31 downto 0);
			
			vgawrite : out std_logic_vector(1 downto 0);
			vgawa : out std_logic_vector(11 downto 0);
			vgawd : out std_logic_vector(7 downto 0);
			memraddr : out std_logic_vector(7 downto 0);
			regaddr : out std_logic_vector(4 downto 0)
		);
	end component;
	
	component freqdiv is
		generic (DIV : natural := 2);
		port (
			clk : in std_logic;
			reset : in std_logic;
			clk_out : out std_logic
		);
	end component;
	
	component mM is
		generic(
			dm_init : string := ""
		);
		port(
			clk  : in std_logic;
			reset : in std_logic;
			pc, ir, dbus, rs1, rs2 : in std_logic_vector(31 downto 0);
			stat : in std_logic_vector(3 downto 0);
			pcld, pcinc, irwr, regwr, statwr, dmwr, dmrd, dm2dbus,
				alu2dbus, reg2io, io2reg : in std_logic;
			aluop : in std_logic_vector(1 downto 0);
			showscreen : in std_logic;
			vgaHS, vgaVS, vgablank, vgapixel : out std_logic;
			vgacolumn : out std_logic_vector(6 downto 0);
			vgarow : out std_logic_vector(5 downto 0)
			);
	end component;
	
	component counter is
		generic (
			nmax : natural := 128
		);
		port(	
			clk : in std_logic;
			reset : in std_logic;
			recount : in std_logic;
			encount : in std_logic;
			n : out natural range 0 to nmax;
			onmax : out std_logic
		);
	end component;
	
	COMPONENT sign_ext IS
		PORT(
			immediate: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			ext_immediate: OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT FORWARD_UNIT IS
		PORT(
			Rs, Rt, EXMEM_Reg, MEMWB_Reg : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			EXMEM_RW, MEMWB_RW : IN STD_LOGIC; --REGISTER WRITE BACK CONTROL
			FWD_A, FWD_B : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT MUX4_1 IS
		PORT(
			IN0, IN1, IN2, IN3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			SEL : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			CHOICE : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;
	
	COMPONENT HAZARD_DETECTION IS
		PORT(
			IDEX_MemRead : IN STD_LOGIC;
			Rs, Rt, IDEX_Reg : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			PC_Wr, IFID_Wr, NOP : OUT STD_LOGIC
		);
	END COMPONENT;
	
------------PIPELINE REGISTER-----------------------------------

COMPONENT IFID_Pipe IS
	GENERIC (
		WORDSIZE	: NATURAL := 32
	);
	PORT (
		clock,
		load,
		clear			: IN	STD_LOGIC;
		Instruction_In	: IN	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
		PC_In			: IN	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
		Instruction_Out : OUT	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0);
		PC_Out			: OUT	STD_LOGIC_VECTOR(WORDSIZE-1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT IDEX IS
	PORT(
		CLK, CLEAR : IN STD_LOGIC;
		RS1_I, RS2_I, PC_In : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		INSTRUCTION_I : IN STD_LOGIC_VECTOR(28 DOWNTO 0);
		DM_Wr_I, DM_Rd_I, Reg_Wr_I, MemToReg_I, Jal_In : IN STD_LOGIC;
		RS1_O, RS2_O, PC_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		INSTRUCTION_O : OUT STD_LOGIC_VECTOR(28 DOWNTO 0);
		DM_Wr_O, DM_Rd_O, Reg_Wr_O, MemToReg_O, Jal_Out : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT EXMEM IS
	PORT(
		CLK, CLEAR : IN STD_LOGIC;
		ALUResult_I, RS1_I, RS2_I, PC_In : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		INSTRUCTION_I : IN STD_LOGIC_VECTOR(28 DOWNTO 0);
		DM_Wr_I, DM_Rd_I, Reg_Wr_I, MemToReg_I, Jal_In : IN STD_LOGIC;
		ALUResult_O, RS1_O, RS2_O, PC_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		INSTRUCTION_O : OUT STD_LOGIC_VECTOR(28 DOWNTO 0);
		DM_Wr_O, DM_Rd_O, Reg_Wr_O, MemToReg_O, Jal_Out : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT MEMWB IS
	PORT(
		CLK, CLEAR : IN STD_LOGIC;
		ALUResult_I : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		INSTRUCTION_I : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		DMRead_I : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		MemToReg_I, Reg_Wr_I, Jal_In : IN STD_LOGIC;
		ALUResult_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		INSTRUCTION_O : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		DMRead_O : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		MemToReg_O, Reg_Wr_O, Jal_Out : OUT STD_LOGIC
	);
END COMPONENT;
	
END PACKAGE;