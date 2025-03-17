---
title: Zephyr is as convenient as it gets.
tags:
  - esp32
  - Zephyr
date: "2025-03-17"
---

## Zephyr is as convenient as it gets.

I started looking into Zephyr the wrong way. Normally, one goes through some kind of blinky example to first have a look in what the that platform can offer. Zephyr is **not** like that. Zephyr is so convenient that it turns easy things difficult, and difficult things easy. It sounds like the user ends up in the same position from where it started, but when the degrees of difficulty are mapped into software development, Zephyr _really_ shines.

If everything goes smoothly, you can get a HTTP request demo that works in less than an hour. Zephyr already includes a bunch of pre-included configurations and device tree files, by following the samples, anything should work. Then, it is a matter of tweaking here and there: a device may need extra memory, for example.

### Standard C Library

In the embedded world, the [newlib](https://sourceware.org/newlib/) is really popular. But there are other, targeting smaller binary sizes, like [picolibc](https://keithp.com/picolibc/), that includes code from newlib and AVR libc. Even inside the newlib, there are variants, like the [_nano_](https://docs.zephyrproject.org/latest/develop/languages/c/newlib.html#nano-newlib) variant that does not include all the newlib formats:

> The Newlib nano variant (libc_nano.a and libm_nano.a) is the size-optimized version of the Newlib, and supports all features that the full variant supports except the new format specifiers introduced in C99, such as the char, long long type format specifiers (i.e. %hhX and %llX).

To choose between them, it is as simple as setting:

```
CONFIG_NEWLIB_LIBC=y
```

In case the newlib nano is supported:

```
CONFIG_NEWLIB_LIBC_NANO=y
```

It is _that_ simple. You can read more about libc [here](https://interrupt.memfault.com/blog/boostrapping-libc-with-newlib).

### Reading and writing from a flash partition

Zephyr does this extremelly well. First of all, almost all device tree includes flash partitions. Let's take a look at the esp32s3:

```
flash: flash-controller@60002000 {
  compatible = "espressif,esp32-flash-controller";
  reg = < 0x60002000 0x1000 >;
  #address-cells = < 0x1 >;
  #size-cells = < 0x1 >;
  flash0: flash@0 {
    compatible = "soc-nv-flash";
    reg = < 0x0 0x800000 >;
    erase-block-size = < 0x1000 >;
    write-block-size = < 0x4 >;
    status = "okay";
    partitions {
      compatible = "fixed-partitions";
      #address-cells = < 0x1 >;
      #size-cells = < 0x1 >;
      boot_partition: partition@0 {
        label = "mcuboot";
        reg = < 0x0 0x10000 >;
        read-only;
      };
      slot0_partition: partition@10000 {
        label = "image-0";
        reg = < 0x10000 0x100000 >;
      };
      slot1_partition: partition@110000 {
        label = "image-1";
        reg = < 0x110000 0x100000 >;
      };
      scratch_partition: partition@210000 {
        label = "image-scratch";
        reg = < 0x210000 0x40000 >;
      };
      storage_partition: partition@250000 {
        label = "storage";
        reg = < 0x250000 0x6000 >;
      };
    };
  };
};
```

It includes a main `slot0_partition` partition, one for the OTA firmware update (slot1_partition) and others for othey type of purpose, like data or keys.

This is _extremely_ convenient because you have already an overview of where you should read/write from/to the flash.

Take this example; you flash a binary file into the `storage_partition` at 0x250000. You want to bring the data from flash to RAM (by reading from it), but the flash may not be directly mapped in the CPU, meaning you can't directly access it. That's a bummer, right?

By using Zephyr, that's actually easy: the solution is to use the [flash mapping Zephyr API](https://docs.zephyrproject.org/latest/services/storage/flash_map/flash_map.html).

It is as simple as: _open_ a _flash area_ and read whatever number of bytes to an existing array.

```c
static const struct flash_area* wasm_area = NULL;
uint8_t example_file[24576] = { 0 };

int error = flash_area_open(FIXED_PARTITION_ID(storage_partition),
		                        &wasm_area);

error = flash_area_read(wasm_area, 0, example_file, wasm_area->fa_size);
```

If no error occurs, the array `example_file` will have all the information from flash stored previously at 0x250000.

### Connect to the Internet

Remember when I stated how Zephyr turned tougher things more convenient?
In order to connect a esp32s3 to the Internet using WiFi, add to the configuration `CONFIG_WIFI=y` , enable wifi in the device tree `&wifi { status = "okay"; };` and run the following code:

```c
int wifi_connect(void)
{
	struct net_if* iface = net_if_get_default();

	struct wifi_connect_req_params wifi_params = {
		.ssid        = WIFI_SSID,
		.psk         = WIFI_PSK,
		.ssid_length = sizeof(WIFI_SSID),
		.psk_length  = sizeof(WIFI_PSK),
		.channel     = WIFI_CHANNEL_ANY,
		.security    = WIFI_SECURITY_TYPE_PSK,
		.band        = WIFI_FREQ_BAND_2_4_GHZ,
		.mfp         = WIFI_MFP_OPTIONAL
	};

	if (net_mgmt(NET_REQUEST_WIFI_CONNECT,
	             iface,
	             &wifi_params,
	             sizeof(struct wifi_connect_req_params))) {
		return -1;
	}

	return 0;
}
```

This is ridiculous for me. It is like reducing the software development to Arduino hobby level while keeping the same baremetal/RTOS development feeling and freedom. I'm highly impressed with Zephyr and really think this is the way to the future.
