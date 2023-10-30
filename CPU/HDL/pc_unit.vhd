library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity pc_unit is 
	port(clk, reset : in std_logic;
		 sel : in std_logic_vector(1 downto 0);
		 i_alu : in signed(31 downto 0);
		 imm : in signed(19 downto 0);
		 pc_out, pc_4_out : out signed(31 downto 0));
end;




architecture arc of pc_unit is 
	signal pc, pc_2 : signed(31 downto 0) := (others=>'0');
	signal pc_4 : signed(31 downto 0) := (others=>'0');
	signal pc_imm : signed(31 downto 0) := (others=>'0');
	
	constant mask : signed(31 downto 0) := x"FFFFFFFE";

	begin	
		pc_4 <= pc_2 + x"00000004";
		pc_imm <= pc_2 + ("000000000" & imm & "0");
		
		process(clk, reset)
			begin 
				if(reset = '1') then 
					pc <= (others=>'0');
				elsif(clk'event and clk='1') then 
					case sel is 
						when "01" => pc <= i_alu and mask;
						when "10" => pc <= pc_4;
						when "11" => pc <= pc_imm;
						when others => NULL;
					end case;
				end if;
		end process;
		
		
		process(clk, reset)
			begin 
				if(reset = '1') then 
					pc_2 <= (others=>'0');
				elsif(clk'event and clk='1') then
					pc_2 <= pc;
				end if;
		end process;	
		
		pc_out <= pc_2;
		pc_4_out <= pc_4;
		
end;