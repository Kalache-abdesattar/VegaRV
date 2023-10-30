library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rv32_pkg.all;



entity pipelined_core is 
	    port(clk, reset : in std_logic;
		 instruction : in std_logic_vector(31 downto 0);
		 imem_read : out std_logic;
		 imem_addr : out std_logic_vector(31 downto 0)
		 );
end;



architecture arc of pipelined_core is
 
	Component fetch_unit  
	    port(clk, reset, stall : in std_logic;
		 imem_read : in std_logic;
		 instruction : in signed(31 downto 0);
		 imem_addr : out std_logic_vector(31 downto 0);
		 RWB_IF_data_i : in RWB_IF_DATA_type;  
		 RWB_IF_ctrl_i : in CTRL_type;
		 IF_DEC_ctrl_o : out CTRL_type;
		 RWB_IF_data_o : out MEM_RWB_DATA_type
		 );
	end Component;
	
	Component decode_unit  
	    port(clk, reset, stall : in std_logic;
		 rwb : in signed(31 downto 0);
		 IF_ID_data_i : in IF_ID_type;   
		 ID_EX_data_o : out ID_EX_DATA_type;
		 RWB_DEC_ctrl_i : in CTRL_type;
		 ID_EXEC_ctrl_o : out CTRL_type
		 );
	end Component;
	
	
	Component exec_unit 
	    port(clk, reset, stall : in std_logic;
		 ID_EX_data_i : in ID_EX_DATA_type;  
		 ID_EX_ctrl_i : in CTRL_type;
		 EX_MEM_data_o : out EXEC_MEM_DATA_type;
		 EX_MEM_ctrl_o : out CTRL_type
		 );
	end Component;
	
	
	Component mem_unit  
	    port(clk, reset, stall : in std_logic;
		 EX_MEM_data_i : in EX_MEM_DATA_type;  
		 EX_MEM_ctrl_i : in CTRL_type;
		 MEM_RWB_ctrl_o : out CTRL_type;
		 MEM_RWB_data_o : out MEM_RWB_DATA_type
		 );
	end Component;
	
	
	Component rwb_unit 
	    port(MEM_RWB_data_i : in MEM_RWB_DATA_type;  
		 MEM_RWB_ctrl_i : in CTRL_type;
		 rwb_o : out signed(31 downto 0);
		 RWB_IF_ctrl_o : out CTRL_type;
		 RWB_IF_data_o : out MEM_RWB_DATA_type
		 );
	end Component;
	
	
	signal rwb : signed(31 downto 0);
	signal stall : std_logic;
	
	
	signal RWB_IF_data : RWB_IF_DATA_type;  
	signal RWB_IF_ctrl : CTRL_type;
	signal IF_DEC_ctrl : CTRL_type;
	signal RWB_IF_data : MEM_RWB_DATA_type;
	
	signal IF_ID_data : IF_ID_type;   
	signal RWB_DEC_ctrl : CTRL_type;
	
	signal ID_EX_data : ID_EX_DATA_type;  
	signal ID_EX_ctrl : CTRL_type;
	
	signal EX_MEM_data : EX_MEM_DATA_type;  
	signal EX_MEM_ctrl : CTRL_type;
	
	signal MEM_RWB_data : MEM_RWB_DATA_type;  
	signal MEM_RWB_ctrl : CTRL_type;
	
	begin
		stall <= '0';
		
		fetch_unit_inst : fetch_unit 
				port map(
						clk	=>	clk,
						reset	=>	reset,
						stall =>	stall,
						imem_read =>	imem_read,
						instruction =>	instruction,
						imem_addr =>	imem_addr,
						RWB_IF_data_i => RWB_IF_data,
						RWB_IF_ctrl_i => RWB_IF_ctrl,
						IF_DEC_ctrl_o => IF_DEC_ctrl,
						RWB_IF_data_o => RWB_IF_data
				);
				
				
		decode_unit_inst : decode_unit 
				port map(
						clk	=>	clk,
						reset	=>	reset,
						stall =>	stall,
						rwb => rwb,
						IF_ID_data_i =>	IF_ID_data,   
						ID_EX_data_o =>	ID_EX_data,
						RWB_DEC_ctrl_i =>	RWB_DEC_ctrl,
						ID_EX_ctrl_o =>	ID_EXEC_ctrl,
				);
		
		
		exec_unit_inst : exec_unit 
				port map(
						clk	=>	clk,
						reset	=>	reset,
						stall =>	stall,
						ID_EX_data_i =>	ID_EX_data,	  
						ID_EX_ctrl_i =>	ID_EX_ctrl,
						EX_MEM_data_o =>	EX_MEM_data,
						EX_MEM_ctrl_o =>	EX_MEM_ctrl
						
				);
		
		
		mem_unit_inst : mem_unit 
				port map(
						clk	=>	clk,
						reset	=>	reset,
						stall =>	stall,
						EX_MEM_data_i =>	EX_MEM_data,  
						EX_MEM_ctrl_i =>	EX_MEM_ctrl,
						MEM_RWB_ctrl_o =>	MEM_RWB_ctrl,
						MEM_RWB_data_o =>	MEM_RWB_data
				);
				
				
		rwb_unit_inst : rwb_unit 
				port map(
						MEM_RWB_data_i =>	MEM_RWB_data,  
						MEM_RWB_ctrl_i =>	MEM_RWB_ctrl,
						rwb_o =>	rwb,
						RWB_IF_ctrl_o =>	RWB_IF_ctrl,
						RWB_IF_data_o =>	RWB_IF_data
				);		
end;	