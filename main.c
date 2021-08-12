#include "main.h"
#include "xiic.h"
#include "stdio.h"
#include "stdlib.h"
#include <sleep.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdbool.h>
// device slave addr, r/w,

u8 rxBuffer[10000];
u8 checkByte = 0xEE;
u8 IIC_devAddr;
u8 IIC_regAddr;
u8 IIC_data0;
u8 IIC_data1;
u8 IIC_receivedData;
u16 messageSize_u16=0;
u32 BaudRate_UART,BaudRate_RS232,BaudRate_RS422;
int dataCounter,messageDataCounter,checkSum = 0;
int messageSize = 0;


XStatus IIC_MCP4725_Write(u8 devAddr, u8 regAddr, u8 data0, u8 data1)
{
	u8 wrData[3];

	wrData[0] = regAddr;
	wrData[1] = data0;
	wrData[2] = data1;

	/* register write single byte */
	if(XIic_Send(I2C_DEVICE_BASE_ADDR, devAddr, wrData, sizeof(wrData), XIIC_STOP) != sizeof(wrData))
	{
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}


XStatus IIC_MCP4725_Read(u8 deviceAddr, u8 regAddr, u8* dataPtr, u8 dataCount)
{
	/* register select */
	if(XIic_Send(I2C_DEVICE_BASE_ADDR, deviceAddr, &regAddr, 2, XIIC_STOP) != 1)
	{
		return XST_FAILURE;
	}
	/* register read */
	if(XIic_Recv(I2C_DEVICE_BASE_ADDR, deviceAddr, dataPtr, dataCount, XIIC_STOP) != dataCount)
	{
		return XST_FAILURE;
	}
	return XST_SUCCESS;
}



int main(void)
{
	CLK_DIV_BAUD_DBG[0]   	= 100000000/115200;
	//CLK_DIV_BAUD_UART[0]   	= 100000000/115200;
	sleep(1);

	// HEADER: 	5 bytes. => 2 bytes initial + 1 byte protocol select + 2 bytes protocol message size.
	// Protocol selection: 00 for UART, 01 for RS232, 02 for RS422, 03 for IIC, 04 for SPI.

	// UART: 	16 bytes. => 1 byte enable + 4 bytes Baud Rate + 1 byte UART message size + 10 bytes UART message.
	// RS232: 	16 bytes. => 1 byte enable + 4 bytes Baud Rate + 1 byte UART message size + 10 bytes UART message.
	// RS422: 	16 bytes. => 1 byte enable + 4 bytes Baud Rate + 1 byte UART message size + 10 bytes UART message.

	// IIC:

	// SPI:


	//IIC_MCP4725_Write(0x40,0x0F,0x00);
	//if (IIC_QMC5883_Read(0x00, datas, 8) == XST_FAILURE)
	while (1)
	{

		if(RX_BUF_EMPTY_UART[0] == 0)
		{
			//TX_BUF_DATA_DBG[0] = 0x00;
			TX_BUF_DATA_DBG[0] = RX_BUF_DATA_UART[0];
		}

		if(RX_BUF_EMPTY_DBG[0] == 0)
		{
			if (dataCounter == 0 && RX_BUF_DATA_DBG[0] == 0x55)
			{
				rxBuffer[dataCounter] = RX_BUF_DATA_DBG[0];
				dataCounter++;
			}
			else if (dataCounter == 1 && RX_BUF_DATA_DBG[0] == 0xAA)
			{
				rxBuffer[dataCounter] = RX_BUF_DATA_DBG[0];
				dataCounter++;
			}
			else if (dataCounter == 2 && (RX_BUF_DATA_DBG[0] == 0x00 || RX_BUF_DATA_DBG[0] == 0x01 || RX_BUF_DATA_DBG[0] == 0x02))
			{
				rxBuffer[dataCounter] = RX_BUF_DATA_DBG[0];
				dataCounter++;
			}
			else if (dataCounter > 2 && dataCounter <= 4)
			{
				rxBuffer[dataCounter] = RX_BUF_DATA_DBG[0];
				messageSize = (int)(16*rxBuffer[3] + rxBuffer[4]);
				dataCounter++;
			}
			else if (5 <= dataCounter && (messageDataCounter <= messageSize))
			{

				rxBuffer[dataCounter] = RX_BUF_DATA_DBG[0];
				checkSum = (checkSum + rxBuffer[dataCounter])%256;
				//TX_BUF_DATA_DBG[0] = rxBuffer[dataCounter];
				//TX_BUF_DATA_DBG[0] = checkSum;
				//TX_BUF_DATA_DBG[0] = messageDataCounter;
				//TX_BUF_DATA_DBG[0] = messageSize;

					if((messageDataCounter == messageSize) && (checkSum == checkByte)) // checkSum == EE
					{
						// UART based.
						if (rxBuffer[2] == 0x00)
						{
							// UART enabled.
							if(rxBuffer[5] == 1)
							{
								BaudRate_UART = (rxBuffer[6] << 24) + (rxBuffer[7] << 16) + (rxBuffer[8] << 8) + (rxBuffer[9]);
								CLK_DIV_BAUD_UART[0] = 100000000/BaudRate_UART;
								sleep(1);
								TX_BUF_DATA_UART[0] = 0xAA;
							}

							// RS232 enabled.
							if(rxBuffer[21] == 1)
							{
								BaudRate_RS232 = (rxBuffer[22] << 24) + (rxBuffer[23] << 16) + (rxBuffer[24] << 8) + (rxBuffer[25]);
								CLK_DIV_BAUD_RS232[0] = 100000000/BaudRate_RS232;
								sleep(1);
								TX_BUF_DATA_RS232[0] = 0xAB;
							}

							// RS422 enabled.
							if(rxBuffer[37] == 1)
							{
								BaudRate_RS422 = (rxBuffer[38] << 24) + (rxBuffer[39] << 16) + (rxBuffer[40] << 8) + (rxBuffer[41]);
								CLK_DIV_BAUD_RS422[0] = 100000000/BaudRate_RS422;
								sleep(1);
								TX_BUF_DATA_RS422[0] = 0xAC;
							}
						}

						// IIC
						else if (rxBuffer[2] == 0x01)
						{
							if(rxBuffer[5] == 0x00) // Read Mode => rxBuffer[2] == 0
							{


							}

							if(rxBuffer[5] == 0x01) // Write Mode => rxBuffer[2] == 1
							{
								IIC_devAddr = rxBuffer[6];
								IIC_regAddr = rxBuffer[7];
								IIC_data0 = rxBuffer[8];
								IIC_data1 = rxBuffer[9];

								//TX_BUF_DATA_DBG[0] = IIC_devAddr;
								//TX_BUF_DATA_DBG[0] = IIC_regAddr;
								//TX_BUF_DATA_DBG[0] = IIC_data0;
								//TX_BUF_DATA_DBG[0] = IIC_data1;
								IIC_MCP4725_Write(IIC_devAddr, IIC_regAddr, IIC_data0, IIC_data1);
								//sleep(10);
							}
						}


						/*
						// SPI
						if (rxBuffer[2] == 0x02)
						{

						}
						*/
					}

					else
					{
						dataCounter++;
						messageDataCounter++;
					}


			}
			else
			{
				for (int i=0; i<messageSize; i++)
				{
					rxBuffer[i] = 0;
				}
				dataCounter = 0;
				messageDataCounter = 0;
				checkSum = 0;
			}
		}



/*
		if(RX_BUF_EMPTY_RS232[0] == 0)
		{
			TX_BUF_DATA_DBG[0] = RX_BUF_DATA_RS232[0];
		}

		if(RX_BUF_EMPTY_RS422[0] == 0)
		{
			TX_BUF_DATA_DBG[0] = RX_BUF_DATA_RS422[0];
		}
*/

	}
	return 0;
}





/*

if(RX_BUF_EMPTY[0] == 0)
{
	//TX_BUF_DATA[0] = rxdata;
	//TX_BUF_DATA[0] = RX_BUF_DATA[0];

	if(data_counter == 0 && rxdata == 0xAA)
	{
		header_specs[data_counter] = rxdata;
		data_counter = data_counter + 1;
		//TX_BUF_DATA[0] = header_specs[0];
	}

	else if(data_counter == 1 && header_specs[0] == 0xAA)
	{
		header_specs[data_counter] = rxdata;
		data_counter = data_counter + 1;
		//TX_BUF_DATA[0] = header_specs[1];
	}

	else if (header_specs[0] == 0xAA && header_specs[1] == 0x55 && data_counter < 8)
	{
		header_specs[data_counter] = rxdata;
		data_counter = data_counter + 1;

		if(data_counter == 8)
		{
			//TX_BUF_DATA[0] = header_specs[0];
			//TX_BUF_DATA[0] = header_specs[1];
			//TX_BUF_DATA[0] = header_specs[2];
			//TX_BUF_DATA[0] = header_specs[3];
			//TX_BUF_DATA[0] = header_specs[4];
			//TX_BUF_DATA[0] = header_specs[5];
			//TX_BUF_DATA[0] = header_specs[6];
			TX_BUF_DATA[0] = header_specs[7];
			data_counter = 0;
		}
	}

	else//control statement, will not be used later.
		TX_BUF_DATA[0] = 0xBC;

}
else
{
		//TX_BUF_DATA[0] = 0xCB;
}

*/

		/*if ([0] == 1)
				CLK_DIV_BAUD_U0[0] = 100000000/1,2,3,4;
				sleep(1);
				TX_BUF_DATA_U0[0] = 5;
		if([6] == 1)
				CLK_DIV_BAUD_U1[0] = 100000000/7,8,9,10;
				sleep(1);
				TX_BUF_DATA_U1[0] = 11;
				*/

