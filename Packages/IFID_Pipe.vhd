LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY IFID_Pipe IS
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
END ENTITY;

ARCHITECTURE Behavior OF IFID_Pipe IS
BEGIN
	PROCESS (clock, load, clear, Instruction_In, PC_In)
	BEGIN
		IF clear = '1' THEN
			Instruction_Out <= (OTHERS => '0');
			PC_Out <= (OTHERS => '0');
		ELSIF (clock'event AND clock = '0') THEN
			IF (load = '1') THEN
				Instruction_Out <= Instruction_In;
				PC_Out <= PC_In;
			END IF;
		END IF;
	END PROCESS;
END ARCHITECTURE;