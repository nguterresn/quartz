---
title: Control the ka3005p power supply with an Arduino Due
tags:
  - Arduino
date: "2023-05-06"
---

There a ton of [repositories available online](https://github.com/Nicoretti/ka3005p) on how to control the ka3005p power supply according to its command sheet. There none on how to control it using an embedded device, such as a microcontroller. You can take a look into the library [here](https://github.com/nguterresn/due-ka3005p/tree/master).

The first requirement is that the device must be able to be an USB Host. The ka3005p power supply acts as an USB device and needs to be managed by an host.
The Arduino Due supports USB host capabilities. It is not possible to use other popular Arduino Boards, such as Uno or Mega to control the power supply.

The [USB Host Shield 2.0](https://github.com/felis/USB_Host_Shield_2.0) is a very interesting project and was from where I took all the code I needed to make this project happen. My library is basically a modified [USB CDC](https://en.wikipedia.org/wiki/USB_communications_device_class) library and a wrapper with all the commands that the power supply expects.

I've used a software on a computer to read and identify the USB characteristics comming from the power supply. This gave me the information I needed to change the _ConfigDescParser_ method (inside _cdc.cpp_) and add the const `USB_CLASS_CDC_DATA` as part of it.

Here is an example on how to use the library:

```c
#include "psu.h"

// #define USE_SERIAL

#ifdef USE_SERIAL
PSU psu;
#else
PSU psu(&Serial);
#endif

void setup()
{
  cpu_irq_enable();
}

void loop()
{
  psu.task();
  uint8_t usb_state = psu.getUsbTaskState();
  if (usb_state == USB_DETACHED_SUBSTATE_WAIT_FOR_DEVICE) {
    // ka3005p not connected.
    return;
  }
  else if (usb_state == USB_STATE_RUNNING) {
    // USB Enumeration is done, do something.
    psu.setCurrent(CHANNEL_1, 2.00);
  }
}
```

If your using platformIO, check the settings you need to add [here](https://github.com/nguterresn/due-ka3005p/blob/master/platformio.ini).
