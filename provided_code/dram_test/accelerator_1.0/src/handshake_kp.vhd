
-- Khaled 
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY handshake IS
    PORT (
        clk_src : IN STD_LOGIC;
        clk_dest : IN STD_LOGIC;
        go : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        ack : OUT STD_LOGIC;
        rcv : OUT STD_LOGIC

    );

    ARCHITECTURE bhv OF handshake IS
        SIGNAL send_src, send_dest1, send_dest2, receive_src, receive_dest1, receive_dest2 : STD_LOGIC;
        TYPE state_type IS (WAIT_S, SEND_S, CLEAR_SEND)
        SIGNAL state_src, state_dest : state_type;
    BEGIN
        PROCESS (clk_src, rst)
        BEGIN
            IF (rst = '1') THEN
                state_src <= WAIT_S;
                ack <= '0';
            ELSIF (rising_edge(clk)) THEN
                receive_dest1 <= receive_src;
                receive_dest2 <= receive_dest1;
                ack <= '0';
                CASE state_src IS
                    WHEN WAIT_S
                      
                        IF (go = '1') THEN
                            state_src <= SEND_S;
                            send_src <= '1';
                        END IF;
                    WHEN SEND_S
                        send_src <= '1';
                        IF (receive_dest2 = '1') THEN
                            state_src <= CLEAR_SEND;
                        END IF;

                    WHEN clear_send
                        send_src <= '0';
                        IF (receive_dest2 = '0') THEN
                            state_src <= WAIT_S;
                            ack <= '1';
                        END IF;
                END CASE;

            END PROCESS;

            PROCESS (clk_dest, rst)
            BEGIN
                IF (rst = '1') THEN
                    state_dest <= WAIT_S;
                    rcv <= '0';
                    receive_src <= '0';

                ELSIF (rising_edge(clk)) THEN
                    send_dest1 <= send_src;
                    send_dest2 <= send_dest1;
                    rcv <= '0';
                    CASE state_dest IS
                        WHEN WAIT_S
                            receive_src <= '0';
                            IF (send_dest2 = '1')
                                rcv <= '1';
                                state_dest <= SEND_S;
                            END IF;
                        WHEN SEND_S
                            receive_src <= '1';
                            state_dest <= CLEAR_SEND;

                        WHEN CLEAR_SEND
                            IF (send_dest2 = '0')
                                receive_src <= '0';
                                state_dest <= WAIT_S;
                            END IF;
                    END CASE;
                END PROCESS;