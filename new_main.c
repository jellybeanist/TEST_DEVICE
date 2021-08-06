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
u16 messageSize_u16=0;
int dataCounter,messageDataCounter = 0;
int messageSize = 0;




int main(void)
{
	CLK_DIV_BAUD_DBG[0]   	= 100000000/115200;
	CLK_DIV_BAUD_UART[0]   	= 100000000/115200;
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
			else if (dataCounter <= 5 && (messageDataCounter <= messageSize))
			{
				TX_BUF_DATA_DBG[0] = rxBuffer[3];
				TX_BUF_DATA_DBG[0] = rxBuffer[4];
				messageSize = (16*rxBuffer[3] + rxBuffer[4]);
				TX_BUF_DATA_DBG[0] = messageSize;
				//messageSize_u16 = (messageSize_u16 << 8) + rxBuffer[4];
				//messageSize = (int)(messageSize_u16);

				rxBuffer[dataCounter] = RX_BUF_DATA_DBG[0];
				dataCounter++;
				messageDataCounter++;
			}
			else
			{
				//TX_BUF_DATA_DBG[0] = messageSize;
			}
		}
		/*if (dataCounter == 5)
		{
			for (int i=0; i<5; i++)
			{

			}
			dataCounter = 0;
		}*/
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

