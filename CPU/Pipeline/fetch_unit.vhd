library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rv32_pkg.all;



entity fetch_unit is 
	    port(clk, reset, stall : in std_logic;
		 imem_read : out std_logic;
		 instruction : in std_logic_vector(31 downto 0);
		 imem_addr : out std_logic_vector(31 downto 0);
		 RWB_IF_data_i : in RWB_IF_DATA_type;  
		 RWB_IF_ctrl_i : in CTRL_type;
		 IF_ID_ctrl_o : out CTRL_type;
		 IF_ID_data_o : out IF_ID_DATA_type
		 );
end;



architecture arc of fetch_unit is

	COMPONENT mux8_1 
	port
	(
		x1, x2, x3, x4, x5, x6, x7, x8 : in std_logic;
		sel : in std_logic_vector(2 downto 0);
		y : out std_logic
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
	
		------------------------------------------------------------------------------------------------
	signal pc_out : signed(31 downto 0);
	signal pc_4_out : signed(31 downto 0);
	signal pc_sel_lsb : std_logic;
 	signal pc_ctrl : std_logic_vector(1 downto 0);
	------------------------------------------------------------------------------------------------
	
	
	begin 
		imem_read <= '1';
		
		branch_mux : mux8_1 
			port map(
					x1 => '0',
					x2 => '1',
					x3 => RWB_IF_data_i.eq,
					x4 => RWB_IF_data_i.neq,
					x5 => RWB_IF_data_i.ge,
					x6 => RWB_IF_data_i.geu,
					x7 => RWB_IF_data_i.lt,
					x8 => RWB_IF_data_i.ltu,
					sel => RWB_IF_ctrl_i.cpu_dbus_ctrl.bmux_sel,
					y => pc_sel_lsb
				);
			
		pc_ctrl <= RWB_IF_ctrl_i.cpu_dbus_ctrl.pc_sel_msb & pc_sel_lsb;

		
		pc_unit_inst : pc_unit 
			port map(
					clk		=>	clk, 
					reset	=>	reset, 
					imm		=>	RWB_IF_data_i.imm(19 downto 0),
					i_alu	=>	RWB_IF_data_i.alu_res,
					sel		=> 	pc_ctrl,
					pc_4_out	=>	pc_4_out,
					pc_out	=>	pc_out
				);
		
		
		process(reset, stall, clk)
			begin 
				if(reset = '1') then 
						IF_ID_ctrl_o.dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
						IF_ID_ctrl_o.cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
						IF_ID_ctrl_o.alu_ctrl <= alu_ctrl_idle;
						IF_ID_ctrl_o.p_rf_ctrl <= p_rf_ctrl_idle;
						
						IF_ID_data_o <= IF_ID_DATA_idle;
						
				elsif(clk'event and clk = '1') then 
					if(stall = '0') then 
						IF_ID_ctrl_o.dmem_bus_ctrl <= dmem_bus_ctrl_idle;	
						IF_ID_ctrl_o.cpu_dbus_ctrl <= cpu_dbus_ctrl_idle;
						IF_ID_ctrl_o.alu_ctrl <= alu_ctrl_idle;
						IF_ID_ctrl_o.p_rf_ctrl <= p_rf_ctrl_idle;
						
						IF_ID_data_o.instruction <= instruction;
						IF_ID_data_o.pc 		<= pc_out;
						IF_ID_data_o.pc_4 		<= 	pc_4_out;
					end if;
				end if;
		end process;
		
end;
