library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rv32_pkg.all;



entity cpu_core_pipelined is 
	    port(clk, reset : in std_logic;
		 instruction : in std_logic_vector(31 downto 0);
		 imem_read : out std_logic;
		 imem_addr : out std_logic_vector(31 downto 0);
		 dmem_read_ena, dmem_write_ena : out std_logic;
		 --dmem_addr : out signed(31 downto 0);
		 dmem_data_in : in signed(31 downto 0);
		 dmem_data_out : out signed(31 downto 0)
		 );
end;



architecture arc of cpu_core_pipelined is 
	COMPONENT mux8_1 
	port
	(
		x1, x2, x3, x4, x5, x6, x7, x8 : in std_logic;
		sel : in std_logic_vector(2 downto 0);
		y : out std_logic
	);
	END COMPONENT;
	
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
	
	
	COMPONENT pc_unit
	PORT
	(
		clk		:	 IN STD_LOGIC;
		reset		:	 IN STD_LOGIC;
		sel		:	 IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		i_alu		:	 IN SIGNED(31 DOWNTO 0);
		imm		:	 IN SIGNED(19 DOWNTO 0);
		pc_out		:	 OUT SIGNED(31 DOWNTO 0);
		pc_4_out		:	 OUT SIGNED(31 DOWNTO 0)
	);
	END COMPONENT;
	
	
	COMPONENT alu
	PORT
	(
		oper1		:	 IN SIGNED(31 DOWNTO 0);
		oper2		:	 IN SIGNED(31 DOWNTO 0);
		sel		:	 IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		eq		:	 OUT STD_LOGIC;
		neq		:	 OUT STD_LOGIC;
		ge		:	 OUT STD_LOGIC;
		geu		:	 OUT STD_LOGIC;
		lt		:	 OUT STD_LOGIC;
		ltu		:	 OUT STD_LOGIC;
		out_sig		:	 OUT SIGNED(31 DOWNTO 0)
	);
	END COMPONENT;
	
	
	COMPONENT mem_bus_ctrl
	PORT
	(
		clk				:	 IN STD_LOGIC;
		reset			:	 IN STD_LOGIC;
		wr_ctrl_i		:	 IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		rd_ctrl_i		:	 IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		wr_ena_i		:	 IN STD_LOGIC;
		rd_ena_i		:	 IN STD_LOGIC;
		dmem_read_i		:	 IN SIGNED(31 DOWNTO 0);
		cpu_db_o		:	 OUT SIGNED(31 DOWNTO 0);
		alu_i		    :	 IN SIGNED(31 DOWNTO 0);
		dmem_wr_i		:	 IN SIGNED(31 DOWNTO 0);
		dmem_wr_o		:	 OUT SIGNED(31 DOWNTO 0);
		signext_i		:	 IN STD_LOGIC;
		dmem_addr_o		:	 OUT SIGNED(31 DOWNTO 0)
	);
	END COMPONENT;
	
	
	COMPONENT control_unit  
    port(
		clk, reset : in std_logic;
        instruction : in std_logic_vector(31 downto 0);
        imem_ctrl_o : out imemory_ctrl_type;
		dmem_bus_ctrl_o : out dmemory_bus_ctrl_type;	
		cpu_dbus_ctrl_o : out cpu_dbus_ctrl_type;
		alu_ctrl_o : out alu_ctrl_type;
		rf_ctrl_o : out rf_ctrl_type;
		imm_o : out signed(31 downto 0)
    );
	END COMPONENT;
	
	
	COMPONENT dmem_32
	PORT(
		clk		:	 IN STD_LOGIC;
		acc_ena		:	 IN STD_LOGIC;
		rd_ena		:	 IN STD_LOGIC;
		wr_ena		:	 IN STD_LOGIC;
		addr		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		rd_data		:	 OUT SIGNED(31 DOWNTO 0);
		wr_data		:	 IN SIGNED(31 DOWNTO 0)
	);
	END COMPONENT;


	
	------------------------------------------------------------------------------------------------
	signal alu_res : signed(31 downto 0);
	signal alu_oper1 : signed(31 downto 0);
	signal alu_oper2 : signed(31 downto 0);
	signal eq, neq, ge, geu, lt, ltu :	STD_LOGIC;
	------------------------------------------------------------------------------------------------
	
	------------------------------------------------------------------------------------------------
	signal rf_i_signal : signed(31 downto 0);
	signal rf_out1 : signed(31 downto 0);
	signal rf_out2 : signed(31 downto 0);
	------------------------------------------------------------------------------------------------
	
	------------------------------------------------------------------------------------------------
	signal pc_out : signed(31 downto 0);
	signal pc_4_out : signed(31 downto 0);
	signal pc_sel_lsb : std_logic;
 	signal pc_ctrl : std_logic_vector(1 downto 0);
	------------------------------------------------------------------------------------------------
	
	------------------------------------------------------------------------------------------------
	signal mem_RWB : signed(31 downto 0) := (others=>'X');
	signal dmem_in : signed(31 downto 0);
	signal dmem_out : signed(31 downto 0);
	signal dmem_addr : signed(31 downto 0);
	
	------------------------------------------------------------------------------------------------
	
	signal imm : signed(31 downto 0);
	
	signal imem_ctrl : imemory_ctrl_type;
	signal dmem_bus_ctrl : dmemory_bus_ctrl_type;	
	signal cpu_dbus_ctrl : cpu_dbus_ctrl_type;
	signal alu_ctrl : alu_ctrl_type;
	signal rf_ctrl : rf_ctrl_type;
	
	signal IF_ID : IF_ID_type;
	
	
	
	begin 
		control_unit_inst : control_unit  
			port map(
					clk		=> 	clk,
					reset	=>	reset, 
					instruction 	=>	instruction,
					imem_ctrl_o		=>	imem_ctrl, 
					dmem_bus_ctrl_o =>	dmem_bus_ctrl,	
					cpu_dbus_ctrl_o => 	cpu_dbus_ctrl,
					alu_ctrl_o 		=> 	alu_ctrl,
					rf_ctrl_o 		=>	rf_ctrl,
					imm_o 			=>	imm
		);
		
	
		with alu_ctrl.op1_sel select 
				alu_oper1 <= rf_out1 when "00",
						 pc_out when others;
		
		
		with alu_ctrl.op2_sel select 
				alu_oper2 <= rf_out2 when "00",
						 pc_out when "01",
						 imm when others;
		
		with rf_ctrl.in_sel select 
				rf_i_signal <= alu_res when "00",
							   pc_4_out when "01",
							   mem_RWB when others;
						 
					 
		pc_unit_inst : pc_unit 
			port map(
					clk		=>	clk, 
					reset	=>	reset, 
					imm		=>	imm(19 downto 0),
					i_alu	=>	alu_res,
					sel		=> 	pc_ctrl,
					pc_4_out	=>	pc_4_out,
					pc_out	=>	pc_out
				);
		
		
		alu_inst : alu 
			port map(
					oper1	=>	alu_oper1, 
					oper2	=>	alu_oper2,
					sel		=>	alu_ctrl.funct,
					out_sig	=>	alu_res,
					eq 		=> 	eq, 
					neq		=>	neq,
					ge		=>	ge, 
					geu		=> 	geu, 
					lt		=>	lt, 
					ltu		=>  ltu
				);
		
		
		rf_inst : register_file 
			port map(
					clk		=>	clk, 
					reset	=>	reset,
					i_signal	=>	rf_i_signal,
					out_sig_1	=>	rf_out1,
					out_sig_2	=>	rf_out2,
					rd_ena 	=>	rf_ctrl.rd_ena,
					wr_ena	=>	rf_ctrl.wr_ena,
					rd_sel_1		=>	rf_ctrl.rs1,
					rd_sel_2		=>	rf_ctrl.rs2,
					wr_sel		=> 	rf_ctrl.rd
				);
				
					
		
		branch_mux : mux8_1 
			port map(
					x1 => '0',
					x2 => '1',
					x3 => eq,
					x4 => neq,
					x5 => ge,
					x6 => geu,
					x7 => lt,
					x8 => ltu,
					sel => cpu_dbus_ctrl.bmux_sel,
					y => pc_sel_lsb
				);
			
		pc_ctrl <= cpu_dbus_ctrl.pc_sel_msb & pc_sel_lsb;		
		
		
		mem_bus_ctrl_inst : mem_bus_ctrl
			PORT MAP(
					clk		=>   clk,
					reset	=>   reset,
					wr_ctrl_i	=>    dmem_bus_ctrl.wr_ctrl,
					rd_ctrl_i	=>	  dmem_bus_ctrl.rd_ctrl,
					wr_ena_i	=>	  dmem_bus_ctrl.wr_ena,
					rd_ena_i	=>	  dmem_bus_ctrl.rd_ena,
					dmem_read_i =>	  dmem_out,
					cpu_db_o	=>	  mem_RWB,			---THIS IS FOR REGISTER WRITE BACK  
					alu_i		=>	  alu_res,
					dmem_wr_i	=>	  rf_out2,
					dmem_wr_o	=>	  dmem_in,
					signext_i	=>	  dmem_bus_ctrl.signext,
					dmem_addr_o	=>	  dmem_addr
					);
		
		
		dmem : dmem_32
			PORT MAP(
					clk		=>	 clk,
					acc_ena		=>	 dmem_bus_ctrl.acc_ena,
					rd_ena		=>	 dmem_bus_ctrl.rd_ena,
					wr_ena		=>	 dmem_bus_ctrl.wr_ena,
					addr		=>	 std_logic_vector(dmem_addr),
					rd_data		=>	 dmem_out,
					wr_data		=>	 dmem_in
					);
		
		
		imem_addr <= std_logic_vector(pc_out);
		imem_read <= imem_ctrl.rd_ena;
end;