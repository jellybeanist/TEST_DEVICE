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
u16 messageSize_u16=0;
u32 BaudRate,BaudRate_2,BaudRate_3;
int dataCounter,messageDataCounter,checkSum = 0;
int messageSize = 0;




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
				TX_BUF_DATA_DBG[0] = checkSum;
				TX_BUF_DATA_DBG[0] = messageDataCounter;
				TX_BUF_DATA_DBG[0] = messageSize;

					if((messageDataCounter == messageSize) && (checkSum == checkByte)) // CC = 204
					{
						TX_BUF_DATA_DBG[0] = 0xAF;
						// UART based.
						if (rxBuffer[2] == 0x00)
						{
							// UART enabled.
							if(rxBuffer[5] == 1)
							{
								BaudRate = (rxBuffer[6] << 24) + (rxBuffer[7] << 16) + (rxBuffer[8] << 8) + (rxBuffer[9]);
								CLK_DIV_BAUD_UART[0] = 100000000/BaudRate;
								CLK_DIV_BAUD_RS232[0] = 100000000/BaudRate_2;
								sleep(1);

								TX_BUF_DATA_UART[0] = 0xAA;
								TX_BUF_DATA_RS232[0] = 0xAA;
							}

							// RS232 enabled.
							if(rxBuffer[21] == 1)
							{
								BaudRate_2 = (rxBuffer[22] << 24) + (rxBuffer[23] << 16) + (rxBuffer[24] << 8) + (rxBuffer[25]);
								CLK_DIV_BAUD_RS232[0] = 100000000/BaudRate_2;
								sleep(1);

								TX_BUF_DATA_RS232[0] = 0xAB;
							}

							// RS422 enabled.
							if(rxBuffer[37] == 1)
							{
								BaudRate_3 = (rxBuffer[38] << 24) + (rxBuffer[39] << 16) + (rxBuffer[40] << 8) + (rxBuffer[41]);
								CLK_DIV_BAUD_RS422[0] = 100000000/BaudRate_3;
								sleep(1);

								TX_BUF_DATA_RS422[0] = 0xAC;
							}
						}
						
						else if (rxBuffer[2] == 0x01)
						{
							
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


