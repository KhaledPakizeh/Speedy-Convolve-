

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.config_pkg.ALL;
USE work.user_pkg.ALL;

ENTITY signal_buffer IS
    GENERIC (
        size_of_buff : POSITIVE : 128;
        size_of_element : POSITIVE : 16
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        load_buffer : IN STD_LOGIC;
        input : IN STD_LOGIC_VECTOR(size_of_element - 1 DOWNTO 0);
        -- Window defined in the packge folder. 
        output : window(0 TO size_of_buff - 1)
    );
END signal_buffer

ARCHITECTURE BHV OF signal_buffer IS

    SIGNAL OUTPU_REG : window(0 TO size_of_buff - 1);
    -- how many register have valid data in them ?. 
    SIGNAL counter : unsigned(INTEGER(ceil((log2(real(size_of_buff))))) DOWNTO 0) := (OTHERS => '0');
    SIGNAL full, empty : STD_LOGIC;

    PROCESS (clk, rst)
    BEGIN

        IF (rst = '1') THEN
            FOR i IN 0 TO size_of_buff - 1 LOOP
                OUTPU_REG(i) <= (OTHERS => '0');
            END LOOP;
            empty <= '1';
            full <= '0';

        ELSIF (rising_edge(clk)) THEN
            IF (load_buffer = '1') THEN -- new input is avaliable. 
                IF (counter = size_of_buff - 2) THEN
                    IF (rd_en = '1') THEN
                        full <= '0'; -- make FULL = 0 as long as we are reading (RD_EN = 1) even if we are at the max BUFF SIZE. 
                        FOR i IN 0 TO size_of_buff - 2 LOOP -- stering logic
                            OUTPU_REG(i + 1) <= OUTPU_REG(i);
                        END LOOP;
                        OUTPU_REG(0) <= input; -- ADD input to the array.

                    ELSE
                        full <= '1'; -- no more space for new input. 
                    END IF;

                    empty <= '0'; -- BUFF no longer empty (128 elements are ready to be sent out).
                ELSE
                    counter <= counter + 1; -- there is space for a new input.
                    FOR i IN 0 TO size_of_buff - 2 LOOP -- stering logic
                        OUTPU_REG(i + 1) <= OUTPU_REG(i);
                    END LOOP;
                    OUTPU_REG(0) <= input; -- ADD input to the array.

                    IF (counter = size_of_buff - 2) THEN -- now we are the max limit.
                        empty <= '0'; -- BUFF no longer empty (128 elements are ready to be sent out).

                        IF (rd_en = '1') THEN
                            full <= '0'; -- make FULL = 0 as long as we are reading (RD_EN = 1) even if we are at the max BUFF SIZE. 

                        ELSE
                            full <= '1';
                        END IF;
                    ELSE
                        empty <= '1'; -- we are empty still. (there are no 128 elements ready to be sent out)

                    END IF;
                END IF;
            END IF;

        END PROCESS;
        PROCESS (OUTPU_REG, rd_en, empty)
        BEGIN

            IF (empty = '0') THEN
                IF (rd_en = '1') THEN
                    counter <= counter - 1; -- new input needed.
                    empty <= '1';
                    FOR i IN 0 TO size_of_buff - 1
                        output(i) <= OUTPU_REG(i); -- send current output buffer.
                    END LOOP;
                END IF;
            END IF;

        END PROCESS;
    END BHV;