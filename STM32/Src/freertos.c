/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * File Name          : freertos.c
  * Description        : Code for freertos applications
  ******************************************************************************
  * This notice applies to any and all portions of this file
  * that are not between comment pairs USER CODE BEGIN and
  * USER CODE END. Other portions of this file, whether 
  * inserted by the user or by software development tools
  * are owned by their respective copyright owners.
  *
  * Copyright (c) 2022 STMicroelectronics International N.V. 
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without 
  * modification, are permitted, provided that the following conditions are met:
  *
  * 1. Redistribution of source code must retain the above copyright notice, 
  *    this list of conditions and the following disclaimer.
  * 2. Redistributions in binary form must reproduce the above copyright notice,
  *    this list of conditions and the following disclaimer in the documentation
  *    and/or other materials provided with the distribution.
  * 3. Neither the name of STMicroelectronics nor the names of other 
  *    contributors to this software may be used to endorse or promote products 
  *    derived from this software without specific written permission.
  * 4. This software, including modifications and/or derivative works of this 
  *    software, must execute solely and exclusively on microcontroller or
  *    microprocessor devices manufactured by or for STMicroelectronics.
  * 5. Redistribution and use of this software other than as permitted under 
  *    this license is void and will automatically terminate your rights under 
  *    this license. 
  *
  * THIS SOFTWARE IS PROVIDED BY STMICROELECTRONICS AND CONTRIBUTORS "AS IS" 
  * AND ANY EXPRESS, IMPLIED OR STATUTORY WARRANTIES, INCLUDING, BUT NOT 
  * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
  * PARTICULAR PURPOSE AND NON-INFRINGEMENT OF THIRD PARTY INTELLECTUAL PROPERTY
  * RIGHTS ARE DISCLAIMED TO THE FULLEST EXTENT PERMITTED BY LAW. IN NO EVENT 
  * SHALL STMICROELECTRONICS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
  * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
  * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
  * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "FreeRTOS.h"
#include "task.h"
#include "main.h"
#include "cmsis_os.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */     
#include "spi.h"
#include "usart.h"
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN Variables */
#define DATA_SIZE 300
static 	uint8_t data[DATA_SIZE];
static 	uint8_t rdata[DATA_SIZE];

/* USER CODE END Variables */
osThreadId defaultTaskHandle;
osThreadId myTask02Handle;
osThreadId myTask03Handle;

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN FunctionPrototypes */
   
/* USER CODE END FunctionPrototypes */

void StartDefaultTask(void const * argument);
void StartTask02(void const * argument);
void StartTask03(void const * argument);

void MX_FREERTOS_Init(void); /* (MISRA C 2004 rule 8.1) */

/**
  * @brief  FreeRTOS initialization
  * @param  None
  * @retval None
  */
void MX_FREERTOS_Init(void) {
  /* USER CODE BEGIN Init */
       
  /* USER CODE END Init */

  /* USER CODE BEGIN RTOS_MUTEX */
  /* add mutexes, ... */
  /* USER CODE END RTOS_MUTEX */

  /* USER CODE BEGIN RTOS_SEMAPHORES */
  /* add semaphores, ... */
  /* USER CODE END RTOS_SEMAPHORES */

  /* USER CODE BEGIN RTOS_TIMERS */
  /* start timers, add new ones, ... */
  /* USER CODE END RTOS_TIMERS */

  /* Create the thread(s) */
  /* definition and creation of defaultTask */
  osThreadDef(defaultTask, StartDefaultTask, osPriorityNormal, 0, 128);
  defaultTaskHandle = osThreadCreate(osThread(defaultTask), NULL);
#if 0
  /* definition and creation of myTask02 */
  osThreadDef(myTask02, StartTask02, osPriorityIdle, 0, 128);
  myTask02Handle = osThreadCreate(osThread(myTask02), NULL);

  /* definition and creation of myTask03 */
  osThreadDef(myTask03, StartTask03, osPriorityIdle, 0, 128);
  myTask03Handle = osThreadCreate(osThread(myTask03), NULL);
#endif
  /* USER CODE BEGIN RTOS_THREADS */
  /* add threads, ... */
  /* USER CODE END RTOS_THREADS */

  /* USER CODE BEGIN RTOS_QUEUES */
  /* add queues, ... */
  /* USER CODE END RTOS_QUEUES */
}

/* USER CODE BEGIN Header_StartDefaultTask */
/**
  * @brief  Function implementing the defaultTask thread.
  * @param  argument: Not used 
  * @retval None
  */
