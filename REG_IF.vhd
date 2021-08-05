library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;
LIBRARY WORK;
USE WORK.TEST_DEVICE_DATA_TYPES.ALL;

entity REG_IF is
    port 
    (
        --CLK AND RESET
        CLK                         : IN    STD_LOGIC;
        RST                         : IN    STD_LOGIC;
        
        --EXT REGISTER
        EXT_REG_IF_ADDR             : IN    STD_LOGIC_VECTOR(15 DOWNTO 0);
        EXT_REG_IF_WR_DATA          : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
        EXT_REG_IF_RD_DATA          : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
        EXT_REG_IF_EN               : IN    STD_LOGIC;  
        EXT_REG_IF_WR_EN            : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);  
                       
        CTRL_REGS                   : OUT   CONTROL_REGISTERS;
        STAT_REGS                   : IN    STAT_REGISTERS
    );
end REG_IF;

architecture Behavioral of REG_IF is
    
    signal ext_interface_rx_buf_rden_dbg         : std_logic;
    signal ext_interface_rx_buf_rden_dl_dbg      : std_logic;
    signal ext_interface_tx_buf_wren_dbg         : std_logic;
    signal ext_interface_tx_buf_wren_dl_dbg      : std_logic;
    
    signal ext_interface_rx_buf_rden_uart        : std_logic;
    signal ext_interface_rx_buf_rden_dl_uart     : std_logic;
    signal ext_interface_tx_buf_wren_uart        : std_logic;
    signal ext_interface_tx_buf_wren_dl_uart     : std_logic;
    
    signal ext_interface_rx_buf_rden_rs232       : std_logic;
    signal ext_interface_rx_buf_rden_dl_rs232    : std_logic;
    signal ext_interface_tx_buf_wren_rs232       : std_logic;
    signal ext_interface_tx_buf_wren_dl_rs232    : std_logic;
    
    signal ext_interface_rx_buf_rden_rs422       : std_logic;
    signal ext_interface_rx_buf_rden_dl_rs422    : std_logic;
    signal ext_interface_tx_buf_wren_rs422       : std_logic;
    signal ext_interface_tx_buf_wren_dl_rs422    : std_logic;
        
