library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity barrel_shifter is 
    port(oper1 : in signed(31 downto 0);
        sel : in unsigned(4 downto 0);
        out_sig : out signed(31 downto 0));
end;




architecture arc of barrel_shifter is
	begin 
			process(oper1, sel)
				begin 
					out_sig <= oper1(0 to to_integer())
			end process;
end;