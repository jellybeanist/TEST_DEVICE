library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TRX is
	port
	(
		CLK                   : IN	STD_LOGIC;
		RST                   : IN	STD_LOGIC;
		
		CLK_DIV_BAUD_UART     : IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		
        TX_OUT_UART           : OUT	STD_LOGIC;
		RX_IN_UART            : IN	STD_LOGIC;
	
		RX_BUF_EMPTY_UART     : OUT	STD_LOGIC;
		RX_BUF_RDEN_UART      : IN	STD_LOGIC;
		RX_BUF_DATA_UART      : OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
        	
		TX_BUF_FULL_UART      : OUT  	STD_LOGIC;
		TX_BUF_WREN_UART      : IN  	STD_LOGIC;
		TX_BUF_DATA_UART      : IN	STD_LOGIC_VECTOR(7 DOWNTO 0)		
	);
end UART_TRX;

architecture Behavioral of UART_TRX is

	signal rx_fifo_full_uart		: std_logic := '0';
	signal rx_fifo_wr_en_uart		: std_logic := '0';
	signal rx_fifo_din_uart			: std_logic_vector(7 downto 0) := (others=>'0');
	signal rx_data_uart				: std_logic_vector(7 downto 0) := (others=>'0');
	signal rx_data_valid_uart		: std_logic := '0';
	
	signal tx_data_uart				: std_logic_vector(7 downto 0) := (others=>'0');
	signal tx_data_valid_uart		: std_logic := '0';
	signal tx_busy_uart				: std_logic := '0';
	signal tx_fifo_rden_uart		: std_logic := '0';
	signal tx_fifo_empty_uart		: std_logic := '0';
	signal tx_fifo_dout_uart		: std_logic_vector(7 downto 0) := (others=>'0');

    COMPONENT RX_FIFO
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
       end component RX_FIFO;
       
    COMPONENT TX_FIFO
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
 end component TX_FIFO;
 
begin

	uart_rx_i : entity work.UART_RX 
		port map
		(
			CLK 			=> CLK,
			rst			 	=> RST,
			
			rx_in 			=> rx_in_uart,
			
			clk_div_baud 	=> CLK_DIV_BAUD_UART,
			
			rx_data 		=> rx_data_uart,
			rx_data_valid 	=> rx_data_valid_uart,
			rx_err 			=> open
		);

	rx_fifo_wr_en_uart <= rx_data_valid_uart and (not rx_fifo_full_uart);
	rx_fifo_din_uart <= rx_data_uart; 
	
	U0_RX_FIFO : RX_FIFO
        PORT MAP 
        (
            rst         => RST,      
            clk         => CLK,
            
            din         => rx_fifo_din_uart,
            rd_en       => RX_BUF_RDEN_UART,
            wr_en       => rx_fifo_wr_en_uart,
            
            dout        => RX_BUF_DATA_UART,
            full        => rx_fifo_full_uart,
            empty       => RX_BUF_EMPTY_UART
        );
           		
	uart_tx_i : entity work.UART_TX 
		port map 
		(
			clk 			=> CLK,
			rst 			=> RST,
			
			tx_out 			=> tx_out_uart,
			
			clk_div_baud 	=> CLK_DIV_BAUD_UART,
			
			tx_data 		=> tx_data_uart,
			tx_data_valid 	=> tx_data_valid_uart,
			tx_busy 		=> tx_busy_uart
        );
        
	tx_data_uart <= tx_fifo_dout_uart;
	tx_data_valid_uart <= tx_fifo_rden_uart;
	tx_fifo_rden_uart <= (not tx_fifo_empty_uart) and (not tx_busy_uart);

    U1_TX_FIFO : TX_FIFO
        PORT MAP 
        (
            rst         => RST,
            clk         => CLK,
            din         => TX_BUF_DATA_UART,
            wr_en       => TX_BUF_WREN_UART,
            rd_en       => tx_fifo_rden_UART,
            dout        => tx_fifo_dout_UART,
            full        => TX_BUF_FULL_UART,
            empty       => tx_fifo_empty_UART
        );
end Behavioral;
