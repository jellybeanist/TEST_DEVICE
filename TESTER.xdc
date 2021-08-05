# Clock signal
set_property PACKAGE_PIN W5 [get_ports CLK_100]							
	set_property IOSTANDARD LVCMOS33 [get_ports CLK_100]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK_100]

#Buttons
set_property PACKAGE_PIN U18 [get_ports RST]                        
    set_property IOSTANDARD LVCMOS33 [get_ports RST]
	
#USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports UART_RX_IN_DBG]                        
    set_property IOSTANDARD LVCMOS33 [get_ports UART_RX_IN_DBG]
set_property PACKAGE_PIN A18 [get_ports UART_TX_OUT_DBG]                        
    set_property IOSTANDARD LVCMOS33 [get_ports UART_TX_OUT_DBG]
    

#Pmod Header JA

#JA1 for UART_RX_IN
    #Sch name = JA1
    set_property PACKAGE_PIN J1 [get_ports {UART_RX_IN}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {UART_RX_IN}]

#JA2 for UART_TX_OUT        
    ##Sch name = JA2
    set_property PACKAGE_PIN L2 [get_ports {UART_TX_OUT}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {UART_TX_OUT}]
        
#JA1 for UART_RX_IN
    #Sch name = JA3
    set_property PACKAGE_PIN J2 [get_ports {UART_RX_IN_RS232}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {UART_RX_IN_RS232}]
     
#JA2 for UART_TX_OUT        
    ##Sch name = JA4
    set_property PACKAGE_PIN G2 [get_ports {UART_TX_OUT_RS232}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {UART_TX_OUT_RS232}]
             
#JA1 for UART_RX_IN
    #Sch name = JA7
    set_property PACKAGE_PIN H1 [get_ports {UART_RX_IN_RS422}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {UART_RX_IN_RS422}]
          
#JA2 for UART_TX_OUT        
  ##Sch name = JA8
    set_property PACKAGE_PIN K2 [get_ports {UART_TX_OUT_RS422}]                    
          set_property IOSTANDARD LVCMOS33 [get_ports {UART_TX_OUT_RS422}]
    
#Pmod Header JB
    #Sch name = JB1
    set_property PACKAGE_PIN A14 [get_ports {IIC_SDA}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {IIC_SDA}]
    #Sch name = JB7
    set_property PACKAGE_PIN A15 [get_ports {IIC_SCL}]                    
        set_property IOSTANDARD LVCMOS33 [get_ports {IIC_SCL}]