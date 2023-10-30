library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use ieee.math_real.all;

use work.rv32_pkg.all;


entity dmem_32 is 
	port(clk : in std_logic;
		 acc_ena : in std_logic;
		 rd_ena : in std_logic;
		 wr_ena : in std_logic;
		 addr : in std_logic_vector(31 downto 0);
		 rd_data : out signed(31 downto 0);
		 wr_data : in signed(31 downto 0)
		 );
end dmem_32;



architecture arc of dmem_32 is 
	constant dmem_size : natural := 256;
	constant bits : natural := 8;
	
	type dmem_32_type is array(0 to dmem_size-1) of signed(31 downto 0);
	signal dmem_32_arr : dmem_32_type := (others=>(others=>'1'));
	
	begin 
			process(clk, dmem_32_arr, acc_ena, wr_data, wr_ena, addr)
				begin 
					if(clk'event and clk = '1') then 
						if(acc_ena = '1') then 
							if(rd_ena = '1') then 
								rd_data <= dmem_32_arr(to_integer(unsigned(addr(bits-1 downto 0))));
							elsif(wr_ena = '1') then 
								dmem_32_arr(to_integer(unsigned(addr(bits-1 downto 0)))) <= wr_data;
							end if;
						end if;
					end if;
			end process;
end;