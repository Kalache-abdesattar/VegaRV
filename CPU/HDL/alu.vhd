library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity alu is 
    port(oper1, oper2 : in signed(31 downto 0);
        sel : in std_logic_vector(9 downto 0);
		eq, neq, ge, geu, lt, ltu : out std_logic;   ---Flags
        out_sig : out signed(31 downto 0));
end;



architecture arc of alu is
	signal eq_sig, neq_sig, ge_sig, geu_sig, lt_sig, ltu_sig : std_logic := '0'; 
	signal branch_tmp : signed(31 downto 0);
    
	begin
		eq_sig <= '1' when(oper1 = oper2) else '0';
		neq_sig <= not eq_sig;
		
		ge_sig <= '1' when(oper1 > oper2) else '0';
		lt_sig <= not ge_sig;
		
		geu_sig <= '1' when(unsigned(oper1) > unsigned(oper2)) else '0';
		ltu_sig <= not geu_sig;
		
		
        process(sel, oper1, oper2)
            begin 
                case sel is 
                    when "0000000000" => 
                        out_sig <= oper1 + oper2;
                    when "0000000001" => 
                        out_sig <= oper1 xor oper2;
					when "0000000010" => 
						out_sig <= oper1 or oper2;
					when "0000000011" => 
						out_sig <= oper1 and oper2;
					when "0000000100" =>
						out_sig <= oper1 SLL to_integer(unsigned(oper2(4 downto 0)));
					when "0000000101" =>
						out_sig <= oper1 SRL to_integer(unsigned(oper2(4 downto 0)));
					when "0000000110" =>
						out_sig <= oper1(31 downto 31) & (oper1(30 downto 0) SRL to_integer(unsigned(oper2(4 downto 0))));
					
					when "0000000111" => 
                        if(unsigned(oper1) < unsigned(oper2)) then 
                            out_sig <= (others=>'1');
                        else out_sig <= (others=>'0');
                        end if;	
									
					when "0000001000" =>  
						if(oper1 < oper2) then 
							 out_sig <= (others=>'1');
						else out_sig <= (others=>'0');
						end if;
						
                    when "0000001001" => 
                        out_sig <= oper1 - oper2;
						
                    when others => out_sig <= (others=>'0');
					end case;
		end process;  
		
		eq <= eq_sig;
		neq <= neq_sig;
		
		ge <= ge_sig;
		geu <= geu_sig;
		
		lt <= lt_sig;
		ltu <= ltu_sig;
                    
end;