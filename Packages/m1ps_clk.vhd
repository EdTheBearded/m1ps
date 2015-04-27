library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity m1ps_clk is
	port(
		clk : in std_logic;
		reset : in std_logic;
		clock3 : in std_logic;
		clock1 : in std_logic;
		clk_out : out std_logic
	);
end m1ps_clk;

architecture a_clk of m1ps_clk is
	CONSTANT CONS_CLOCK_DIV : INTEGER := 1000000;
	signal  slow_clk, counting, clk3_out : std_logic;
begin
	
	clock_divider:
	PROCESS (clk, reset)
		VARIABLE i : INTEGER := 0;
	BEGIN
		IF (reset = '1') THEN
			i := 0;
			slow_clk <= '0';
		ELSIF (rising_edge(clk)) THEN
			IF (i <= CONS_CLOCK_DIV/2) THEN
				i := i + 1;
				slow_clk <= '0';
			ELSIF (i < CONS_CLOCK_DIV-1) THEN
				i := i + 1;
				slow_clk <= '1';
			ELSE		
				i := 0;
			END IF;	
		END IF;
	END PROCESS;
	
	process(slow_clk, reset)
		variable counter : natural range 5 downto 0;
	begin
		if reset = '1' then
			 counter := 0;
			 counting <= '0';
		elsif slow_clk'event and slow_clk = '1' then
			clk3_out <= '0';
			if clock3 = '1' then
				counter := 5;
				counting <= '1';
			elsif counter /= 0 then
				clk3_out <= not clk3_out;
				counter := counter - 1;
			end if;
		end if;
	end process;
	
	clk_out <= clk3_out when counting = '1' else clock1;	
end a_clk;