/* USER CODE END Header_StartDefaultTask */
void StartDefaultTask(void const * argument)
{

  /* USER CODE BEGIN StartDefaultTask */
/*
	MOSI	PA7
	SS		PC4
	SCLK	PB3
	TRIG	PB7
*/

	uint8_t *pData = data;
	uint16_t Size = DATA_SIZE;
	int ctr = 0;
	int i;
	uint8_t xbyte = 0x21;
	int menu_ptr = 0;

	HAL_StatusTypeDef ret;

	for(i = 0;i < DATA_SIZE;i++)
	{
		data[i] = xbyte;
		if(++xbyte > 0x7e)
			xbyte = 0x21;
	}
	xbyte = 0x7e;
	for(i = 0;i < DATA_SIZE;i++)
	{
		rdata[i] = xbyte;
		if(--xbyte < 0x21)
			xbyte = 0x73;
	}
	vTaskDelay(1000);

	/* Infinite loop */

	for(;;)
	{
		// scope trigger (PB7)
//		data[0]++;
		HAL_GPIO_WritePin(GPIOB, TRIG_Pin, GPIO_PIN_SET);
		vTaskDelay(1);
		HAL_GPIO_WritePin(SPI1_SS_GPIO_Port, SPI1_SS_Pin, GPIO_PIN_RESET);
		vTaskDelay(1);
		// hspi1 is conf as master; hspi2 is slave
		HAL_SPI_TransmitReceive(&hspi2, &data[0], &rdata[0], Size, 100);
		vTaskDelay(1);
		HAL_GPIO_WritePin(SPI1_SS_GPIO_Port, SPI1_SS_Pin, GPIO_PIN_SET);
		vTaskDelay(1);
		HAL_GPIO_WritePin(GPIOB, TRIG_Pin, GPIO_PIN_RESET);
		vTaskDelay(1);
		ret = HAL_UART_Transmit(&huart2, &rdata[0], Size, 100);
		vTaskDelay(50);
		if(menu_ptr == 0)
		{
			HAL_GPIO_WritePin(GPIOD, LED1_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOD, LED2_Pin, GPIO_PIN_SET);
			menu_ptr = 1;
		}else if(menu_ptr == 1)
		{
			HAL_GPIO_WritePin(GPIOD, LED2_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOD, LED3_Pin, GPIO_PIN_SET);
			menu_ptr = 2;
		}else if(menu_ptr == 2)
		{
			HAL_GPIO_WritePin(GPIOD, LED3_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOD, LED4_Pin, GPIO_PIN_SET);
			menu_ptr = 3;
		}else if(menu_ptr == 3)
		{
			HAL_GPIO_WritePin(GPIOD, LED4_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOD, LED1_Pin, GPIO_PIN_SET);
			menu_ptr = 0;
		}

	}
  /* USER CODE END StartDefaultTask */
}

/* USER CODE BEGIN Header_StartTask02 */
/**
* @brief Function implementing the myTask02 thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_StartTask02 */
void StartTask02(void const * argument)
{
  /* USER CODE BEGIN StartTask02 */
  /* Infinite loop */
	HAL_StatusTypeDef ret;
	int i,j;
	uint8_t xbyte = 0x21;
	uint8_t *pData;
	uint16_t Size;
	int menu_ptr = 0;
	int ctr = 0;
	
	for(i = 0;i < DATA_SIZE;i++)
	{
		data[i] = xbyte;
		if(++xbyte > 0x7e)
			xbyte = 0x21;
	}
	pData = &data[0];
//	pData = &xbyte;
	Size = DATA_SIZE;
//	Size = 1;
//	data[DATA_SIZE-2] = '\r';
//	data[DATA_SIZE-1] = '\n';
	j = 1;

	for(;;)
	{
//		vTaskDelay(500);
//		HAL_GPIO_WritePin(GPIOB, TRIG_Pin, GPIO_PIN_SET);
//		for(i = 0;i < j;i++)
//			vTaskDelay(1);
		Size--;
		if(Size < 270)
			Size = DATA_SIZE;

		if((j += 10) > 500)
		{
			j = 1;
/*
			xbyte = '\r';
			HAL_UART_Transmit(&huart2, &xbyte, 1, 100);
			xbyte = '\n';
			HAL_UART_Transmit(&huart2, &xbyte, 1, 100);
*/
			xbyte = 7;
			HAL_UART_Transmit(&huart2, &xbyte, 1, 100);
			vTaskDelay(1000);
			
		}
//		HAL_GPIO_WritePin(GPIOB, TRIG_Pin, GPIO_PIN_RESET);
		ret = HAL_UART_Transmit(&huart2, pData, Size, 100);

		if(menu_ptr == 0)
		{
			HAL_GPIO_WritePin(GPIOD, LED1_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOD, LED2_Pin, GPIO_PIN_SET);
			menu_ptr = 1;
		}else if(menu_ptr == 1)
		{
			HAL_GPIO_WritePin(GPIOD, LED2_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOD, LED3_Pin, GPIO_PIN_SET);
			menu_ptr = 2;
		}else if(menu_ptr == 2)
		{
			HAL_GPIO_WritePin(GPIOD, LED3_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOD, LED4_Pin, GPIO_PIN_SET);
			menu_ptr = 3;
		}else if(menu_ptr == 3)
		{
			HAL_GPIO_WritePin(GPIOD, LED4_Pin, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(GPIOD, LED1_Pin, GPIO_PIN_SET);
			menu_ptr = 0;
		}
	}
  /* USER CODE END StartTask02 */
}

/* USER CODE BEGIN Header_StartTask03 */
/**
* @brief Function implementing the myTask03 thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_StartTask03 */
void StartTask03(void const * argument)
{
  /* USER CODE BEGIN StartTask03 */
  /* Infinite loop */
	uint8_t xbyte = 0x21;
	
	for(;;)
	{
		vTaskDelay(100);
		xbyte++;
	}
  /* USER CODE END StartTask03 */
}

/* Private application code --------------------------------------------------*/
/* USER CODE BEGIN Application */
     
/* USER CODE END Application */

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
