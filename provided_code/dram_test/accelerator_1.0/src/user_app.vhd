-- Khaled & Sobhi

library ieee;
use ieee.std_logic_1164.all;
use work.user_pkg.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.config_pkg.all;



entity user_app is
    port (
        clk	   : in  std_logic;
        rst    : in  std_logic;
        sw_rst : in std_logic;
		load_in_kernel_buffer : in std_logic;
		load_in_kernel_data : in std_logic_vector(KERNEL_WIDTH_RANGE);
        ram0_rd_read_enable_signal : out std_logic;
        ram0_rd_valid : in  std_logic;
        ram0_rd_data  : in  std_logic_vector(RAM0_RD_DATA_RANGE);
        ram1_wr_valid : out std_logic;
        ram1_wr_data  : out std_logic_vector(RAM1_WR_DATA_RANGE)

        );
end user_app;


architecture default of user_app is

	signal reset_all_signal : std_logic;
	signal kernel_empty_signal : std_logic;
	signal tree_out : std_logic_vector(16 + 16 + integer(ceil(log2(real(128)))) - 1 downto 0);
	signal not_empty : std_logic;
	signal not_full : std_logic;
	signal read_enable_signal : std_logic;
	signal valid_input_signal : std_logic;
	signal valid_output_signal : std_logic;
	signal out_signal : window(0 to 127);
	signal kernel_signal_out : window(0 to 127);
	signal signal_full : std_logic;
	signal kernel_signal_full : std_logic;
	signal empty_s : std_logic;
	

begin

	ram1_wr_valid <= valid_output_signal;
    reset_all_signal  <= rst or sw_rst;
    ram0_rd_read_enable_signal <= ram0_rd_valid;
    
		
	SIGNAL_BUFF_inst0 : entity work.signal_buffer
		port map (
			clk => clk,
			rst => reset_all_signal,
			rd_en => ram0_rd_valid,
			input => ram0_rd_data,		
			output => out_signal,
			full => signal_full,
			empty => empty_s,
			load_buffer => ram0_rd_valid
		);
		valid_input_signal <= signal_full and ram0_rd_valid;
	    not_full <= not signal_full;
	    not_empty <= not empty_s;

		-- Kernell stuff.
	SIGNAL_BUFF_inst1 : entity work.signal_buffer
		port map (
			clk => clk,
			rst => reset_all_signal,
			rd_en => load_in_kernel_buffer,        
			input => load_in_kernel_data,		
			output => kernel_signal_out,
			full => kernel_signal_full,
			empty => kernel_empty_signal,
			load_buffer => load_in_kernel_buffer,
			kernel_enable => '1'
		);
		
		-- given (choose unsigned)
	TREE_MULT : entity work.mult_add_tree(unsigned_arch)
		generic map (num_inputs => 128,   
					input1_width => 16,
					input2_width => 16
		)
		port map (
			clk  => clk,
			rst  => reset_all_signal,
			en   => '1',
			input1 => kernel_signal_out,
			input2 => out_signal,
			output => tree_out
		);
	CLIPP_WORK_inst : entity work.clipp_signal
		generic map (input_width => 39,
					output_width => 16)
		port map (
			input => tree_out,
			output => ram1_wr_data
		);

	
	DELAY_inst_valid : entity work.delay
		generic map (width => 1,
					 cycles => 9,  -- enough to get valid          
					 init => "0")
		port map (
			clk => clk,
			rst => reset_all_signal,
			en => '1',					
			input(0) => valid_input_signal,                             
			output(0) => valid_output_signal
		);
			

end default;


