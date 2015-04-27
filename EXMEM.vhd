LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY EXMEM IS
	PORT(
		CLK, CLEAR : IN STD_LOGIC;
		ALUResult_I, RS1_I, RS2_I, PC_In : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		INSTRUCTION_I : IN STD_LOGIC_VECTOR(28 DOWNTO 0);
		DM_Wr_I, DM_Rd_I, Reg_Wr_I, MemToReg_I, Jal_In : IN STD_LOGIC;
		ALUResult_O, RS1_O, RS2_O, PC_Out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		INSTRUCTION_O : OUT STD_LOGIC_VECTOR(28 DOWNTO 0);
		DM_Wr_O, DM_Rd_O, Reg_Wr_O, MemToReg_O, Jal_Out : OUT STD_LOGIC
	);
END EXMEM;

ARCHITECTURE BEHAVIOUR OF EXMEM IS
BEGIN

	PROCESS(CLK, CLEAR)
	BEGIN
		IF CLEAR = '1' THEN
			ALUResult_O <= (OTHERS => '0');
			RS1_O <= (OTHERS => '0');
			RS2_O <= (OTHERS => '0');
			PC_Out <= (OTHERS => '0');
			INSTRUCTION_O <= (OTHERS => '0');
			DM_Wr_O <= '0';
			DM_Rd_O <= '0';
			Reg_Wr_O <= '0';
			MemToReg_O <= '0';
			Jal_Out <= '0';
		ELSIF (CLK'EVENT AND CLK = '0') THEN
			ALUResult_O <= ALUResult_I;
			RS1_O <= RS1_I;
			RS2_O <= RS2_I;
			PC_Out <= PC_In;
			INSTRUCTION_O <= INSTRUCTION_I;
			DM_Wr_O <= DM_Wr_I;
			DM_Rd_O <= DM_Rd_I;
			Reg_Wr_O <= Reg_Wr_I;
			MemToReg_O <= MemToReg_I;
			Jal_Out <= Jal_In;
		END IF;
	END PROCESS;
END BEHAVIOUR;