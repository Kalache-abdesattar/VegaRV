library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cpu_bus is 
	port(clk, reset : in std_logic;
		 alu_oper1, alu_oper2 : out signed(31 downto 0);
		 pc_i_alu : out signed(31 downto 0);
		 );
end;