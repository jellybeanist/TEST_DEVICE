library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY WORK;
USE WORK.TEST_DEVICE_DATA_TYPES.ALL;

entity TOP is
    Port 
    ( 
        CLK_100             : IN STD_LOGIC;
        RST                 : IN STD_LOGIC;
        
        IIC_SDA             : INOUT STD_LOGIC;
        IIC_SCL             : INOUT STD_LOGIC;
                
        UART_TX_OUT_DBG     : OUT STD_LOGIC;
        UART_RX_IN_DBG      : IN STD_LOGIC;
        
        UART_TX_OUT         : OUT STD_LOGIC;
        UART_RX_IN          : IN STD_LOGIC;
        
        UART_TX_OUT_RS232   : OUT STD_LOGIC;
        UART_RX_IN_RS232    : IN STD_LOGIC;
        
        UART_TX_OUT_RS422   : OUT STD_LOGIC;
        UART_RX_IN_RS422    : IN STD_LOGIC
        
    );
end TOP;


architecture Behavioral of TOP is
    
    signal i_rst                : std_logic := '1';
    signal i_rst_n              : std_logic := '0'; 
    signal alive_counter        : std_logic_vector(31 downto 0) := (others => '0');
    
    signal reg_if_addr          : std_logic_vector(15 downto 0);
    signal reg_if_wr_data       : std_logic_vector(31 downto 0);
    signal reg_if_rd_data       : std_logic_vector(31 downto 0);
    signal reg_if_en            : std_logic;
    signal reg_if_wr_en         : std_logic_vector(3 downto 0);
    
    signal CTRL_REGS            : CONTROL_REGISTERS;
    signal STAT_REGS            : STAT_REGISTERS;
    