begin

    write_registers_p : process (CLK)
    begin
        if rising_edge(CLK) then
            -- DEBUG
            ext_interface_tx_buf_wren_dbg               <= '0';
            ext_interface_tx_buf_wren_dl_dbg            <= ext_interface_tx_buf_wren_dbg;
            CTRL_REGS.ext_interface_tx_buf_wren_dbg     <= ext_interface_tx_buf_wren_dbg and (not ext_interface_tx_buf_wren_dl_dbg);
            
            -- UART
            ext_interface_tx_buf_wren_uart              <= '0';
            ext_interface_tx_buf_wren_dl_uart           <= ext_interface_tx_buf_wren_uart;
            CTRL_REGS.ext_interface_tx_buf_wren_uart    <= ext_interface_tx_buf_wren_uart and (not ext_interface_tx_buf_wren_dl_uart);
            
            -- RS232
            ext_interface_tx_buf_wren_rs232             <= '0';
            ext_interface_tx_buf_wren_dl_rs232          <= ext_interface_tx_buf_wren_rs232;
            CTRL_REGS.ext_interface_tx_buf_wren_rs232   <= ext_interface_tx_buf_wren_rs232 and (not ext_interface_tx_buf_wren_dl_rs232);
            
            -- RS422
            ext_interface_tx_buf_wren_rs422             <= '0';
            ext_interface_tx_buf_wren_dl_rs422          <= ext_interface_tx_buf_wren_rs422;
            CTRL_REGS.ext_interface_tx_buf_wren_rs422   <= ext_interface_tx_buf_wren_rs422 and (not ext_interface_tx_buf_wren_dl_rs422);
            
            if (EXT_REG_IF_EN = '1' and EXT_REG_IF_WR_EN = "1111") then
                case EXT_REG_IF_ADDR(13 downto 2) is
                    
                    -- DEBUG
                    when x"000" => CTRL_REGS.ext_interface_clk_div_baud_dbg             <= EXT_REG_IF_WR_DATA;
                    when x"001" => CTRL_REGS.ext_interface_tx_buf_data_dbg              <= EXT_REG_IF_WR_DATA(CTRL_REGS.ext_interface_tx_buf_data_dbg'range);
                                   ext_interface_tx_buf_wren_dbg                        <= '1';
                    
                    -- UART               
                    when x"002" => CTRL_REGS.ext_interface_clk_div_baud_uart            <= EXT_REG_IF_WR_DATA;
                    when x"003" => CTRL_REGS.ext_interface_tx_buf_data_uart             <= EXT_REG_IF_WR_DATA(CTRL_REGS.ext_interface_tx_buf_data_uart'range);
                                   ext_interface_tx_buf_wren_uart                       <= '1';
                                   
                    -- RS232
                    when x"004" => CTRL_REGS.ext_interface_clk_div_baud_rs232           <= EXT_REG_IF_WR_DATA;
                    when x"005" => CTRL_REGS.ext_interface_tx_buf_data_rs232            <= EXT_REG_IF_WR_DATA(CTRL_REGS.ext_interface_tx_buf_data_rs232'range);
                    ext_interface_tx_buf_wren_rs232                                     <= '1';
                                   
                    -- RS422               
                    when x"006" => CTRL_REGS.ext_interface_clk_div_baud_rs422           <= EXT_REG_IF_WR_DATA;
                    when x"007" => CTRL_REGS.ext_interface_tx_buf_data_rs422            <= EXT_REG_IF_WR_DATA(CTRL_REGS.ext_interface_tx_buf_data_rs422'range);
                    ext_interface_tx_buf_wren_rs422                                     <= '1';
                                   
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    read_registers_p : process (CLK)
    begin
        if rising_edge(CLK) then
            -- DEBUG
            ext_interface_rx_buf_rden_dbg                <= '0';
            ext_interface_rx_buf_rden_dl_dbg             <= ext_interface_rx_buf_rden_dbg;
            CTRL_REGS.ext_interface_rx_buf_rden_dbg      <= ext_interface_rx_buf_rden_dbg and (not ext_interface_rx_buf_rden_dl_dbg);
            
            -- UART
            ext_interface_rx_buf_rden_uart               <= '0';
            ext_interface_rx_buf_rden_dl_uart            <= ext_interface_rx_buf_rden_uart;
            CTRL_REGS.ext_interface_rx_buf_rden_uart     <= ext_interface_rx_buf_rden_uart and (not ext_interface_rx_buf_rden_dl_uart);
            
            -- RS232
            ext_interface_rx_buf_rden_rs232              <= '0';
            ext_interface_rx_buf_rden_dl_rs232           <= ext_interface_rx_buf_rden_rs232;
            CTRL_REGS.ext_interface_rx_buf_rden_rs232    <= ext_interface_rx_buf_rden_rs232 and (not ext_interface_rx_buf_rden_dl_rs232);
            
            -- RS422
            ext_interface_rx_buf_rden_rs422              <= '0';
            ext_interface_rx_buf_rden_dl_rs422           <= ext_interface_rx_buf_rden_rs422;
            CTRL_REGS.ext_interface_rx_buf_rden_rs422    <= ext_interface_rx_buf_rden_rs422 and (not ext_interface_rx_buf_rden_dl_rs422);
                        
            if (EXT_REG_IF_EN = '1' and EXT_REG_IF_WR_EN = "0000") then
                EXT_REG_IF_RD_DATA <= (others => '0');
                case EXT_REG_IF_ADDR(13 downto 2) is
                
                    -- DEBUG
                    when x"800" => EXT_REG_IF_RD_DATA(0)                                                <= STAT_REGS.ext_interface_rx_buf_empty_dbg;
                    when x"801" => EXT_REG_IF_RD_DATA(STAT_REGS.ext_interface_rx_buf_data_dbg'range)    <= STAT_REGS.ext_interface_rx_buf_data_dbg;
                                   ext_interface_rx_buf_rden_dbg <= '1';
                    when x"802" => EXT_REG_IF_RD_DATA(0)                                                <= STAT_REGS.ext_interface_tx_buf_full_dbg;
                    
                    -- UART                               
                    when x"803" => EXT_REG_IF_RD_DATA(0)                                                <= STAT_REGS.ext_interface_rx_buf_empty_uart;
                    when x"804" => EXT_REG_IF_RD_DATA(STAT_REGS.ext_interface_rx_buf_data_uart'range)   <= STAT_REGS.ext_interface_rx_buf_data_uart;
                                   ext_interface_rx_buf_rden_uart <= '1';
                    when x"805" => EXT_REG_IF_RD_DATA(0)                                                <= STAT_REGS.ext_interface_tx_buf_full_uart;   
                            
                    -- RS232
                    when x"806" => EXT_REG_IF_RD_DATA(0)                                                <= STAT_REGS.ext_interface_rx_buf_empty_rs232;
                    when x"807" => EXT_REG_IF_RD_DATA(STAT_REGS.ext_interface_rx_buf_data_rs232'range)  <= STAT_REGS.ext_interface_rx_buf_data_rs232;
                                   ext_interface_rx_buf_rden_rs232 <= '1';
                    when x"808" => EXT_REG_IF_RD_DATA(0)                                                <= STAT_REGS.ext_interface_tx_buf_full_rs232;
                    
                    -- RS422                               
                    when x"809" => EXT_REG_IF_RD_DATA(0)                                                <= STAT_REGS.ext_interface_rx_buf_empty_rs422;
                    when x"810" => EXT_REG_IF_RD_DATA(STAT_REGS.ext_interface_rx_buf_data_rs422'range)  <= STAT_REGS.ext_interface_rx_buf_data_rs422;
                                   ext_interface_rx_buf_rden_rs422 <= '1';
                    when x"811" => EXT_REG_IF_RD_DATA(0)                                                <= STAT_REGS.ext_interface_tx_buf_full_rs422;
                    
                    when others => null; 
                end case;
            end if;
        end if;
    end process;

end Behavioral;