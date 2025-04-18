---
title: Zephyr and MCUBoot - How to sign and boot validated firmware
tags:
  - esp32
  - Zephyr
  - mcuboot
date: "2025-04-18"
---

## How to sign and boot validated firmware

In my [last blog post about Zephyr and MCUBoot](./zephyr-mcuboot-upgrade-only.md), I wrote about creating an MCUBoot complying image  **without** validating the signature.

By adding a valid signature, one can know two important things:

* whether the image has changed since it was created
* whether the image was created by a valid source

Note that the following information is based on the use of an esp32s3 and Zephyr 3.7.1. I highly recommend reading the MCUBoot [available documentation for espressif](https://docs.mcuboot.com/readme-espressif.html) targets.

### How to creata a key pair

The first step is to generate a key pair. MCUBoot provides three signature algorithms: RSA, ECDSA_P256 and ED25519.

I'd recommend the last, ED25519, since it provides:

* Fastest image signature verification
* Small key size (256-bit)
* Enhanced protection against side-channel attacks

The MCUBoot imgtool.py has a command to generate the desired key pair:

```make
# Makefile
IMGTOOL := ../bootloader/mcuboot/scripts/imgtool.py

keys:
  python3 $(IMGTOOL) keygen -k image_keys.pem -t ed25519
```

It will generate a ED25519 key pair named `image_keys.pem` that should look more or less like this:

```txt
-----BEGIN PRIVATE KEY-----
MC4CAQAwBQYDK2VwBCIAIHrZQPXloLmnjZwVmWE3a//fMp6NYAGQpNStWEz7JTfp
-----END PRIVATE KEY-----
```

Note that this is **key pair**. In the next steps, the public and private keys are extracted from `image_keys.pem` .

### How to create a signed image

Compared to creating a unsigned image, only a few things change.

```make
IMGTOOL := ../bootloader/mcuboot/scripts/imgtool.py

sign:
  python3 $(IMGTOOL) sign \
    --key $(SIGN_KEYS_PATH) \
    --version $(IMAGE_0_VERSION) \
    --pad --pad-sig \
    --align 4 --header-size 32 \
    --slot-size $(IMAGE_SLOT_SIZE) \
    build/zephyr/zephyr.bin $(SIGNED_IMAGE)
```

A `--key` needs to be included and `--pad-sig` needs to be added to the command. The rest is the same as creating an unsigned image. The MCUBoot header is still 32 bytes and the flash alignment is still 4 bytes.

The key **MUST NOT** be shared anywhere. A private key is used to _sign_ and the public to _verify_. By no means, should the key pair or the private key be stored inside the device. Only the public key (as the name states) can, and has, to be stored into the device's flash.

When it comes to the Zephyr configuration (e.g. *.conf), it can be remain unchanged. Although there are a few configurations to use [MCUboot sign command with west flash ](https://docs.zephyrproject.org/latest/develop/west/sign.html), I chose not to use it and do it manually instead. There's no need to add any extra configuration.

### Flash the signed image

The image can already be flashed. The signed image should be flashed into a flash offset where the bootloader will boot to. That is, the `slot0_partition` offset:

```
partitions {
    compatible = "fixed-partitions";
    #address-cells = < 0x1 >;
    #size-cells = < 0x1 >;
    boot_partition: partition@0 {
      label = "mcuboot";
      reg = < 0x0 0x20000 >;
      read-only;
    };
    slot0_partition: partition@20000 {
      label = "image-0";
      reg = < 0x20000 0x100000 >;
    };
    slot1_partition: partition@120000 {
      label = "image-1";
      reg = < 0x120000 0x100000 >;
    };
  };
```

In my case, it's `0x20000` , but it depends based on one's device tree.

To flash the signed image be **extra careful** with the flash offset, it has to match the `slot0_partition` offset (0x20000):

```make
flash-sign: sign
	python3 $(ESPTOOL) \
    -p $(PORT) \
    --baud 921600 --before default_reset \
    --after hard_reset write_flash \
    -u --flash_mode dio --flash_freq 40m \
    --flash_size detect 0x20000 $(SIGNED_IMAGE)
```

Note that `$(SIGNED_IMAGE)` contains the path to the signed path [previously](#how-to-create-a-signed-image) created.

After running the command, the signed image is flashed. Now, the bootloader just needs to verify the `slot0_partition` and boot it.

### How to create the bootloader image

The bootloader image is mostly based into MCUBoot configurations. To sign using ED25519 and to validate the image at every boot, add the following to the configuration:

```yml
CONFIG_BOOT_UPGRADE_ONLY=y # Prevent swapping (used with unsigned image too)

CONFIG_BOOT_VALIDATE_SLOT0=y
CONFIG_BOOT_SIGNATURE_TYPE_ED25519=y
CONFIG_BOOT_SIGNATURE_KEY_FILE="image_keys.pem"
```

The `CONFIG_BOOT_VALIDATE_SLOT0` will validate slot0 everytime the device boots and the other two are essential to create the ED25519 signature.

> [!info]
>
> Bootloader code lays inside `bootloader/mcuboot/boot/zephyr` and is ready to use by Zephyr. The only thing to change are Kconfig values as described above. The configuration is a new one, only meant for the bootloader, and will be added later on in the build process.

The bootloader should also be aware of the flash partitions and its sizes, so whatever partitions are set [in the application side](#flash-the-signed-image), need also to be part of the bootloader device tree.

When building, the command will extract the _public key_ from the `image_keys.pem` key pair and save it under `/build/zephyr/autogen-pubkey.c`

That being said, I'd recommend to build as stated in the Zephyr MCUBoot sample and run the following command:

```make
boot: check
  @rm -f mcuboot.bin
  (mkdir -p $(BUILD_DIR_BOOT) && \
    cd $(BUILD_DIR_BOOT) && \
    cmake -DEXTRA_CONF_FILE=$(BOOTLOADER_EXTRA_CONF_FILE) \
      -G"Ninja" \
      -DBOARD=$(BOARD) \
      $(SOURCE_DIRECTORY)/../../boot/zephyr && \
    ninja)
  cp $(BUILD_DIR_BOOT)/zephyr/zephyr.bin mcuboot.bin
```

The above make command can probably be narrowed down to:

```bash
west build -b esp32s3_devkitc/esp32s3/procpu -- -DEXTRA_CONF_FILE=my-extra-conf.conf
```

Then, to flash:

```bash
west flash
```

And that's it. The device **will not output anything related to the signature as long as there's nothing wrong**. If the signature is wrong, it will output something as such:

```BASH
E: Image in the primary slot is not valid!
```

To troubleshoot, I'd recommend using the [imgtool](https://docs.mcuboot.com/imgtool.html) **dumpinfo** and **validate** options.
