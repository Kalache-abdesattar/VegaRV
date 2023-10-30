library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rv32_pkg.all;



entity rwb_unit is 
	    port(MEM_RWB_data_i : in MEM_RWB_DATA_type;  
		 MEM_RWB_ctrl_i : in CTRL_type;
		 rwb_o : out signed(31 downto 0);
		 RWB_ID_ctrl_o : out CTRL_type;
		 RWB_IF_ctrl_o : out CTRL_type;
		 RWB_IF_data_o : out RWB_IF_DATA_type
		 );
end;



architecture arc of rwb_unit is
	
	begin 
		
		with MEM_RWB_ctrl_i.p_rf_ctrl.in_sel select 
				rwb_o <= MEM_RWB_data_i.alu_res when "00",
							   MEM_RWB_data_i.pc_4 when "01",
							   MEM_RWB_data_i.mem_RWB when others;
								
		
		RWB_IF_ctrl_o <= MEM_RWB_ctrl_i;
		RWB_ID_ctrl_o <= MEM_RWB_ctrl_i;
		
end;
