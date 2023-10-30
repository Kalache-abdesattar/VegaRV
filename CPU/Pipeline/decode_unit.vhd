library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rv32_pkg.all;



entity decode_unit is 
	    port(clk, reset, stall : in std_logic;
		 rwb : in signed(31 downto 0);
		 IF_ID_data_i : in IF_ID_DATA_type;   ---INSTRUCTION + PC + PC_4
		 ID_EX_data_o : out ID_EX_DATA_type;
		 RWB_ID_ctrl_i : in CTRL_type;
		 ID_EX_ctrl_o : out CTRL_type
		 );
end;



architecture arc of decode_unit is 
	
	COMPONENT register_file
	PORT
	(
		clk		:	 IN STD_LOGIC;
		reset		:	 IN STD_LOGIC;
		rd_ena		:	 IN STD_LOGIC;
		wr_ena		:	 IN STD_LOGIC;
		i_signal		:	 IN SIGNED(31 DOWNTO 0);
		rd_sel_1		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		rd_sel_2		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		wr_sel		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		out_sig_1		:	 OUT SIGNED(31 DOWNTO 0);
		out_sig_2		:	 OUT SIGNED(31 DOWNTO 0)
	);
	END COMPONENT;
	
	
	
	COMPONENT p_control_unit  
    port(
      instruction : in std_logic_vector(31 downto 0);
		dmem_bus_ctrl_o : out dmemory_bus_ctrl_type;	
		cpu_dbus_ctrl_o : out cpu_dbus_ctrl_type;
		alu_ctrl_o : out alu_ctrl_type;
		p_rf_ctrl_o : out p_rf_ctrl_type
    );
	END COMPONENT;
	
	
	COMPONENT immediate_generation 
	    port(instruction : in std_logic_vector(31 downto 0);
		 imm : out signed(31 downto 0)
		 );
	END COMPONENT;

	------------------------------------------------------------------------------------------------
	signal rf_i_signal : signed(31 downto 0);
	signal rf_out1 : signed(31 downto 0);
	signal rf_out2 : signed(31 downto 0);
	signal rs1, rs2 : signed(31 downto 0);
	signal rs1_sel, rs2_sel, rd_sel : std_logic_vector(4 downto 0);
	-------------------------------------
	-----------------------------------------------------------
	signal forward_rs1, forward_rs2 : std_logic := '0';

	------------------------------------------------------------------------------------------------
	--
	
	signal imm : signed(31 downto 0);
	
	signal dmem_bus_ctrl : dmemory_bus_ctrl_type;	
	signal cpu_dbus_ctrl : cpu_dbus_ctrl_type;
	signal alu_ctrl : alu_ctrl_type;
	signal p_rf_ctrl : p_rf_ctrl_type;
	
	
	begin 
		p_control_unit_inst : p_control_unit  
			port map( 
					instruction 	=>	IF_ID_data_i.instruction,
					dmem_bus_ctrl_o =>	dmem_bus_ctrl,	
					cpu_dbus_ctrl_o => 	cpu_dbus_ctrl,
					alu_ctrl_o 		=> 	alu_ctrl,
					p_rf_ctrl_o 		=>	p_rf_ctrl
		);
		
	
		
		rf_i_signal <= rwb;				 
		
		
		imm_gen : immediate_generation 
				port map(instruction => IF_ID_data_i.instruction,
							imm => imm
		 );
		 
		 
		 
		rs1_sel <= IF_ID_data_i.instruction(19 downto 15);
		rs2_sel <= IF_ID_data_i.instruction(24 downto 20); 
		rd_sel <= RWB_ID_ctrl_i.p_rf_ctrl.rd;
		 
		rf_inst : register_file 
			port map(
					clk		=>	clk, 
					reset	=>	reset,
					i_signal	=>	rf_i_signal,
					out_sig_1	=>	rf_out1,
					out_sig_2	=>	rf_out2,
					rd_ena 	=>	p_rf_ctrl.rd_ena,
					wr_ena	=>	RWB_ID_ctrl_i.p_rf_ctrl.wr_ena,
					rd_sel_1		=>	rs1_sel,
					rd_sel_2		=>	rs2_sel,
					wr_sel		=> rd_sel
				);
		
		
		----INSTRUCTION FORWARDING
		process(rs1_sel, rs2_sel, rd_sel)
			begin
				if(rs1_sel = rd_sel) then
					rs1 <= rwb;
					forward_rs1 <= '1';
				else 	
					rs1 <= rf_out1;
					forward_rs1 <= '0';
				end if;
				
				if(rs2_sel = rd_sel) then
					rs1 <= rwb;
					forward_rs2 <= '1';
				else 	
					rs2 <= rf_out2;
					forward_rs2 <= '0';
				end if;
		end process;
					
		
		process(reset, stall, clk)
			begin 
				if(reset = '1') then 
						ID_EX_ctrl_o.dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
						ID_EX_ctrl_o.cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
						ID_EX_ctrl_o.alu_ctrl <= alu_ctrl_idle;
						ID_EX_ctrl_o.p_rf_ctrl <= p_rf_ctrl_idle;
						
						ID_EX_data_o <= ID_EX_DATA_idle;
						
				elsif(clk'event and clk = '1') then 
					if(stall = '0') then
						ID_EX_ctrl_o.dmem_bus_ctrl <= dmem_bus_ctrl;
						ID_EX_ctrl_o.cpu_dbus_ctrl <= cpu_dbus_ctrl;
						ID_EX_ctrl_o.alu_ctrl <= alu_ctrl;
						ID_EX_ctrl_o.p_rf_ctrl <= p_rf_ctrl;
						
						ID_EX_data_o.forward_rs1 <= forward_rs1;
						ID_EX_data_o.forward_rs2 <= forward_rs2;
						ID_EX_data_o.rs1 <= rf_out1;
						ID_EX_data_o.rs2 <= rf_out2;
						ID_EX_data_o.imm <= imm;
						ID_EX_data_o.pc <= IF_ID_data_i.pc;
						ID_EX_data_o.pc_4 <= IF_ID_data_i.pc_4;
					end if;
				end if;
		end process;
end;