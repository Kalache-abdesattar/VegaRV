library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rv32_pkg.all;



entity p_control_unit is  
    port(instruction : in std_logic_vector(31 downto 0);
		  dmem_bus_ctrl_o : out dmemory_bus_ctrl_type;	
		  cpu_dbus_ctrl_o : out cpu_dbus_ctrl_type;
		  alu_ctrl_o : out alu_ctrl_type;
		  p_rf_ctrl_o : out p_rf_ctrl_type
        );
end;



architecture arc of p_control_unit is 

	signal dmem_bus_ctrl : dmemory_bus_ctrl_type;	
	signal cpu_dbus_ctrl : cpu_dbus_ctrl_type;
	signal alu_ctrl : alu_ctrl_type;
	signal p_rf_ctrl : p_rf_ctrl_type;
	
	begin
		
		process(instruction)
			begin 	
				case instruction(6 downto 0) is
					when opcode_alu_c => 
						alu_ctrl.op1_sel <= "00";
						alu_ctrl.op2_sel <= "00";
						alu_ctrl.funct <= instruction(31 downto 25) & instruction(14 downto 12);
						
						p_rf_ctrl.in_sel <= "00";
						p_rf_ctrl.rd_ena <= '1';
						p_rf_ctrl.wr_ena <= '1';
						p_rf_ctrl.rd <= instruction(11 downto 7);
						
						cpu_dbus_ctrl.pc_sel_msb <= '1';
						cpu_dbus_ctrl.bmux_sel <= "000";
						
						
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
						
						
					when opcode_alui_c =>
						alu_ctrl.op1_sel <= "00";
						alu_ctrl.op2_sel <= "11"; --"1X"
						alu_ctrl.funct <= "0000000" & instruction(14 downto 12);
						
						p_rf_ctrl.in_sel <= "00";
						p_rf_ctrl.rd_ena <= '1';
						p_rf_ctrl.wr_ena <= '1';
						p_rf_ctrl.rd <= instruction(11 downto 7);
						
						cpu_dbus_ctrl.pc_sel_msb <= '1';
						cpu_dbus_ctrl.bmux_sel <= "000";
						
						
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
					
					when opcode_lui_c => 
						alu_ctrl.op1_sel <= "00";
						alu_ctrl.op2_sel <= "11";  --"1X"  
						alu_ctrl.funct <= (others=>'0');
						
						p_rf_ctrl.in_sel <= "00";
						p_rf_ctrl.rd_ena <= '1';
						p_rf_ctrl.wr_ena <= '1';
						p_rf_ctrl.rd <= instruction(11 downto 7);
						
						cpu_dbus_ctrl.pc_sel_msb <= '1';
						cpu_dbus_ctrl.bmux_sel <= "000";
						
						
						
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
						
						
					when opcode_auipc_c => 
						alu_ctrl.op1_sel <= "11";  --"1X"
						alu_ctrl.op2_sel <= "11";  --"1X" 
						alu_ctrl.funct <= (others=>'0');
						
						p_rf_ctrl.in_sel <= "00";	
						p_rf_ctrl.rd_ena <= '0';
						p_rf_ctrl.wr_ena <= '1';
						p_rf_ctrl.rd <= instruction(11 downto 7);
						
						cpu_dbus_ctrl.pc_sel_msb <= '1';
						cpu_dbus_ctrl.bmux_sel <= "000";
						
						
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;
					
					
					when opcode_branch_c => 
						alu_ctrl.op1_sel <= "00";
						alu_ctrl.op2_sel <= "00";
						alu_ctrl.funct <= (others=>'0');
						
						p_rf_ctrl.in_sel <= (others => '0');
						p_rf_ctrl.rd_ena <= '1';
						p_rf_ctrl.wr_ena <= '0';
						p_rf_ctrl.rd <= "00000";
						
						cpu_dbus_ctrl.pc_sel_msb <= '1';
						cpu_dbus_ctrl.bmux_sel <= instruction(14 downto 12);
						
						
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
		
					
					when opcode_jal_c => 
						alu_ctrl.op1_sel <= "11";  --"1X"
						alu_ctrl.op2_sel <= "11";  --"1X" 
						alu_ctrl.funct <= (others=>'0');
						
						p_rf_ctrl.in_sel <= "01";		
						p_rf_ctrl.rd_ena <= '0';
						p_rf_ctrl.wr_ena <= '1';
						p_rf_ctrl.rd <= instruction(11 downto 7);
						
						cpu_dbus_ctrl.pc_sel_msb <= '1';
						cpu_dbus_ctrl.bmux_sel <= "001";
						
						
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;
					
					
					when opcode_jalr_c => 
						alu_ctrl.op1_sel <= "11";  --"1X"
						alu_ctrl.op2_sel <= "11";  --"1X" 
						alu_ctrl.funct <= "0000000000";
						
						p_rf_ctrl.in_sel <= "01";	
						p_rf_ctrl.rd_ena <= '0';
						p_rf_ctrl.wr_ena <= '1';
						p_rf_ctrl.rd <= instruction(11 downto 7);
						
						cpu_dbus_ctrl.pc_sel_msb <= '1';
						cpu_dbus_ctrl.bmux_sel <= "000";
						
						
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;
						
						
					when opcode_load_c =>
						alu_ctrl.op1_sel <= "00";
						alu_ctrl.op2_sel <= "11";  --"1X"
						alu_ctrl.funct <= "0000000000";
						
						p_rf_ctrl.in_sel <= "10";  --"1X"
						p_rf_ctrl.rd_ena <= '1';
						p_rf_ctrl.wr_ena <= '1';
						p_rf_ctrl.rd <= instruction(11 downto 7);
						
						dmem_bus_ctrl.acc_ena <= '1';
						dmem_bus_ctrl.rd_ena <= '1';
						dmem_bus_ctrl.wr_ena <= '0';
						dmem_bus_ctrl.rd_ctrl <= (others=>'0');
						dmem_bus_ctrl.wr_ctrl <= instruction(13 downto 12);
						dmem_bus_ctrl.signext <= instruction(14);
						
						
							
						cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
						
						
						
					when opcode_store_c =>
						alu_ctrl.op1_sel <= "00";
						alu_ctrl.op2_sel <= "11";  --"1X"
						alu_ctrl.funct <= (others=>'0');
						
						p_rf_ctrl.in_sel <= (others=>'0');
						p_rf_ctrl.rd_ena <= '1';
						p_rf_ctrl.wr_ena <= '0';
						p_rf_ctrl.rd <= (others=>'0');
						
						dmem_bus_ctrl.acc_ena <= '1';
						dmem_bus_ctrl.rd_ena <= '0';
						dmem_bus_ctrl.wr_ena <= '1';
						dmem_bus_ctrl.rd_ctrl <= instruction(13 downto 12);
						dmem_bus_ctrl.wr_ctrl <= (others=>'0');
						dmem_bus_ctrl.signext <= instruction(14);
						
							
						cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
					
					
					when others => 
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
						cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
						alu_ctrl <= alu_ctrl_idle;
						p_rf_ctrl <= p_rf_ctrl_idle;
				end case;
		end process;
		
		
		dmem_bus_ctrl_o <= dmem_bus_ctrl;	
		cpu_dbus_ctrl_o <= cpu_dbus_ctrl;
		alu_ctrl_o <= alu_ctrl;
		p_rf_ctrl_o <= p_rf_ctrl;
		
					
end;