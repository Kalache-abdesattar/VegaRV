library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity riscv_tb_0 is 
	generic(constant xlen : natural := 32);
end entity;



architecture arc of riscv_tb_0 is
	COMPONENT cpu_core
	PORT
	(
		clk		:	 IN STD_LOGIC;
		reset		:	 IN STD_LOGIC;
		instruction		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		imem_read		:	 OUT STD_LOGIC;
		imem_addr		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		dmem_read_ena		:	 OUT STD_LOGIC;
		dmem_write_ena		:	 OUT STD_LOGIC;
		--dmem_addr		:	 OUT SIGNED(31 DOWNTO 0);
		dmem_data_in		:	 IN SIGNED(31 DOWNTO 0);
		dmem_data_out		:	 OUT SIGNED(31 DOWNTO 0)
	);
	END COMPONENT;


	type imem_type is array(0 to 127) of std_logic_vector(31 downto 0); 
	constant instructions : imem_type := (("00000000000000000000000000010011"),("00000000000100000000000010010011"),("00000000001000000000000100010011"),("00000000001100000000000110010011"),("00000000010000000000001000010011"),("00000000010100000000001010010011"),("00000000011000000000001100010011"),("00000000011100000000001110010011"),("00000000100000000000010000010011"),("00000000100100000000010010010011"),("00000000101000000000010100010011"),("00000000101100000000010110010011"),("00000000110000000000011000010011"),("00000000110100000000011010010011"),("00000000111000000000011100010011"),("00000000111100000000011110010011"),("00000001000000000000100000010011"),("00000001000100000000100010010011"),("00000001001000000000100100010011"),("00000001001100000000100110010011"),("00000001010000000000101000010011"),("00000001010100000000101010010011"),("00000001011000000000101100010011"),("00000001011100000000101110010011"),("00000001100000000000110000010011"),("00000001100100000000110010010011"),("00000001101000000000110100010011"),("00000001101100000000110110010011"),("00000001110000000000111000010011"),("00000001110100000000111010010011"),("00000001111000000000111100010011"),("00000001111100000000111110010011"),("00000000000100010111100000100011"),("00000010001100001101000000100011"),("00000000010100000100000000100011"),("00000001000000010111010110000011"),("00000010000000001101011010000011"),("00000000000000000100011110000011"), others=>(others=>'0'));
	constant tp : time := 8ns;
	
	signal clk, reset : std_logic := '0';
	signal instruction : std_logic_vector(31 downto 0);
	signal dmem_data_in : signed(31 downto 0) := (others=>'0');

	signal imem_read : std_logic;
	signal imem_addr : STD_LOGIC_VECTOR(31 DOWNTO 0);
	begin 
		clk <= not clk after 1ns;
		reset <= '1', '0' after 5ns;
		
		process
			begin 
				if(reset = '0') then
					for i in instructions'range loop
						instruction <= instructions(i);
						wait for tp;
					end loop;
				end if;
		end process;
			
	
		cp_core : cpu_core
		PORT MAP
	(
		clk	=> clk,
		reset		=> reset,
		instruction	=> instruction,
		imem_read	=> imem_read,
		imem_addr	=> imem_addr,
		dmem_read_ena	=> OPEN,
		dmem_write_ena		=> OPEN,
		--dmem_addr		=> OPEN,
		dmem_data_in		=> dmem_data_in,
		dmem_data_out		=> OPEN
	);
		 
end;
