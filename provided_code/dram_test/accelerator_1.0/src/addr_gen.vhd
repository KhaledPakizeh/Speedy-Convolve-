

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY addr_gen
    GENERIC (width : POSITIVE);

    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        start_address : IN STD_LOGIC_VECTOR(width - 1 DOWNTO 0) := (OTHERS => '0');
        size : IN STD_LOGIC_VECTOR(width DOWNTO 0);
        go : IN STD_LOGIC;
        dram_ready : IN sd_logic;
        FIFO_FULL : in std_logic; 
        rd_address : OUT STD_LOGIC_VECTOR(width DOWNTO 0);
        rd_enable : OUT STD_LOGIC;
        done : OUT STD_LOGIC

    );
    ARCHITECTURE bhv OF addr_gen IS
        TYPE state_type IS (INIT, EXCUTE, DONE)
        SIGNAL state, next_state : state_type;
        SIGNAL address, next_address : STD_LOGIC_VECTOR(width DOWNTO 0);
    BEGIN
        PROCESS (clk, rst)
        BEGIN
            IF (rst = '1') THEN
                state <= INIT;
                address <= (OTHERS => '0');
            ELSIF (rising_edge(clk)) THEN
                state <= next_state;
                address <= next_address;
            END IF;
        END PROCESS;

        PROCESS (address, start_address, size, go, state, dram_ready,FIFO_FULL)
        BEGIN
            next_state <= state;
            next_address <= address;
            rd_enable <= '0';
            done <= '0';
            CASE state IS
                WHEN INIT
                    next_address <= start_address;
                    IF (go = '1') THEN
                        next_state <= EXCUTE;
                    END IF;
                WHEN EXCUTE
                    IF(FIFO_FULL = 0) then 
                    next_address <= STD_LOGIC_VECTOR(unsigned(address) + 1);
                    rd_enable <= '1';
                    IF (unsigned(next_address) = unsigned(size) - 1) THEN
                        next_state <= DONE;
                        done <= '1';
                    END IF;
                end if; 
                
                WHEN DONE
                    done <= '1';
                    IF (go = '0')
                        next_state <= INIT;
                    END IF;
            END CASE;
        END PROCESS;