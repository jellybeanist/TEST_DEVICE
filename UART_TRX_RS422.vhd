library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TRX_RS422 is
	port
	(
		CLK                   : IN	STD_LOGIC;
		RST                   : IN	STD_LOGIC;
		
		CLK_DIV_BAUD_RS422    : IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		
        TX_OUT_RS422          : OUT	STD_LOGIC;
		RX_IN_RS422           : IN	STD_LOGIC;
	
		RX_BUF_EMPTY_RS422    : OUT	STD_LOGIC;
		RX_BUF_RDEN_RS422     : IN	STD_LOGIC;
		RX_BUF_DATA_RS422     : OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
        	
		TX_BUF_FULL_RS422     : OUT  	STD_LOGIC;
		TX_BUF_WREN_RS422     : IN  	STD_LOGIC;
		TX_BUF_DATA_RS422     : IN	STD_LOGIC_VECTOR(7 DOWNTO 0)		
	);
end UART_TRX_RS422;

architecture Behavioral of UART_TRX_RS422 is

	signal rx_fifo_full_rs422		: std_logic := '0';
	signal rx_fifo_wr_en_rs422		: std_logic := '0';
	signal rx_fifo_din_rs422		: std_logic_vector(7 downto 0) := (others=>'0');
	signal rx_data_rs422			: std_logic_vector(7 downto 0) := (others=>'0');
	signal rx_data_valid_rs422		: std_logic := '0';
	
	signal tx_data_rs422			: std_logic_vector(7 downto 0) := (others=>'0');
	signal tx_data_valid_rs422		: std_logic := '0';
	signal tx_busy_rs422			: std_logic := '0';
	signal tx_fifo_rden_rs422		: std_logic := '0';
	signal tx_fifo_empty_rs422		: std_logic := '0';
	signal tx_fifo_dout_rs422		: std_logic_vector(7 downto 0) := (others=>'0');

    COMPONENT UART_RX_FIFO_RS422
      PORT (
        rst         : IN STD_LOGIC;
        clk         : IN STD_LOGIC;
        din         : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_en       : IN STD_LOGIC;
        rd_en       : IN STD_LOGIC;
        dout        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        full        : OUT STD_LOGIC;
        empty       : OUT STD_LOGIC
      );
       end component UART_RX_FIFO_RS422;
       
    COMPONENT UART_TX_FIFO_RS422
        PORT (
          rst       : IN STD_LOGIC;
          clk       : IN STD_LOGIC;
          din       : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
          wr_en     : IN STD_LOGIC;
          rd_en     : IN STD_LOGIC;
          dout      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
          full      : OUT STD_LOGIC;
          empty     : OUT STD_LOGIC
        );
 end component UART_TX_FIFO_RS422;
 
begin

	uart_rx_i : entity work.UART_RX_RS422 
		port map
		(
			CLK 			=> CLK,
			rst			 	=> RST,
			
			rx_in 			=> rx_in_rs422,
			
			clk_div_baud 	=> CLK_DIV_BAUD_RS422,
			
			rx_data 		=> rx_data_rs422,
			rx_data_valid 	=> rx_data_valid_rs422,
			rx_err 			=> open
		);

	rx_fifo_wr_en_rs422 <= rx_data_valid_rs422 and (not rx_fifo_full_rs422);
	rx_fifo_din_rs422 <= rx_data_rs422; 
	
	U0_RX_FIFO : UART_RX_FIFO_RS422
        PORT MAP 
        (
            rst         => RST,      
            clk         => CLK,
            
            din         => rx_fifo_din_rs422,
            rd_en       => RX_BUF_RDEN_RS422,
            wr_en       => rx_fifo_wr_en_rs422,
            
            dout        => RX_BUF_DATA_RS422,
            full        => rx_fifo_full_rs422,
            empty       => RX_BUF_EMPTY_RS422
        );
           		
	uart_tx_i : entity work.UART_TX_RS422 
		port map 
		(
			clk 			=> CLK,
			rst 			=> RST,
			
			tx_out 			=> tx_out_rs422,
			
			clk_div_baud 	=> CLK_DIV_BAUD_RS422,
			
			tx_data 		=> tx_data_rs422,
			tx_data_valid 	=> tx_data_valid_rs422,
			tx_busy 		=> tx_busy_rs422
        );
        
	tx_data_rs422 <= tx_fifo_dout_rs422;
	tx_data_valid_rs422 <= tx_fifo_rden_rs422;
	tx_fifo_rden_rs422 <= (not tx_fifo_empty_rs422) and (not tx_busy_rs422);

    U1_TX_FIFO : UART_TX_FIFO_RS422
        PORT MAP 
        (
            rst         => RST,
            clk         => CLK,
            din         => TX_BUF_DATA_RS422,
            wr_en       => TX_BUF_WREN_RS422,
            rd_en       => tx_fifo_rden_RS422,
            dout        => tx_fifo_dout_RS422,
            full        => TX_BUF_FULL_RS422,
            empty       => tx_fifo_empty_rs422
        );
end Behavioral;
