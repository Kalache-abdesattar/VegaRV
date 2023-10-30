library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



package rv32_pkg is 
	
	constant XLEN : natural := 32;

	-- RISC-V Opcodes -------------------------------------------------------------------------
	-- -------------------------------------------------------------------------------------------
	-- alu --
	constant opcode_alui_c   : std_logic_vector(6 downto 0) := "0010011"; -- ALU operation with immediate (operation via funct3 and funct7)
	constant opcode_alu_c    : std_logic_vector(6 downto 0) := "0110011"; -- ALU operation (operation via funct3 and funct7)
	constant opcode_lui_c    : std_logic_vector(6 downto 0) := "0110111"; -- load upper immediate
	constant opcode_auipc_c  : std_logic_vector(6 downto 0) := "0010111"; -- add upper immediate to PC
	-- control flow --
	constant opcode_jal_c    : std_logic_vector(6 downto 0) := "1101111"; -- jump and link
	constant opcode_jalr_c   : std_logic_vector(6 downto 0) := "1100111"; -- jump and link with register
	constant opcode_branch_c : std_logic_vector(6 downto 0) := "1100011"; -- branch (condition set via funct3)
	-- memory access --
	constant opcode_load_c   : std_logic_vector(6 downto 0) := "0000011"; -- load (data type via funct3)
	constant opcode_store_c  : std_logic_vector(6 downto 0) := "0100011"; -- store (data type via funct3)
	-- sync/system/csr --
	constant opcode_fence_c  : std_logic_vector(6 downto 0) := "0001111"; -- fence / fence.i
	-- floating point operations --
	constant opcode_fop_c    : std_logic_vector(6 downto 0) := "1010011"; -- dual/single operand instruction
	-- official *custom* RISC-V opcodes - free for custom instructions --
	constant opcode_cust0_c  : std_logic_vector(6 downto 0) := "0001011"; -- custom-0
	constant opcode_cust1_c  : std_logic_vector(6 downto 0) := "0101011"; -- custom-1
	constant opcode_cust2_c  : std_logic_vector(6 downto 0) := "1011011"; -- custom-2
	constant opcode_cust3_c  : std_logic_vector(6 downto 0) := "1111011"; -- custom-3

	
	-- RISC-V Control Types -------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------
	-- Instruction Memory Bus control 
	type imemory_ctrl_type is record
		rd_ena : std_logic;
		addr_ena : std_logic;
	end record;
	
	
	-- Data Memory Bus control
	type dmemory_bus_ctrl_type is record
		acc_ena : std_logic;
		rd_ena : std_logic;
		wr_ena : std_logic;
		rd_ctrl : std_logic_vector(1 downto 0);
		wr_ctrl : std_logic_vector(1 downto 0);
		signext : std_logic;
	end record;
	

	-- Internal Cpu Bus control
	type cpu_dbus_ctrl_type is record
		pc_sel_msb : std_logic;
		bmux_sel : std_logic_vector(2 downto 0);
	end record;
	
	
	-- ALU Control 
	type alu_ctrl_type is record
		op1_sel : std_logic_vector(1 downto 0);
		op2_sel : std_logic_vector(1 downto 0);
		funct : std_logic_vector(9 downto 0);
	end record;
	
	

	-- Register File Control
	type rf_ctrl_type is record
		in_sel : std_logic_vector(1 downto 0);
		rs1 : std_logic_vector(4 downto 0);
		rs2 : std_logic_vector(4 downto 0);
		rd : std_logic_vector(4 downto 0);
		rd_ena : std_logic;
		wr_ena : std_logic;
	end record;
	
	
	-- Register File Control FOR THE PIPELINED VARIANT
	type p_rf_ctrl_type is record
		in_sel : std_logic_vector(1 downto 0);
		rd : std_logic_vector(4 downto 0);
		rd_ena : std_logic;
		wr_ena : std_logic;
	end record;
	
	
	
	
	-- IDLE State Control Constants
	-- --------------------------------------------------------------------------------------------------
	constant imem_ctrl_idle : imemory_ctrl_type := (
		rd_ena => '0',
		addr_ena => '0'
	);
	
	constant dmem_bus_ctrl_idle : dmemory_bus_ctrl_type := (
		acc_ena => '0',
		rd_ena => '0',
		wr_ena => '0',
		rd_ctrl => "00",
		wr_ctrl => "00",
		signext => '0'
	);
	
	constant cpu_dbus_ctrl_idle : cpu_dbus_ctrl_type := (
		pc_sel_msb => '0',
		bmux_sel => "000"
	);
	
	constant alu_ctrl_idle : alu_ctrl_type := (
		op1_sel => "00",
		op2_sel => "00",
		funct => "0000000000"
	);
		
	constant rf_ctrl_idle : rf_ctrl_type := (
		in_sel => "00",
		rs1 => "00000",
		rs2 => "00000",
		rd => "00000",
		rd_ena => '0',
		wr_ena => '0'
	);
	
	constant p_rf_ctrl_idle : p_rf_ctrl_type := (
		in_sel => "00",
		rd => "00000",
		rd_ena => '0',
		wr_ena => '0'
	);
	
	
	-- RISC-V Control Types FOR THE PIPELINED VARIANT-------------------------------------------------------------------------
	-- --------------------------------------------------------------------------------------------------
	-- Instruction FETCH-DECODE REGISTER
	type IF_ID_DATA_type is record
		instruction : std_logic_vector(31 downto 0);
		pc : signed(31 downto 0);
		pc_4 : signed(31 downto 0);
	end record;
	
	
	-- Instruction DECODE-EXECUTE DATA REGISTER
	type ID_EX_DATA_type is record
		rs1 : signed(31 downto 0);
		rs2 : signed(31 downto 0);
		imm : signed(31 downto 0);
		pc : signed(31 downto 0);
		pc_4 : signed(31 downto 0);
		forward_rs1 : std_logic;
		forward_rs2 : std_logic;
	end record;
	
	
	type EX_MEM_DATA_type is record
		rs1 : signed(31 downto 0);
		rs2 : signed(31 downto 0);
		imm : signed(31 downto 0);
		alu_res : signed(31 downto 0);
		pc : signed(31 downto 0);
		pc_4 : signed(31 downto 0);
		eq		:	 STD_LOGIC;
		neq		:	 STD_LOGIC;
		ge		:	 STD_LOGIC;
		geu		:	 STD_LOGIC;
		lt		:	 STD_LOGIC;
		ltu		:	 STD_LOGIC;
	end record;
	
	
	type MEM_RWB_DATA_type is record
		rs1 : signed(31 downto 0);
		rs2 : signed(31 downto 0);
		imm : signed(31 downto 0);
		alu_res : signed(31 downto 0);
		pc : signed(31 downto 0);
		pc_4 : signed(31 downto 0);
		mem_rwb : signed(31 downto 0);
		eq		:	 STD_LOGIC;
		neq		:	 STD_LOGIC;
		ge		:	 STD_LOGIC;
		geu		:	 STD_LOGIC;
		lt		:	 STD_LOGIC;
		ltu		:	 STD_LOGIC;
	end record;
	
	
	type RWB_IF_DATA_type is record
		imm : signed(31 downto 0);
		alu_res : signed(31 downto 0);
		pc : signed(31 downto 0);
		pc_4 : signed(31 downto 0);
		eq		:	 STD_LOGIC;
		neq		:	 STD_LOGIC;
		ge		:	 STD_LOGIC;
		geu		:	 STD_LOGIC;
		lt		:	 STD_LOGIC;
		ltu		:	 STD_LOGIC;
	end record;
	
	
	
	
	-----------------------IDLE
	constant IF_ID_DATA_idle : IF_ID_DATA_type :=(
		instruction => "00000000000000000000000000000000",
		pc => "00000000000000000000000000000000",
		pc_4 => "00000000000000000000000000000000"
	);
	
	
	-- Instruction DECODE-EXECUTE DATA REGISTER
	constant ID_EX_DATA_idle : ID_EX_DATA_type :=(
		rs1 => "00000000000000000000000000000000",
		rs2 => "00000000000000000000000000000000",
		imm => "00000000000000000000000000000000",
		pc => "00000000000000000000000000000000",
		pc_4 => "00000000000000000000000000000000",
		forward_rs1 => '0',
		forward_rs2 => '0'
		);
	
	
	constant EX_MEM_DATA_idle : EX_MEM_DATA_type :=(
		rs1 => "00000000000000000000000000000000",
		rs2 => "00000000000000000000000000000000",
		imm => "00000000000000000000000000000000",
		alu_res => "00000000000000000000000000000000",
		pc => "00000000000000000000000000000000",
		pc_4 => "00000000000000000000000000000000",
		eq		=> '0',
		neq	=> '0',
		ge		=> '0',
		geu	=> '0',
		lt		=> '0',
		ltu	=> '0'
	);
	
	
	constant MEM_RWB_DATA_idle : MEM_RWB_DATA_type :=(
		mem_rwb => "00000000000000000000000000000000",
		rs1 => "00000000000000000000000000000000",
		rs2 => "00000000000000000000000000000000",
		imm => "00000000000000000000000000000000",
		alu_res => "00000000000000000000000000000000",
		pc => "00000000000000000000000000000000",
		pc_4 => "00000000000000000000000000000000",
		eq		=> '0',
		neq	=> '0',
		ge		=> '0',
		geu	=> '0',
		lt		=> '0',
		ltu	=> '0'
	);
	
	
	
	constant RWB_IF_DATA_idle : RWB_IF_DATA_type :=(
		imm => "00000000000000000000000000000000",
		alu_res => "00000000000000000000000000000000",
		pc => "00000000000000000000000000000000",
		pc_4 => "00000000000000000000000000000000",
		eq		=> '0',
		neq	=> '0',
		ge		=> '0',
		geu	=> '0',
		lt		=> '0',
		ltu	=> '0'
	);
	
	
	
	
	--- CONTROL REGISTER FOR CPU PIPELINE
	type CTRL_type is record
		dmem_bus_ctrl : dmemory_bus_ctrl_type;	
		cpu_dbus_ctrl : cpu_dbus_ctrl_type;
		alu_ctrl : alu_ctrl_type;
		p_rf_ctrl : p_rf_ctrl_type;
	end record;
	
end rv32_pkg;


package body rv32_pkg is 
end rv32_pkg;	