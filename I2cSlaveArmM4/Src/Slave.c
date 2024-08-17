/*
 * Slave.c
 *
 *  Created on: Aug 16, 2024
 *      Author: spyro
 */
#include "Slave.h"
#include "main.h"

extern I2C_HandleTypeDef h12c1;

#define RxSIZE 4
#define TxSIZE 4

uint8_t TxData[TxSIZE] = {0x15, 0xAA , 0xBB, 0xFF};
uint8_t RxData[RxSIZE];
uint8_t rxcount;
uint8_t txcount;
int is_first_recvd = 0;
uint8_t countAddr = 0;
uint8_t counterror = 0;


void process_data (I2C_HandleTypeDef *hi2c)
{


}

extern void HAL_I2C_ListenCpltCallback (I2C_HandleTypeDef *hi2c)
{
	HAL_I2C_EnableListen_IT(hi2c);
}


void HAL_I2C_AddrCallback(I2C_HandleTypeDef *hi2c, uint8_t TransferDirection, uint16_t AddrMatchCode)
{
	if (TransferDirection == I2C_DIRECTION_TRANSMIT)  // if the master wants to transmit the data
	{
		rxcount = 0;
		countAddr++;
		// receive using sequential function.
		HAL_I2C_Slave_Sequential_Receive_IT(hi2c, RxData, RxSIZE, I2C_FIRST_AND_LAST_FRAME);
		rxcount = rxcount + RxSIZE;
		if (__HAL_I2C_GET_FLAG(hi2c, I2C_FLAG_AF)) {
		    // Handle Acknowledge failure
		    __HAL_I2C_CLEAR_FLAG(hi2c, I2C_FLAG_AF);
		}
		HAL_I2C_EnableListen_IT(hi2c);
	}
	else
	{
		txcount = 0;
		HAL_I2C_Slave_Sequential_Transmit_IT(hi2c, TxData, TxSIZE, I2C_FIRST_AND_LAST_FRAME);
		txcount += TxSIZE;
		if (__HAL_I2C_GET_FLAG(hi2c, I2C_FLAG_AF)) {
		    // Handle Acknowledge failure
		    __HAL_I2C_CLEAR_FLAG(hi2c, I2C_FLAG_AF);
		}
		HAL_I2C_EnableListen_IT(hi2c);
	}
}

void HAL_I2C_SlaveRxCpltCallback(I2C_HandleTypeDef *hi2c)
{
	if (rxcount >= RxSIZE)
	{
		rxcount = 0;
        __HAL_I2C_DISABLE(hi2c);

        // Clear any pending interrupts or flags
        __HAL_I2C_CLEAR_FLAG(hi2c, I2C_FLAG_STOPF);
        __HAL_I2C_CLEAR_FLAG(hi2c, I2C_FLAG_AF);


        // Reinitialize I2C
        HAL_I2C_Init(hi2c);

        // Re-enable I2C
        __HAL_I2C_ENABLE(hi2c);

        // Re-enable interrupts
        HAL_I2C_EnableListen_IT(hi2c);

	}
	else
	{
		HAL_I2C_Slave_Seq_Receive_IT(hi2c, RxData+rxcount, 1, I2C_NEXT_FRAME);
	}
}


void HAL_I2C_SlaveTxCpltCallback(I2C_HandleTypeDef *hi2c)
{
	if (txcount >= TxSIZE)
	{
		rxcount = 0;
	    __HAL_I2C_DISABLE(hi2c);

	    // Clear any pending interrupts or flags
	    __HAL_I2C_CLEAR_FLAG(hi2c, I2C_FLAG_STOPF);
	    __HAL_I2C_CLEAR_FLAG(hi2c, I2C_FLAG_AF);

	    HAL_I2C_DeInit(hi2c);
	    HAL_I2C_Init(hi2c);
	    // Re-enable I2C
	    __HAL_I2C_ENABLE(hi2c);
       // Re-enable interrupts
       HAL_I2C_EnableListen_IT(hi2c);
	}
	else
	{
		txcount++;

	}
}

void HAL_I2C_ErrorCallback(I2C_HandleTypeDef *hi2c)
{
	counterror++;
	uint32_t errorcode = HAL_I2C_GetError(hi2c);
	if (errorcode == 4)  // AF error
	{
		process_data(hi2c);
	}
	HAL_I2C_EnableListen_IT(hi2c);
}



