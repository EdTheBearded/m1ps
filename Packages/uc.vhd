LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY Packages;
USE Packages.Processor.ALL;

ENTITY UC IS
	PORT (
		clear,
		clock			: IN	STD_LOGIC;
		instruction		: IN	STD_LOGIC_VECTOR (5 DOWNTO 0);
		Stat			: IN	STD_LOGIC_VECTOR (3 DOWNTO 0); --C, V, N, Z
		Jump_En, DM_Wr, DM_Rd, PC_Ld_En, Reg_Wr, IF_Flush, Immediate, 
		MemToReg, Jal	: OUT	STD_LOGIC		
	);
END ENTITY;

ARCHITECTURE Behavior OF UC IS
	SIGNAL current_state : states_UC := FETCH;
BEGIN
	StateMachine:
	PROCESS (clear, clock, instruction, current_state)
	BEGIN
		IF (clear = '1') THEN
			Jump_En		<= '0';
			DM_Wr		<= '0';
			DM_Rd		<= '0';
			PC_Ld_En	<= '0';
			Reg_Wr		<= '0';
			MemToReg	<= '0';
			IF_Flush 	<= '0';
			Immediate	<= '0';
			Jal			<= '0';
			
			current_state <= FETCH;	
		ELSE --(clock'EVENT AND clock = '1') THEN
			Jump_En		<= '0';
			DM_Wr		<= '0';
			DM_Rd		<= '0';
			PC_Ld_En	<= '0';
			Reg_Wr		<= '0';
			MemToReg	<= '0';
			IF_Flush 	<= '0';
			Immediate	<= '0';
			Jal 		<= '0';
			CASE instruction(5 DOWNTO 3) IS
				WHEN "000" =>
					IF instruction(2 DOWNTO 0) = "000" THEN --NOP's causam problema.
						Reg_Wr		<= '0';
						MemToReg	<= '0';
						DM_Rd		<= '0';
					ELSE
						Reg_Wr		<= '1';
						MemToReg	<= '0';
						DM_Rd		<= '1';
					END IF;
				WHEN "001" =>
					MemToReg	<= '1';	
					Reg_Wr		<= '1';
					Immediate	<= instruction(2);
				WHEN "010" =>
					DM_Wr		<= '1';
				WHEN "011" =>
				WHEN "100" =>
					Reg_Wr		<= '1';				
				WHEN "101" =>	--Jal instruction (101000)
					MemToReg	<= '1';	
					Reg_Wr		<= '1';
					Jump_En		<= '1';
					--IF_Flush	<= '1';
					Jal			<= '1';
				WHEN "110" =>	--Jr instruction  (110000)
				WHEN OTHERS =>
					IF_Flush <= '1';
					CASE instruction(2 DOWNTO 0) IS
						WHEN "111" =>
							Jump_En	<= '1';
						WHEN OTHERS =>
							PC_Ld_En <= '1';
					END CASE;
			END CASE;
		END IF;
	END PROCESS;
END ARCHITECTURE;
