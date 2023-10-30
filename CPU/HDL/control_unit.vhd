library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rv32_pkg.all;



entity control_unit is  
    port(clk, reset : in std_logic;
        instruction : in std_logic_vector(31 downto 0);
        imem_ctrl_o : out imemory_ctrl_type;
		dmem_bus_ctrl_o : out dmemory_bus_ctrl_type;	
		cpu_dbus_ctrl_o : out cpu_dbus_ctrl_type;
		alu_ctrl_o : out alu_ctrl_type;
		rf_ctrl_o : out rf_ctrl_type;
		imm_o : out signed(31 downto 0)
        );
end;



architecture arc of control_unit is 
	type state is (idle, fetch1, decode, execute, Mem, RWB);
	signal pr_state, next_state : state; 
	--attribute fsm_encoding : string;
	--attribute fsm_encoding of state : signal is "gray"; 
	
	signal sign_padding : std_logic_vector(19 downto 0);
	signal imm : signed(31 downto 0);
	
	signal imem_ctrl : imemory_ctrl_type;
	signal dmem_bus_ctrl : dmemory_bus_ctrl_type;	
	signal cpu_dbus_ctrl : cpu_dbus_ctrl_type;
	signal alu_ctrl : alu_ctrl_type;
	signal rf_ctrl : rf_ctrl_type;
	
	
    begin 
		process(clk, reset)
			begin 
				if(reset = '1') then 
					pr_state <= idle;
				elsif(clk'event and clk = '1') then 
					pr_state <= next_state;
				end if;
		end process;
		
		
		process(pr_state)
			begin 
				case pr_state is 
					when idle =>
						next_state <= fetch1;
					when fetch1 =>
						next_state <= execute;
					when decode =>
						next_state <= execute;
					when execute =>
						next_state <= Mem;
					when Mem =>
						next_state <= RWB;
					when RWB =>
						next_state <= fetch1;
				end case;
		end process;
		
		
		process(pr_state, instruction)
			begin 
				sign_padding <= (others=>'0');
				imm <= (others=>'0');
				
				imem_ctrl <= imem_ctrl_idle;
				case pr_state is 
					when idle =>
						imem_ctrl <= imem_ctrl_idle;
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
						cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
						alu_ctrl <= alu_ctrl_idle;
						rf_ctrl <= rf_ctrl_idle;
						
						imm <= (others => '0');
						
					when fetch1 =>
						imem_ctrl.rd_ena <= '1';
						imem_ctrl.addr_ena <= '1';
						
						
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
						cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
						alu_ctrl <= alu_ctrl_idle;
						rf_ctrl <= rf_ctrl_idle;
						
					when decode =>
						imem_ctrl <= imem_ctrl_idle;
						dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
						cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
						alu_ctrl <= alu_ctrl_idle;
						rf_ctrl <= rf_ctrl_idle;
						
					when execute =>
						case instruction(6 downto 0) is
							when opcode_alu_c => 
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "00";
								alu_ctrl.funct <= instruction(31 downto 25) & instruction(14 downto 12);
								
								rf_ctrl.in_sel <= (others => '0');
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= instruction(24 downto 20);
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= "00000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
				
								imm <= (others => '0');
								
							when opcode_alui_c => 
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 20));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11";  --"1X"
								alu_ctrl.funct <= "0000000" & instruction(14 downto 12);
								
								rf_ctrl.in_sel <= (others=>'0');
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= (others=>'0');
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= "00000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								
							when opcode_lui_c => 
								sign_padding <= (others=>instruction(31));          ----
								imm <= signed(instruction(31 downto 20) & "00000000000000000000");  ---signext(imm20 << 12)
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11"; --"1X"   
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= (others=>'0');
								rf_ctrl.rs1 <= "00000";    --rs1 <= ZERO
								rf_ctrl.rs2 <= (others=>'0');
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= "00000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								
							when opcode_auipc_c => 
								sign_padding <= (others=>instruction(31));          ----
								imm <= signed(instruction(31 downto 20) & "00000000000000000000");  ---signext(imm20 << 12)
								
								alu_ctrl.op1_sel <= "11";   --"1X"
								alu_ctrl.op2_sel <= "11";   --"1X"   
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= (others=>'0');
								rf_ctrl.rs1 <= (others=>'0');  
								rf_ctrl.rs2 <= (others=>'0');		
								rf_ctrl.rd_ena <= '0';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= "00000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								
							when opcode_branch_c => 
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 20));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "00";
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= (others => '0');
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= instruction(24 downto 20);
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= "00000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
				
								
							when opcode_jal_c => 
								sign_padding <= (others=>instruction(31));          ----
								imm <= signed(sign_padding(10 downto 0) & instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(10 downto 1) & "0");
								
								alu_ctrl.op1_sel <= "11";  --"1X"
								alu_ctrl.op2_sel <= "11";  --"1X" 
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= "01";
								rf_ctrl.rs1 <= (others=>'0');  
								rf_ctrl.rs2 <= (others=>'0');		
								rf_ctrl.rd_ena <= '0';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= "00000";
								
								cpu_dbus_ctrl.pc_sel_msb <= '0';
								cpu_dbus_ctrl.bmux_sel <= "000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;
							
							
							when opcode_jalr_c => 
								sign_padding <= (others=>instruction(31));          ----
								imm <= signed(sign_padding & instruction(31 downto 20)); 
								
								alu_ctrl.op1_sel <= "00";  --"1X"
								alu_ctrl.op2_sel <= "11";  --"1X" 
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= "01";
								rf_ctrl.rs1 <= instruction(19 downto 15); 
								rf_ctrl.rs2 <= (others=>'0');		
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= "00000";
								
								cpu_dbus_ctrl.pc_sel_msb <= '0';
								cpu_dbus_ctrl.bmux_sel <= "000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;
								

							when opcode_load_c =>
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 20));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11";  --"1X"
								alu_ctrl.funct <= "0000000000";
								
								rf_ctrl.in_sel <= (others=>'0');
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= (others=>'0');
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= (others=>'0');
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								
								
							when opcode_store_c =>
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 25) & instruction(11 downto 7));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11";  --"1X"
								alu_ctrl.funct <= "0000000000";
								
								rf_ctrl.in_sel <= (others=>'0');
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= instruction(24 downto 20);
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= (others=>'0');
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								
								
							when others =>
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								alu_ctrl <= alu_ctrl_idle;
								rf_ctrl <= rf_ctrl_idle;
						
						end case;
								
					when Mem =>
						case instruction(6 downto 0) is 
							when opcode_load_c =>
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 20));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11";  --"1X"
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= (others=>'0');
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= (others=>'0');
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= (others=>'0');
								
								dmem_bus_ctrl.acc_ena <= '1';
								dmem_bus_ctrl.rd_ena <= '1';
								dmem_bus_ctrl.wr_ena <= '0';
								dmem_bus_ctrl.rd_ctrl <= (others=>'0');
								dmem_bus_ctrl.wr_ctrl <= instruction(13 downto 12);
								dmem_bus_ctrl.signext <= instruction(14);
								
								
								imem_ctrl <= imem_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								
								
							when opcode_store_c =>
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 25) & instruction(11 downto 7));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11";  --"1X"
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= (others=>'0');
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= instruction(24 downto 20);
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= (others=>'0');
								
								dmem_bus_ctrl.acc_ena <= '1';
								dmem_bus_ctrl.rd_ena <= '0';
								dmem_bus_ctrl.wr_ena <= '1';
								dmem_bus_ctrl.rd_ctrl <= instruction(13 downto 12);
								dmem_bus_ctrl.wr_ctrl <= (others=>'0');
								dmem_bus_ctrl.signext <= instruction(14);
								
								imem_ctrl <= imem_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								
								
							when others =>
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								alu_ctrl <= alu_ctrl_idle;
								rf_ctrl <= rf_ctrl_idle;
						end case;	
						
						
					when RWB => 
						case instruction(6 downto 0) is
							when opcode_alu_c => 
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "00";
								alu_ctrl.funct <= instruction(31 downto 25) & instruction(14 downto 12);
								
								rf_ctrl.in_sel <= "00";
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= instruction(24 downto 20);
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '1';
								rf_ctrl.rd <= instruction(11 downto 7);
								
								cpu_dbus_ctrl.pc_sel_msb <= '1';
								cpu_dbus_ctrl.bmux_sel <= "000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
				
								imm <= (others => '0');
								
							when opcode_alui_c => 
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 20));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11"; --"1X"
								alu_ctrl.funct <= "0000000" & instruction(14 downto 12);
								
								rf_ctrl.in_sel <= "00";
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= (others=>'0');
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '1';
								rf_ctrl.rd <= instruction(11 downto 7);
								
								cpu_dbus_ctrl.pc_sel_msb <= '1';
								cpu_dbus_ctrl.bmux_sel <= "000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
							
							when opcode_lui_c => 
								sign_padding <= (others=>instruction(31));          ----
								imm <= signed(instruction(31 downto 20) & "00000000000000000000");  ---signext(imm20 << 12)
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11";  --"1X"  
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= "00";
								rf_ctrl.rs1 <= "00000";    --rs1 <= ZERO
								rf_ctrl.rs2 <= (others=>'0');
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '1';
								rf_ctrl.rd <= instruction(11 downto 7);
								
								cpu_dbus_ctrl.pc_sel_msb <= '1';
								cpu_dbus_ctrl.bmux_sel <= "000";
								
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								
								
							when opcode_auipc_c => 
								sign_padding <= (others=>instruction(31));          ----
								imm <= signed(instruction(31 downto 20) & "00000000000000000000");  ---signext(imm20 << 12)
								
								alu_ctrl.op1_sel <= "11";  --"1X"
								alu_ctrl.op2_sel <= "11";  --"1X" 
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= "00";
								rf_ctrl.rs1 <= (others=>'0');  
								rf_ctrl.rs2 <= (others=>'0');		
								rf_ctrl.rd_ena <= '0';
								rf_ctrl.wr_ena <= '1';
								rf_ctrl.rd <= instruction(11 downto 7);
								
								cpu_dbus_ctrl.pc_sel_msb <= '1';
								cpu_dbus_ctrl.bmux_sel <= "000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;
							
							
							when opcode_branch_c => 
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 20));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "00";
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= (others => '0');
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= instruction(24 downto 20);
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= "00000";
								
								cpu_dbus_ctrl.pc_sel_msb <= '1';
								cpu_dbus_ctrl.bmux_sel <= instruction(14 downto 12);
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
				
							
							when opcode_jal_c => 
								sign_padding <= (others=>instruction(31));          ----
								imm <= signed(sign_padding(10 downto 0) & instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(10 downto 1) & "0");
								
								alu_ctrl.op1_sel <= "11";  --"1X"
								alu_ctrl.op2_sel <= "11";  --"1X" 
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= "01";
								rf_ctrl.rs1 <= (others=>'0');  
								rf_ctrl.rs2 <= (others=>'0');		
								rf_ctrl.rd_ena <= '0';
								rf_ctrl.wr_ena <= '1';
								rf_ctrl.rd <= instruction(11 downto 7);
								
								cpu_dbus_ctrl.pc_sel_msb <= '1';
								cpu_dbus_ctrl.bmux_sel <= "001";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;
							
							
							when opcode_jalr_c => 
								sign_padding <= (others=>instruction(31));          ----
								imm <= signed(sign_padding & instruction(31 downto 20)); 
								
								alu_ctrl.op1_sel <= "11";  --"1X"
								alu_ctrl.op2_sel <= "11";  --"1X" 
								alu_ctrl.funct <= "0000000000";
								
								rf_ctrl.in_sel <= "01";
								rf_ctrl.rs1 <= (others=>'0');  
								rf_ctrl.rs2 <= (others=>'0');		
								rf_ctrl.rd_ena <= '0';
								rf_ctrl.wr_ena <= '1';
								rf_ctrl.rd <= instruction(11 downto 7);
								
								cpu_dbus_ctrl.pc_sel_msb <= '1';
								cpu_dbus_ctrl.bmux_sel <= "000";
								
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;
								
								
							when opcode_load_c =>
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 20));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11";  --"1X"
								alu_ctrl.funct <= "0000000000";
								
								rf_ctrl.in_sel <= "10";  --"1X"
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= (others=>'0');
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '1';
								rf_ctrl.rd <= instruction(11 downto 7);
								
								dmem_bus_ctrl.acc_ena <= '1';
								dmem_bus_ctrl.rd_ena <= '1';
								dmem_bus_ctrl.wr_ena <= '0';
								dmem_bus_ctrl.rd_ctrl <= (others=>'0');
								dmem_bus_ctrl.wr_ctrl <= instruction(13 downto 12);
								dmem_bus_ctrl.signext <= instruction(14);
								
								
								imem_ctrl <= imem_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								
								
								
							when opcode_store_c =>
								sign_padding <= (others => instruction(31));
								imm <= signed(sign_padding & instruction(31 downto 25) & instruction(11 downto 7));
								
								
								alu_ctrl.op1_sel <= "00";
								alu_ctrl.op2_sel <= "11";  --"1X"
								alu_ctrl.funct <= (others=>'0');
								
								rf_ctrl.in_sel <= (others=>'0');
								rf_ctrl.rs1 <= instruction(19 downto 15);
								rf_ctrl.rs2 <= instruction(24 downto 20);
								rf_ctrl.rd_ena <= '1';
								rf_ctrl.wr_ena <= '0';
								rf_ctrl.rd <= (others=>'0');
								
								dmem_bus_ctrl.acc_ena <= '1';
								dmem_bus_ctrl.rd_ena <= '0';
								dmem_bus_ctrl.wr_ena <= '1';
								dmem_bus_ctrl.rd_ctrl <= instruction(13 downto 12);
								dmem_bus_ctrl.wr_ctrl <= (others=>'0');
								dmem_bus_ctrl.signext <= instruction(14);
								
								imem_ctrl <= imem_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
	
								
							when others =>
								imem_ctrl <= imem_ctrl_idle;
								dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
								cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
								alu_ctrl <= alu_ctrl_idle;
								rf_ctrl <= rf_ctrl_idle;
						end case;
				end case;
		end process;
		
		
		imem_ctrl_o <= imem_ctrl;
		dmem_bus_ctrl_o <= dmem_bus_ctrl;	
		cpu_dbus_ctrl_o <= cpu_dbus_ctrl;
		alu_ctrl_o <= alu_ctrl;
		rf_ctrl_o <= rf_ctrl;
		
		imm_o <= imm;
					
end;