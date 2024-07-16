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

The HAL is great and most of the times is enough. However, it is important to know how to do it manually, register by register, so that one can understand better how things work and develop away from any vendor tool.

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
RCC->AHBENR |= 0x00080000; // RCC_AHBENR_GPIOCEN = 0x00080000
```

The `RCC` points to a memory mapped address register, the Reset and Clock Control (RCC). In this case, we deal with the AHB peripheral clock enable register (RCC_AHBENR 7.4.6).

The AHB peripheral, for those who don't know, is a bus that connects the GPIOs to the Bus Matrix (which is also connected to the AHB2 bus).

![STM32F0 System architecture](../img/system_arch_stm32f0.jpg)

The _AHB peripheral clock enable register_ enables/disables the clock for all the GPIO ports.

![RCC_AHBENR Register](../img/RCC_AHBENR.jpg)

Therefore, by previously setting the `PORTC` bit to 1, we are actually enabling the clock.

### Init

What registers need to be set to initialize a port? Let's check.

Inside `HAL_GPIO_Init`:

```c
/* Configure the IO Output Type */
temp = GPIOx->OTYPER;
temp &= ~(GPIO_OTYPER_OT_0 << position) ;
temp |= (((GPIO_Init->Mode & OUTPUT_TYPE) >> OUTPUT_TYPE_Pos) << position);
GPIOx->OTYPER = temp;

// ...

/* Activate the Pull-up or Pull down resistor for the current IO */
temp = GPIOx->PUPDR;
temp &= ~(GPIO_PUPDR_PUPDR0 << (position * 2u));
temp |= ((GPIO_Init->Pull) << (position * 2u));
GPIOx->PUPDR = temp;

// ...

/* Configure IO Direction mode (Input, Output, Alternate or Analog) */
temp = GPIOx->MODER;
temp &= ~(GPIO_MODER_MODER0 << (position * 2u));
temp |= ((GPIO_Init->Mode & GPIO_MODE) << (position * 2u));
GPIOx->MODER = temp;
```

Starting from the top to the bottom, the register `OTYPER` stands for _output type register_:

![GPIO port output type register (GPIOx_OTYPER)](../img/OTYPER.jpg)

The register `PUPDR` stands for _pull-up/pull-down register_ but doesn't necessarly need to be set. The default value is 0: no pull-up or pull-down resistor.

![GPIO port pull-up/pull-down register (GPIOx_PUPDR)](../img/PUPDR.jpg)

And finally, the `MODER`. It stands for _mode register_ and is responsible for setting a pin to one of the four available options:

![GPIO port mode register (GPIOx_MODER)](../img/MODER.jpg)

From the code example above, both `MODER` and `OTYPER` are dependant on `GPIO_Init`, which is the same struct as seen [before](#init).

Simplifying a bit all the bitwise operations and the abstractions, the code may look like this:

```c
/* For Pin 2 on PORTC */
#define pin 2

/* Configured as push-pull (set as 0) */
GPIOC->OTYPER &= ~(1 << pin); // OT2

// ...

/* No pull-up or pull-down (set as 0) */
// 3u = 11: Reserved
// * 2 = 2 bits per pin
GPIOC->PUPDR = &= ~(1 << (3u << (pin * 2))); // PUPDR2[1:0]

// ...

/* Configured as an output (set as 0x1) */
// 1u = 01: General purpose output mode
// * 2 = 2 bits per pin
GPIOC->MODER |= (1 << (1u << (pin * 2)));
```

After a port is correctly initialized as an output, there are a few things that happen on the hardware level:

![IO Port Bit](../img/IOPortBit.jpg)

Everything starts with the `MODER` set as an output. The `OTYPER` register controls how the MOSFETs are used and the `PUPDR` enables or disables the resistors accordingly.

In contrast to what some may think, the input data register is still being sampled with data. However, there is one major diference:

- The input data register (IDR) has the I/O state (data presented at the pin)
- The output data register (ODR) has the last written value

It's important to know the diference, as they are not exactly the same!

### Write

Inside `HAL_GPIO_WritePin`:

```c
if (PinState != GPIO_PIN_RESET)
{
  GPIOx->BSRR = (uint32_t)GPIO_Pin;
}
else
{
  GPIOx->BRR = (uint32_t)GPIO_Pin;
}
```

In this specific case, due to both having only access to write and placed before `ODR`, they can be used without bitwise operations.

![IO Port Bit W](../img/IOPortBitZoom.jpg)
