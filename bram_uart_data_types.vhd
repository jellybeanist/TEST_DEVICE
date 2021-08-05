LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE STD.TEXTIO.ALL;

package test_device_data_types is
    -- CPU -->> PL
    type CONTROL_REGISTERS is 
    record    
        
        -- DEBUG
        ext_interface_clk_div_baud_dbg          : std_logic_vector(31 downto 0);
        ext_interface_rx_buf_rden_dbg           : std_logic;
        ext_interface_tx_buf_wren_dbg           : std_logic;
        ext_interface_tx_buf_data_dbg           : std_logic_vector(7 downto 0);
        
        -- UART
        ext_interface_clk_div_baud_uart         : std_logic_vector(31 downto 0);
        ext_interface_rx_buf_rden_uart          : std_logic;
        ext_interface_tx_buf_wren_uart          : std_logic;
        ext_interface_tx_buf_data_uart          : std_logic_vector(7 downto 0);
        
        -- RS232  
        ext_interface_clk_div_baud_rs232        : std_logic_vector(31 downto 0);
        ext_interface_rx_buf_rden_rs232         : std_logic;
        ext_interface_tx_buf_wren_rs232         : std_logic;
        ext_interface_tx_buf_data_rs232         : std_logic_vector(7 downto 0);
        
        -- RS232  
        ext_interface_clk_div_baud_rs422        : std_logic_vector(31 downto 0);
        ext_interface_rx_buf_rden_rs422         : std_logic;
        ext_interface_tx_buf_wren_rs422         : std_logic;
        ext_interface_tx_buf_data_rs422         : std_logic_vector(7 downto 0);
        

    end record;
    -- PL -->> CPU    
    type STAT_REGISTERS is 
    record
        
        -- DEBUG
        ext_interface_rx_buf_empty_dbg          : std_logic;
        ext_interface_rx_buf_data_dbg           : std_logic_vector(7 downto 0);
        ext_interface_tx_buf_full_dbg           : std_logic;
        
        -- UART
        ext_interface_rx_buf_empty_uart         : std_logic;
        ext_interface_rx_buf_data_uart          : std_logic_vector(7 downto 0);
        ext_interface_tx_buf_full_uart          : std_logic;
        
        -- RS232
        ext_interface_rx_buf_empty_rs232        : std_logic;
        ext_interface_rx_buf_data_rs232         : std_logic_vector(7 downto 0);
        ext_interface_tx_buf_full_rs232         : std_logic;
        
        -- RS422
        ext_interface_rx_buf_empty_rs422        : std_logic;
        ext_interface_rx_buf_data_rs422         : std_logic_vector(7 downto 0);
        ext_interface_tx_buf_full_rs422         : std_logic;
        
    end record;
end test_device_data_types;

package body test_device_data_types is

end test_device_data_types;