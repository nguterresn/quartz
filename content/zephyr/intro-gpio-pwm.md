---
title: Intro to Zephyr, GPIO and PWM on esp32
tags:
  - esp32
  - Zephyr
date: "2025-01-30"
---

## Introduction to Zephyr

[Zephyr](https://www.zephyrproject.org) has been around for some time but no one seems to know how to pronounce it correctly yet. It started as an [RTOS](https://en.wikipedia.org/wiki/Zephyr_(operating_system)) but it has evolved for something much much better, something that has been missing in the embedded field for a while.

I've always tried to avoid Zephyr for two main reasons:

* Never had to actually used it
* Learning curve

The [esp-idf](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/index.html) provides [freeRTOS](https://www.freertos.org) out-of-the-box. It's easy to install and understand, why would anyone move away from that?

Zephyr starts to get some attention when projects start to get bigger, because the best characteristic of Zephyr, it is not its RTOS, but its tooling instead. Zephyr tooling is **amazing**. It is hard to grasp how good it is until one uses it for the first time. It's _game changing_.

Without Zephyr, one needs to go down the rabbit-hole of CMake or Makefile to build, debug and flash. One needs to manage all the dependencies, repositories, branches, releases, etc. Zephyr offers its own build [tool](https://docs.zephyrproject.org/latest/develop/west/index.html), `west` , and `west` handles that _flawlessly_!

Zephyr tooling is so good, I'd only use Zephyr _because_ of it, _despite_ its learning curve.

### Hello World or Toggle a GPIO, you name it

Better than reading about Zephyr, is to actually see it in action. For the remaining of this article, I'd be using an esp32, namely the board `esp32_devkitc_wroom/esp32/procpu` .

The Zephyr device tree is a way of passing all the information about a microcontroller and board into a format that will later be possible to be accessed from code. The device tree is also the result of multiple device tree files (.dts/.dtsi) in cascade.

So normally:

* A module/chip has a common configuration, e.g. `esp32_common.dtsi`: includes all the peripherals definitions
* A board takes the common configuration and adapts to its hardware design, e.g. `esp32_devkitc_wroom_procpu.dts`: it has all the hardware default configurations, such as uart
* The board configuraiton might not be enough to cover all the cases, so a overlay is created to attach pins to peripherals,     `esp32_devkitc_wroom_procpu.overlay`

Reading all the files is quite a challenging.

Since esp32 already comes with two GPIO interfaces defined, `gpio0` and `gpio1` , any GPIO can be accessed from the code:

```dts
// from esp32_common.dtsi

gpio0: gpio@3ff44000 {
  compatible = "espressif,esp32-gpio";
  gpio-controller;
  #gpio-cells = <2>;
  reg = <0x3ff44000 0x800>;
  interrupts = <GPIO_INTR_SOURCE IRQ_DEFAULT_PRIORITY 0>;
  interrupt-parent = <&intc>;
  /* Maximum available pins (per port)
    * Actual occupied pins are specified
    * on part number dtsi level, using
    * the `gpio-reserved-ranges` property.
    */
  ngpios = <32>;   /* 0..31 */
};
```

```c
#include <stdio.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>
#include <zephyr/device.h>

// For more pins, check esp32-pinctrl.h
static const struct device* gpio2 = DEVICE_DT_GET(DT_NODELABEL(gpio0));

int main(void)
{
	if (!device_is_ready(gpio2)) {
		printk("Error: gpio2 device is not ready\n");
		return -1;
	}
	// Configure GPIO 2 as output
	gpio_pin_configure(gpio2, 2, GPIO_OUTPUT);

	while (1) {
		gpio_pin_set(gpio2, 2, 1);
		k_msleep(1000);
		gpio_pin_set(gpio2, 2, 0);
		k_msleep(1000);
	}
	return 0;
}
```

The code above will toggle GPIO 2, which is connected on my board to an LED.
This was easy, right? The chanllenges start with the device tree.

### Device tree and PWM

The goal is to generate a PWM wave of 50% duty cycle. There are multiple options regarding the esp32:

* Use the zephyr PWM driver
* Use the [led control driver](https://docs.zephyrproject.org/latest/build/dts/api/bindings/pwm/espressif%2Cesp32-ledc.html)
* Use the [motor control driver](https://docs.zephyrproject.org/latest/build/dts/api/bindings/pwm/espressif%2Cesp32-mcpwm.html)

The two last options are like abstractions from the main PWM driver. It just eases the process of handling PWM on the esp32.

To select the a GPIO to generate a PWM wave, the pin needs to have a sort of pin multiplexer that sets the pin as enabled to generate the said PWM.

To use the esp-ledc driver, the peripheral `lec0` , that is defined in `esp32_common.dtsi` , needs to have a pin multiplexer (or pin control) fed. That can be done by the [node `pinctrl`](https://docs.zephyrproject.org/latest/hardware/pinctrl/index.html) .

```c
&pinctrl {
  ledc0_default: ledc0_default {
    group1 {
      pinmux = <LEDC_CH0_GPIO2>;
      output-enable;
    };
  };
};
```



> [!info]
>
> The GPIO2 needs first to support the peripheral (or vice-versa) before it can be assigned to a pinctrl (hence, `LEDC_CH0_GPIO2`, _ledc channel 0 at GPIO2_). Some peripherals may not be supported for some other GPIOs.

A pinctrl node, such as the `ledc0_default`, can be then assigned to an existing interface (ledc0) that [expects a pinctrl](https://docs.zephyrproject.org/latest/build/dts/api/bindings/pwm/espressif%2Cesp32-ledc.html).

```c
&ledc0 {
  status = "okay";
  pinctrl-0 = <&ledc0_default>;
	pinctrl-names = "default";
  #address-cells = <1>;
  #size-cells = <0>;

  TheChannelZero@0 {
    reg = <0x0>;
    timer = <0>;
  };
};
```

To make things easier, an alias can then be created to access the `ledc0` node.

```
/ {
  aliases {
    led = &ledc0;
  };
};
```

Finally, the code will look as such:

```c
#include <stdio.h>
#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>
#include <zephyr/device.h>
#include <zephyr/drivers/pwm.h>

// For more pins, check esp32-pinctrl.h
static const struct device* ledc0_dev = DEVICE_DT_GET(DT_ALIAS(led));

int main(void)
{
	if (!device_is_ready(ledc0_dev)) {
		printk("Error: ledc0_dev device is not ready\n");
		return -1;
	}

	// Set PWM signal
	int ret = pwm_set(ledc0_dev, 0, 1000, 500, PWM_POLARITY_NORMAL);
	if (ret < 0) {
		printk("Error: Failed to set PWM signal (err %d)\n", ret);
		return -1;
	}
	return 0;
}
```

Here's the full overlay:

```dts
/ {
  aliases {
    led = &ledc0;
  };
};

&ledc0 {
  status = "okay";
  pinctrl-0 = <&ledc0_default>;
	pinctrl-names = "default";
  #address-cells = <1>;
  #size-cells = <0>;

  Channel0@0 {
    reg = <0x0>;
    timer = <0>;
  };
};

&pinctrl {
  ledc0_default: ledc0_default {
    group1 {
      pinmux = <LEDC_CH0_GPIO2>;
      output-enable;
    };
  };
};
```


