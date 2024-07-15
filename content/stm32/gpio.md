---
title: Set up an output on a STM32F0
tags:
  - STM32
date: "2024-07-15"
---

## Introduction

Setting up a 32-bit based MCU pin might be more tricky than you think. However, it is not really difficult. There are packages, like the HAL, one can use to quickly setup a pin as an output. But — what really happens behind the scenes?

I'll try to list down all the things I've learned from experience using the [STM32F030R8](https://www.st.com/en/microcontrollers-microprocessors/stm32f030r8.html).

## HAL

The easiest thing to do is to learn from examples. The default code generated from the STM32CubeIDE contains a few functions that group a few [HAL](https://github.com/STMicroelectronics/stm32f0xx_hal_driver) calls:

```c
static void MX_GPIO_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct = { 0 };

  /* GPIO Ports Clock Enable */
  __HAL_RCC_GPIOC_CLK_ENABLE();
  __HAL_RCC_GPIOA_CLK_ENABLE();

  /*Configure GPIO pin : B1_Pin */
  GPIO_InitStruct.Pin  = B1_Pin;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_FALLING;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);

  /*Configure GPIO pin : LD2_Pin */
  GPIO_InitStruct.Pin   = LD2_Pin;
  GPIO_InitStruct.Mode  = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull  = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
}
```

### RCC

Note the first thing done is to setup the clock for each `PORT` used:

```c
/* GPIO Ports Clock Enable */
__HAL_RCC_GPIOC_CLK_ENABLE();
__HAL_RCC_GPIOA_CLK_ENABLE();
```

### Init

The HAL provides a struct of type `GPIO_InitTypeDef` to ease the process of initializing a GPIO:

```C
typedef struct
{
  uint32_t Pin;
  uint32_t Mode;
  uint32_t Pull;
  uint32_t Speed;
  uint32_t Alternate;
} GPIO_InitTypeDef;
```

The `Pull`, `Speed` and `Alternate` integers are variables we don't need to pay attention now. On the other hand, both `Pin` and `Mode` integers are important. The two integers are quite explicit for what they serve.

To initialize, a struct of type `GPIO_InitTypeDef` is created and is filled with the desired data. Since we want to set up the pin as an output, it would be something like:

```c
GPIO_InitTypeDef GPIO_InitStruct = { 0 };

// ...
// #define GPIO_PIN_5  ((uint16_t)0x0020U)  /* Pin 5 selected */
// ...

GPIO_InitStruct.Pin   = GPIO_PIN_5;
GPIO_InitStruct.Mode  = MODE_OUTPUT | OUTPUT_PP;
GPIO_InitStruct.Pull  = GPIO_NOPULL;
GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;

HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);
```

The `GPIO_PIN_5` is defined by the HAL (stm32f0xx_hal_gpio.h).
The mode is defined as `MODE_OUTPUT`. This enables a few things internally. The mode also specifies `OUTPUT_PP`, which sets the GPIO in a _push-pull_ mode (sources Vcc when 1 and Gnd when 0).

### Write

To write to a pin, you need to simply use one of the HAL available functions:

```c
HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET);
```

## Underneath the HAL

The HAL is great and most of the times is enough. However, it is important to know how to do it manually, register by register, so that one can understand better how things work.

### RCC

Digging `__HAL_RCC_GPIOC_CLK_ENABLE`, we can check a define as such:

```c
__IO uint32_t tmpreg;

SET_BIT(RCC->AHBENR, RCC_AHBENR_GPIOCEN);
tmpreg = READ_BIT(RCC->AHBENR, RCC_AHBENR_GPIOCEN);
UNUSED(tmpreg);
```

Which translates to:

```c
RCC->AHBENR |= 0x00080000;
```

The `RCC` points to a memory mapped address register, the Reset and Clock Control (RCC). In this case, we deal with the AHB peripheral clock enable register (RCC_AHBENR 7.4.6).

The AHB peripheral, for those who don't know, is a bus that connects the GPIOs to the Bus Matrix (which is also connected to the AHB2 bus).

![STM32F0 System architecture](../img/system_arch_stm32f0.jpg)

The _AHB peripheral clock enable register_ enables/disables the clock for all the GPIO ports.

![RCC_AHBENR Register](../img/RCC_AHBENR.jpg)

Therefore, by previously setting the `PORTC` bit to 1, we are actually enabling the clock for the same port.

### Init

### Write
