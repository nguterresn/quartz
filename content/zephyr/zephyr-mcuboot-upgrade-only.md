---
title: Zephyr and MCUBoot upgrade only
tags:
  - zephyr
  - esp32
  - mcuboot
date: "2025-04-13"
---

## Zephyr and MCUBoot - Simple upgrade only

This blog post aims to show how to setup MCUBoot on a esp32s3 and perform a
unverified flash slot/partition swap. Although there's [this](https://docs.mcuboot.com/readme-zephyr.html)
document that provides a bunch of information about MCUBoot and how it should be
enabled for the Zephyr build, I personally think that's too much information without actual examples;
and too much focus on complex swap algorithms without touching any bootloader foundation.

A bootloader should boot an image — in the essence of the name, that's its purpose. However,
with modern needs, things have changed and bootloaders have multiple stages, downgrade protection, signature validation, etc.

As far as MCUBoot allows, a bootloader should at least be able to:

* Check for the presence of a image in a secondary partition
* Override primary partition with a new second partition
* Boot from the primary partition

## Build and flash MCUBoot

The first step to achieve what's stated above, is to cherry-pick all the Zephyr defines needed for the desired behaviour:

```dts
CONFIG_MAIN_STACK_SIZE=10240
CONFIG_MBEDTLS_CFG_FILE="mcuboot-mbedtls-cfg.h"

CONFIG_FLASH=y

CONFIG_BOOT_UPGRADE_ONLY=y
CONFIG_BOOT_SIGNATURE_TYPE_NONE=y
```

The `CONFIG_BOOT_UPGRADE_ONLY=y` and `CONFIG_BOOT_SIGNATURE_TYPE_NONE=y` have a special reason here: the first **replaces the primary partition with the second** (without the option to undo) and the second **prevents the boot partition from having its signature verified**.

The MCUBoot build will be stored at offset 0x0, as stated in the default Zephyr device-tree:

```
boot_partition: partition@0 {
  label = "mcuboot";
  reg = < 0x0 0x10000 >;
  read-only;
};
```

Under `bootloader/mcuboot/boot/zephyr` you will find the ported MBUBoot code for Zephyr. Simply build and flash for your target:

```
west build -b <target>
west flash
```

The flashing process should also erase a few sectors of the flash before writting. Make sure it doesn't overflow the current limit of 0x10000.

## Build and flash your custom firmware

Now, that the bootloader is already in the device, it is time to tweak the application configuration:

```dts
# Bootloader
CONFIG_REBOOT=y
CONFIG_BOOTLOADER_MCUBOOT=y
# Required to use dfu/mcuboot module
CONFIG_STREAM_FLASH=y
CONFIG_IMG_MANAGER=y
```

Above, are all the extra defines that are necessary to add to be able to request, update and reboot the device.

Somewhere across my application code, I had to add the following code block:

```c
void image_handle_firmware_downloaded(struct appq* data)
{
	(void)data;

	boot_request_upgrade(BOOT_UPGRADE_PERMANENT);
	sys_reboot(SYS_REBOOT_COLD);
}
```

When `image_handle_firmware_downloaded` is executed, the code simply flags the secondary partition as swappable. Upon reboot, the bootloader checks for the swappable flag and proceeds to replace the primary partition with the second one.

There is no signature verification and it is not possible to recover the previous primary partition (due to the bootloader [config](#build-and-flash-mcuboot)).

Now, the next thing to do is to flash the application code into the primary partition (slot0_partition).
I've split the partitions as such:

```dts
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
```

(I'm pretty sure there's a way to automate the process, I just couldn't figured it out in time) Instead of using `west flash` , I've split the flashing process in two steps:

* Usage of `imgtool.py`: to create the MCUBoot firmware (includes a 32 byte header, even if unsigned)
* Usage of `esp_tool.py`: to flash in a specific flash offset

In short, it can be executed as such:

```bash
python3 ../bootloader/mcuboot/scripts/imgtool.py create --version 0.0.1 --align 4 --header-size 32 --slot-size 1048576 build/zephyr/zephyr.bin dist/unsigned-slot0.bin
python3 ../modules/hal/espressif/tools/esptool_py/esptool.py -p /dev/cu.wchusbserial58FC0505471 --baud 921600 --before default_reset --after hard_reset write_flash -u --flash_mode dio --flash_freq 40m --flash_size detect 0x10000 dist/unsigned-slot0.bin
```

Note two things:

* The slot size used on `imgtool.py` has to match the size of the primary partition (0x100000)
* The flash offset (`0x10000 dist/unsigned-slot0.bin`) needs to match the offset of the primary partition (0x10000)

## Build for the secondary partition

A similar approach as above can used to build and flash to a secondary partition and flag it at boot.

```c
// For unsigned-slot0.bin
void main()
{
  printk("This is slot0!\n");

	boot_request_upgrade(BOOT_UPGRADE_PERMANENT);
	sys_reboot(SYS_REBOOT_COLD);
}
```

```c
// For unsigned-slot1.bin
void main()
{
  printk("This is slot1!\n");
}
```

As long as both were successfully created using `imgtool.py` and flash into the correct address, the slot0 will first boot, followed by a restart, copy of slot1 to slo0 and boot from slot0, displaying:

```bash
"This is slot1!\n"
```