begin
    
    i_rst_n <= not i_rst;

    P1: process (CLK_100) begin
        if rising_edge(CLK_100) then
            if (RST = '0') then
                if (alive_counter = 100_000) then
                    alive_counter <= (others => '0');
                    i_rst <= '0';
                else
                    alive_counter <= alive_counter + 1;
                end if;
            else
                alive_counter <= (others => '0');
                i_rst <= '1';
            end if;
        end if;
    end process;
        
        
    U1: entity work.BD_wrapper
        port map
        (
            CLK_100             => CLK_100,
            RESET_N             => i_rst_n,
            
            IIC_scl_io          => IIC_SCL,
            IIC_sda_io          => IIC_SDA,
            
            REG_IF_addr         => reg_if_addr,
            REG_IF_clk          => open,
            REG_IF_din          => reg_if_wr_data,
            REG_IF_dout         => reg_if_rd_data,
            REG_IF_en           => reg_if_en,
            REG_IF_rst          => open,
            REG_IF_we           => reg_if_wr_en
            
        );
    
    U2: entity work.REG_IF
        port map
        (
            CLK                 =>  CLK_100,                   
            RST                 =>  i_rst,               
            
            EXT_REG_IF_ADDR     =>  reg_if_addr,        
            EXT_REG_IF_WR_DATA  =>  reg_if_wr_data,         
            EXT_REG_IF_RD_DATA  =>  reg_if_rd_data,          
            EXT_REG_IF_EN       =>  reg_if_en,        
            EXT_REG_IF_WR_EN    =>  reg_if_wr_en,  
                               
            CTRL_REGS           =>  CTRL_REGS,  
            STAT_REGS           =>  STAT_REGS                 
        );
    
    U3: entity work.UART_TRX_DBG
        port map 
        (
        
            CLK                 =>    CLK_100,
            RST                 =>    i_rst,
            
            CLK_DIV_BAUD_DBG    =>    CTRL_REGS.ext_interface_clk_div_baud_dbg,
            
            RX_IN_DBG           =>    UART_RX_IN_DBG,
            TX_OUT_DBG          =>    UART_TX_OUT_DBG,
     
            RX_BUF_EMPTY_DBG    =>    STAT_REGS.ext_interface_rx_buf_empty_dbg,
            RX_BUF_DATA_DBG     =>    STAT_REGS.ext_interface_rx_buf_data_dbg,
            RX_BUF_RDEN_DBG     =>    CTRL_REGS.ext_interface_rx_buf_rden_dbg,
     
            TX_BUF_DATA_DBG     =>    CTRL_REGS.ext_interface_tx_buf_data_dbg,
            TX_BUF_WREN_DBG     =>    CTRL_REGS.ext_interface_tx_buf_wren_dbg,
            TX_BUF_FULL_DBG     =>    STAT_REGS.ext_interface_tx_buf_full_dbg
        );
        
    U4: entity work.UART_TRX
            port map 
            (
            
            CLK                 =>    CLK_100,
            RST                 =>    i_rst,
            
            CLK_DIV_BAUD_UART   =>    CTRL_REGS.ext_interface_clk_div_baud_uart,
            
            RX_IN_UART          =>    UART_RX_IN,
            TX_OUT_UART         =>    UART_TX_OUT,
      
            RX_BUF_EMPTY_UART   =>    STAT_REGS.ext_interface_rx_buf_empty_uart,
            RX_BUF_DATA_UART    =>    STAT_REGS.ext_interface_rx_buf_data_uart,
            RX_BUF_RDEN_UART    =>    CTRL_REGS.ext_interface_rx_buf_rden_uart,
      
            TX_BUF_DATA_UART    =>    CTRL_REGS.ext_interface_tx_buf_data_uart,
            TX_BUF_WREN_UART    =>    CTRL_REGS.ext_interface_tx_buf_wren_uart,
            TX_BUF_FULL_UART    =>    STAT_REGS.ext_interface_tx_buf_full_uart
            );

    U5: entity work.UART_TRX_RS232
            port map 
            (
            
            CLK                 =>    CLK_100,
            RST                 =>    i_rst,
            
            CLK_DIV_BAUD_RS232  =>    CTRL_REGS.ext_interface_clk_div_baud_rs232,
            
            RX_IN_RS232         =>    UART_RX_IN_RS232,
            TX_OUT_RS232        =>    UART_TX_OUT_RS232,
      
            RX_BUF_EMPTY_RS232  =>    STAT_REGS.ext_interface_rx_buf_empty_rs232,
            RX_BUF_DATA_RS232   =>    STAT_REGS.ext_interface_rx_buf_data_rs232,
            RX_BUF_RDEN_RS232   =>    CTRL_REGS.ext_interface_rx_buf_rden_rs232,
      
            TX_BUF_DATA_RS232   =>    CTRL_REGS.ext_interface_tx_buf_data_rs232,
            TX_BUF_WREN_RS232   =>    CTRL_REGS.ext_interface_tx_buf_wren_rs232,
            TX_BUF_FULL_RS232   =>    STAT_REGS.ext_interface_tx_buf_full_rs232
            );
            
    U6: entity work.UART_TRX_RS422
                    port map 
                    (
                    
            CLK                 =>    CLK_100,
            RST                 =>    i_rst,
            
            CLK_DIV_BAUD_RS422  =>    CTRL_REGS.ext_interface_clk_div_baud_rs422,
            
            RX_IN_RS422         =>    UART_RX_IN_RS422,
            TX_OUT_RS422        =>    UART_TX_OUT_RS422,
            
            RX_BUF_EMPTY_RS422  =>    STAT_REGS.ext_interface_rx_buf_empty_rs422,
            RX_BUF_DATA_RS422   =>    STAT_REGS.ext_interface_rx_buf_data_rs422,
            RX_BUF_RDEN_RS422   =>    CTRL_REGS.ext_interface_rx_buf_rden_rs422,
            
            TX_BUF_DATA_RS422   =>    CTRL_REGS.ext_interface_tx_buf_data_rs422,
            TX_BUF_WREN_RS422   =>    CTRL_REGS.ext_interface_tx_buf_wren_rs422,
            TX_BUF_FULL_RS422   =>    STAT_REGS.ext_interface_tx_buf_full_rs422
                    );
    
    
end Behavioral;
