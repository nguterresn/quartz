---
title: SysTick, Priorities and HAL
tags:
  - STM32
  - HAL
  - Timer
date: "2024-09-15"
---

### SysTick as an exception

The SysTick, or SYSTICK, is a built-in 24-bit count down system timer presented in every Cortex-M microcontroller. As a consequence, it is also available in every STM32 microcontroller with the same architecture.

![NVIC Chart](http://microcontrollerslab.com/wp-content/uploads/2020/09/Nested-vectored-interrupt-controller-NVIC-ARM-CortexM-microcontrollers.jpg)

*[Source](https://microcontrollerslab.com/nested-vectored-interrupt-controller-nvic-arm-cortex-m/)*

The SysTick also acts as an exception, in parallel with, for example, an _Interrupt Request_ (IRQ). The exception, when _triggered_, is then managed by the _Nested Vectored Interrupt Controller_ (NVIC) and dispatched according to its priority.

This system timer happens to be extremely important due to its goal — to be used by an RTOS or as a portable basic timer. According to the datasheet of the STM32F030R8:

> The SysTick calibration value is set to 6000, which gives a reference time base of 1 ms with
the SysTick clock set to 6 MHz (max fHCLK / 8).

A reference time of 1ms is a perfect match for RTOS context switching!

> [!note]
> The calibration value differs between different Cortex-M, and so does fHCLK.

By default, the STM32F030R8 has its HCLK or HSI (High Speed Internal) clock, set as 8MHz.

![fHCLK_HSI](../img/fHCLKHSI.jpg)

Reading from the left to the right, the HSI is then divided by 8 to output the Cortex system timer, the SysTick. This flow results in a timer of 1KHz, or 1ms, as presented above.
However, the frequency at which the SysTick runs, can change by:

- Selecting (SW) the PLLCLK or HSE.
- Setting a different HPRE (a prescaler) for SYSCLK.

### HAL_InitTick
