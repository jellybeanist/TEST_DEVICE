library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TRX_DBG is
	port
	(
		CLK				    : IN	STD_LOGIC;
		RST				    : IN	STD_LOGIC;
		
		CLK_DIV_BAUD_DBG	: IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
		
		TX_OUT_DBG		    : OUT	STD_LOGIC;
		RX_IN_DBG		    : IN	STD_LOGIC;
		
		RX_BUF_EMPTY_DBG	: OUT	STD_LOGIC;
		RX_BUF_RDEN_DBG		: IN	STD_LOGIC;
		RX_BUF_DATA_DBG		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
        		
		TX_BUF_FULL_DBG		: OUT  	STD_LOGIC;
		TX_BUF_WREN_DBG		: IN  	STD_LOGIC;
		TX_BUF_DATA_DBG		: IN	STD_LOGIC_VECTOR(7 DOWNTO 0)		
	);
end UART_TRX_DBG;

architecture Behavioral of UART_TRX_DBG is

	signal rx_fifo_full_dbg			: std_logic := '0';
	signal rx_fifo_wr_en_dbg		: std_logic := '0';
	signal rx_fifo_din_dbg			: std_logic_vector(7 downto 0) := (others=>'0');
	signal rx_data_dbg			    : std_logic_vector(7 downto 0) := (others=>'0');
	signal rx_data_valid_dbg		: std_logic := '0';
	
	signal tx_data_dbg			    : std_logic_vector(7 downto 0) := (others=>'0');
	signal tx_data_valid_dbg		: std_logic := '0';
	signal tx_busy_dbg				: std_logic := '0';
	signal tx_fifo_rden_dbg			: std_logic := '0';
	signal tx_fifo_empty_dbg		: std_logic := '0';
	signal tx_fifo_dout_dbg			: std_logic_vector(7 downto 0) := (others=>'0');

    COMPONENT UART_RX_FIFO_DBG
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
       end component UART_RX_FIFO_DBG;
       
    COMPONENT UART_TX_FIFO_DBG
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
 end component UART_TX_FIFO_DBG;
 
begin

	uart_rx_i : entity work.UART_RX_DBG 
		port map
		(
			CLK 			=> CLK,
			rst			 	=> RST,
			
			rx_in 			=> rx_in_dbg,
			
			clk_div_baud 	=> CLK_DIV_BAUD_DBG,
			
			rx_data 		=> rx_data_dbg,
			rx_data_valid 	=> rx_data_valid_dbg,
			rx_err 			=> open
		);

	rx_fifo_wr_en_dbg <= rx_data_valid_dbg and (not rx_fifo_full_dbg);
	rx_fifo_din_dbg <= rx_data_dbg; 
	
	U0_RX_FIFO : UART_RX_FIFO_DBG
        PORT MAP 
        (
            rst         => RST,      
            clk         => CLK,
            
            din         => rx_fifo_din_dbg,
            rd_en       => RX_BUF_RDEN_DBG,
            wr_en       => rx_fifo_wr_en_dbg,
            
            dout        => RX_BUF_DATA_DBG,
            full        => rx_fifo_full_dbg,
            empty       => RX_BUF_EMPTY_DBG
        );
           		
	uart_tx_i : entity work.UART_TX_DBG 
		port map 
		(
			clk 			=> CLK,
			rst 			=> RST,
			
			tx_out 			=> tx_out_dbg,
			
			clk_div_baud 	=> CLK_DIV_BAUD_DBG,
			
			tx_data 		=> tx_data_dbg,
			tx_data_valid 	=> tx_data_valid_dbg,
			tx_busy 		=> tx_busy_dbg
        );
        
	tx_data_dbg <= tx_fifo_dout_dbg;
	tx_data_valid_dbg <= tx_fifo_rden_dbg;
	tx_fifo_rden_dbg <= (not tx_fifo_empty_dbg) and (not tx_busy_dbg);

    U1_TX_FIFO : UART_TX_FIFO_DBG
        PORT MAP 
        (
            rst         => RST,
            clk         => CLK,
            din         => TX_BUF_DATA_DBG,
            wr_en       => TX_BUF_WREN_DBG,
            rd_en       => tx_fifo_rden_dbg,
            dout        => tx_fifo_dout_dbg,
            full        => TX_BUF_FULL_DBG,
            empty       => tx_fifo_empty_dbg
        );
end Behavioral;
