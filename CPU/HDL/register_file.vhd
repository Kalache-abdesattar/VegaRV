library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




entity register_file is  
    port(clk, reset : in std_logic;
        rd_ena, wr_ena : in std_logic;
        i_signal : in signed(31 downto 0);
        rd_sel_1, rd_sel_2, wr_sel : in std_logic_vector(4 downto 0);
        out_sig_1, out_sig_2 : out signed(31 downto 0)
        );
end;




architecture arc of register_file is 
    constant zero : signed(31 downto 0) := (others=>'0');
	
	signal x0 : signed(31 downto 0) := (others=>'0');

    type reg_file_type is array(1 to 31) of signed(31 downto 0);
    signal regx1_x31 : reg_file_type := (others=>(others=>'0'));
 
    begin 
		x0 <= zero;
		
        process(clk, reset, i_signal, wr_ena, wr_sel)
            begin 
                if(reset = '1') then 
                    regx1_x31 <= (others=>(others=>'0'));
                elsif(clk'event and clk = '1') then 
                    if(wr_ena = '1') then 
                        case wr_sel is 
                            when "00000" => 
                                null; ----X0 WRITE-PROTECT
                            when others =>
                                regx1_x31(to_integer(unsigned(wr_sel))) <= i_signal;
                        end case;
                    end if;
                end if;
        end process;

		
        
        process(rd_sel_1, rd_ena, rd_sel_2, x0, regx1_x31)
            begin   
				if(rd_ena = '1') then 
					case rd_sel_1 is 
						when "00000" => 
							out_sig_1 <= x0;
						when others =>
							out_sig_1 <= regx1_x31(to_integer(unsigned(rd_sel_1)));
					end case;

					case rd_sel_2 is 
						when "00000" => 
							out_sig_2 <= x0;
						when others =>
							out_sig_2 <= regx1_x31(to_integer(unsigned(rd_sel_2)));
					end case;
				else 
					out_sig_1 <= (others=>'X');
					out_sig_2 <= (others=>'X');
 				end if;
        end process;        
end;