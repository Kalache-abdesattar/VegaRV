library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.rv32_pkg.all;


entity immediate_generation is 
	    port(instruction : in std_logic_vector(31 downto 0);
		 imm : out signed(31 downto 0)
		 );
end;


architecture arc of immediate_generation is 
	signal sign_padding : std_logic_vector(19 downto 0) := (others=>'0');
	
	signal imm12 : signed(31 downto 0):= (others=>'0');
	signal imm20 : signed(31 downto 0):= (others=>'0');
	signal imm_store : signed(31 downto 0):= (others=>'0');
	
	begin
		sign_padding <= (others=>instruction(31));
		
		imm12 <= signed(sign_padding & instruction(31 downto 20));
		imm20 <= signed(sign_padding(10 downto 0) & instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(10 downto 1) & "0");
		imm_store <= signed(sign_padding & instruction(31 downto 25) & instruction(11 downto 7));
		
		
		process(instruction, imm12, imm20, imm_store)
			begin 
				case instruction(6 downto 0) is 
					when opcode_jal_c =>
						imm <= imm20;
					when opcode_store_c =>
						imm <= imm_store;
					when others =>
						imm <= imm12;
				end case;
		end process;
end;