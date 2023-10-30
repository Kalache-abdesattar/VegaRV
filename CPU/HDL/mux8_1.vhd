library ieee;
use ieee.std_logic_1164.all;


entity mux8_1 is 
	port(x1, x2, x3, x4, x5, x6, x7, x8 : in std_logic;
		sel : in std_logic_vector(2 downto 0);
		y : out std_logic
		 );
end;


architecture arc of mux8_1 is 
	begin 
		process(sel, x1, x2, x3, x4, x5, x6, x7, x8)
			begin 
				case sel is 
					when "000" =>
						y <= x1;
					when "001" =>
						y <= x2;
					when "010" =>
						y <= x3;
					when "011" =>
						y <= x4;
					when "100" =>
						y <= x5;
					when "101" =>
						y <= x6;
					when "110" =>
						y <= x7;
					when "111" =>
						y <= x8;
					when others =>
						y <= '0';
				end case;
		end process;
end;