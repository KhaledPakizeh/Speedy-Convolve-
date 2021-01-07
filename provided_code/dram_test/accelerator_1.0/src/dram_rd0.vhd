


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity dram_rd0 is 
    port (
            dram_clk : in std_logic;
            user_clk : in std_logic; 
            rst      : in std_logic; 
            go      : in std_logic; 
            size    : in std_logic_vector(); 
            start_addr : in std_logic_vector(14 downto 0); -- ram has a data bus that is 32 bits wide, so to access each 16 bit - we divide by 2.  
            rd_enable_fifo : in std_logic; 
            data    : out std_logic_vector(15 downto 0);
            done : out std_logic;
            rd_ram_en : out std_logic;  
            rd_address : out std_logic_vector(14 downto 0);
            dram_ready : in std_logic; 
            rd_valid: in std_logic; 
            rd_data : in std_logic_vector (31 downto 0)

    );

architecture BHV of dram_rd0 is 

    signal sync_go : std_logic; 
    begin 

    entity : work.address_gen
        port map (
                clk => dram_clk,
                rst => rst, 
                go => hand_shake_go 
                

        )   ; 

    entity : work.handshake 
        port map (
            clk_src => user_clk,
            clk_dest => dram_clk, 
            rst => rst, 
            go => go, 
            rcv => open
            ack => hand_shake_go


        )
 