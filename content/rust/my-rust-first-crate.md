---
title: My first Rust Crate
tags:
  - esp32
  - Rust
date: "2025-06-02"
---

## Rust for Embedded

When I [first looked into Rust](./rust-chars.md) (almost one year ago), I noticed the language was still in its early phase for embedded development. Most of the embedded world runs C. The rest may run C++ in consequence of previously running C. I use C and Zephyr in a daily basis. It has always been hard to justify learning Rust when C is everywhere. But oh my — Rust is _the_ future.

Modern languages seem be to made to abstract annoying steps or to hide lack of code fundamentals. You can clearly see how Rust was made; not to guarantee any of the previously stated things, but to improve programming while providing the same low-level access as C or any other low-level language.

One such example is cargo, the build system. Cargo is insanely good. No more CMake hell. Multiple targets? Just create a Cargo.toml that states how many targets you need:

```toml
# Cargo.toml

[workspace]
members = ["lib", "examples/esp32c6-app", "examples/esp32s3-app"]
resolver = "2"
```

And to simply flash an esp32c6:

```bash
cd examples/esp32c6-app
run -p esp32c6-app --target riscv32imac-unknown-none-elf
```

How easy is that?
By no means, such a thing is possible to achieve with Embedded C.

### Something to drive

In order to learn Rust I had to go deeper. Not just the usual _Rust for beginners_ type of thing, but actual code on real hardware. I had to fight the compiler and fight a heavy impostor syndrome.

Regardless of the struggles, one thing I've realized when coding with Rust instead of C, is how much happier I become once the code builds. With C, the code may build, but it may not run. In Rust, I can be almost 100% certain the code will run smoothly and will do what I've imagined it would if it builds. The brief hapiness hits different due to the cofidence provided by the language.

Eventually, I found something to build: a esp32 driver for the [WS2812B](https://cdn-shop.adafruit.com/datasheets/WS2812B.pdf). It works in a simple way, 24 "bit" packet, in which, each 8 "bit" packet is a RGB color (red, green, blue). I used quotes over _bit_ on purpose, because a "bit" is a concept based on how long a GPIO is driven high or low.

* A "1" requires a GPIO to be driven high for 800ns and low for 450ns.
* A "0" requires a GPIO to be driven high for 400ns and low 850ns.

Note how fast is the minimal tick — 50ns. I tried to _bitbang_ a GPIO but couldn't really achieve a nanosecond resolution (the delay module is [unstable](https://docs.espressif.com/projects/rust/esp-hal/1.0.0-beta.1/esp32/esp_hal/index.html#modules)). Finally, the use of the [Remote Control Transceiver](https://docs.esp-rs.org/esp-idf-hal/esp_idf_hal/rmt/index.html) (RMT).

The RMT provides a way to build all the "bits" beforehand. A color can be set from (0, 0, 0) to (255, 255, 255).

A bit "1" can be created by using the trait `PulseCode` :

```rust
fn get_bit_one(&self) -> u32 {
  PulseCode::new(Level::High, 16, Level::Low, 9)
}
```

I've configured each tick to be 50ns, minimal resolution. The GPIO will be high for 16 ticks and low for 9 ticks:

* 16 * 50ns = 800ns
* 9 * 50ns = 450ns

### Run!

A [esp_ws2812_b](https://crates.io/crates/esp_ws2812_b) minimal working example can be written as:

```rust
let config = esp_hal::Config::default().with_cpu_clock(CpuClock::max());
let _peripherals: esp_hal::peripherals::Peripherals = esp_hal::init(config);

let mut r = WS2812B::new(_peripherals.RMT, 80, _peripherals.GPIO8)?;
r.set_colors(255, 0, 0);
r = r.play(1)?;

loop {
  r = r.fade(1)?;
}
```

This example will light up the color red on one (or the first) WS2812B LED.

### More about the crate

* The crate can write up to 255 LEDS in series.
* The last dispatched packet should always be a `PulseCode::empty()` , hence the limit to 255 and not 256.
* The crate **does not** use heap allocation, only stack, and requires 24576 bytes, or 24kB, of stack memory. The crate does not use the std, dependends on esp-hal 1.0.0.
* As of the data of this post, the crate only provides a blocking (using the unstable delay module) fade example, but a non-blocking implementation can be achieve with `fn play`.
