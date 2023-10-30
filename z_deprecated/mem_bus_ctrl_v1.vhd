library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;




entity mem_bus_ctrl is 
	port(clk, reset : in std_logic;
		 wr_ctrl_i : in std_logic_vector(1 downto 0);
		 rd_ctrl_i : in std_logic_vector(1 downto 0);
		 wr_ena_i, rd_ena_i : in std_logic;
		 dmem_read_i : in signed(31 downto 0);
		 cpu_db_o : out signed(31 downto 0);
		 alu_i : in signed(31 downto 0);
		 dmem_wr_i : in signed(31 downto 0);
		 dmem_wr_o : out signed(31 downto 0);
		 signext_i : in std_logic;
		 dmem_addr_o : out signed(31 downto 0)
		 );
end;



architecture arc of mem_bus_ctrl is 
	begin 	
		dmem_addr_o <= alu_i;
		
		process(clk)
			begin 
				if(clk'event and clk='1') then
					if(wr_ena_i = '1') then
						case(wr_ctrl_i) is 
							when "00" =>   --BYTE
								dmem_wr_o(7 downto 0) <= dmem_wr_i(7 downto 0);
								dmem_wr_o(31 downto 8) <= (others => '0');
							when "01" =>   --HALF WORD
								dmem_wr_o(15 downto 0) <= dmem_wr_i(15 downto 0);
								dmem_wr_o(31 downto 16) <= (others => '0');
							when others =>
								dmem_wr_o <= dmem_wr_i;
							end case;
					end if;
				end if;
		end process;
		
		
		process(clk)
			begin 
				if(clk'event and clk='1') then
					if(rd_ena_i = '1') then
						case(rd_ctrl_i) is 
							when "00" =>   --BYTE
								cpu_db_o(7 downto 0) <= dmem_read_i(7 downto 0);
								cpu_db_o(31 downto 8) <= (others => signext_i and dmem_read_i(7));
							when "01" =>   --HALF WORD
								cpu_db_o(15 downto 0) <= dmem_wr_i(15 downto 0);
								cpu_db_o(31 downto 16) <= (others => signext_i and dmem_read_i(15));
							when others =>
								cpu_db_o <= dmem_wr_i;
							end case;
					end if;
				end if;
		end process;
end;