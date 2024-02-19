---
title: Compile, Program and Run a FPGA using Python scripts
tags:
  - FPGA
  - Python
date: "2021-02-09"
---

Using an IDE is good for development, but when the work is done, there is no big reason to continue to open the IDE and click **"Compile, Program, Run..."**. So, the best solution is to run scripts and automate the process!

The FPGA needs to **compile**, be **programmed** and then **run the C file** over **Nios 2 processor**. The compiling and programming can be done only using Quartus tools, but, in order to Run a C file, it is necessary to **use the Nios 2 Command Shell.** Therefore, compiling and programming will be done using the Quartus Tools while building and running a C file can be done using the Nios 2 Command Shell.

Before starting, note that everything is done in a Windows computer. In a Linux computer the steps would be similar, yet different.

All the documentation is available online. A good reference is the [Quartus II Scripting Reference Manual](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/manual/tclscriptrefmnl.pdf) and the [Nios II Software Developer Handbook](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/nios2/n2sw_nii5v2gen2.pdf), for Quartus Tools and Nios 2 Command Shell, respectively.

## Quartus Tools

### Compile

Using `quartus_sh` is possible to run commands using a shell, which has a very small foorprint.

```python
quartus_sh --flow compile <top file>
```

Running this command allows us to compile using the **top** file of the project.

### Program

To program, it is not used the `quartus_sh` anymore but the `quartus_pgm` instead.

```python
quartus_pgm -l # to display the list of available hardware
```

**Note**: try this command above to check if there are any USB-Blaster connected.

After testing connection, try to run the following command to program the previous compiled files to the FPGA:

```python
quartus_pgm -c USB-Blaster -m jtag -o p;<path to .sof file>
```

If the command does not fail, the FPGA is now successfully programmed through USB-Blaster using JTAG.

## Nios 2 Command Shell

This shell uses **Windows Subsystem for Linux** and, although some things are similar, others are not.

Nios 2 Command Shell uses the **Linux terminal** instead of Windows' Power Shell, so it's possible to use Linux terminal commands like `cd` or `make`.

After programming the FPGA, the system is changed - this means that the board support package (BSP) also needs to be refreshed or updated with new system parameters or characteristics. ([Check older articles about this](http://nguterresn.github.io/content/sensor-monitoring-fpga-adc-ltc2308-eclipse))

### Updating BSP

To update the BSP the command is the following:

```python
Nios II Command Shell.bat nios2-bsp-generate-files.exe --bsp-dir <path_to_bsp_files> --settings <path_to_settings.bsp>
```

`Nios II Command Shell.bat` opens the Linux terminal necessary to use the followed commands, like `nios2-bsp-generate-files.exe`

**Note:** if the software folder project name is _adcnios_ the BSP directory will be _adcnios_bsp_.

After updating the BSP is now ok to **build** and **run** the C program written.

### Build

To build, run:

```python
Nios II Command Shell.bat make all -C <path to software project folder>
```

The `make` command builds the C file and checks if there is any error!

### Run

**If there are no errors**, it is safe to proceed by running:

```python
Nios II Command Shell.bat nios2-download -g <path to .elf file>
```

The terminal should output some text informing the **processor is being programmed with the new C file and is running.**

**Note:** '-g' enables the processor to run. If the '-g' is not specified, the processor will be paused even though the code is flashed.

## Scripting with Python

To run terminal commands using Python there are a few possibilities. The most part of developers recommend to use the [subprocess library.](https://docs.python.org/3/library/subprocess.html)

By using this library, running a terminal command in python is as easy as:

```python
import subprocess

subprocess.run([quartus_sh , '--flow' , 'compile', ADC_TOP_PATH], shell = True)
```

Inside [ ] is the first command in the Quartus Tools, the equivalent to:

```python
quartus_sh --flow compile <top file>
```

And **ADC_TOP_PATH** is a string variable pointing to the path of the top file of the project.

By using `subprocess` to all of the previous commands, it is possible to get something like this:

```python
import subprocess

## QUARTUS SIDE
# Compiles project
compileFPGA = subprocess.run([QUARTUS_SH, '--flow' , 'compile', ADC_TOP_PATH], shell = True)

# Program FPGA
programFPGA = subprocess.run([QUARTUS_PGM, '-c' , 'USB-Blaster', '-m', 'jtag', '-o', 'p;'+ ADC_SOF], shell = True)

## NIOS2 SIDE
# Update BSP and sent settings
update_bsp = subprocess.run([NIOS2SHELL, 'nios2-bsp-generate-files.exe', '--bsp-dir', ADC_BSP, '--settings', SETTINGS_BSP], shell = True)

# Fix PATH problems
#fix_path = subprocess.run([WSL, 'export', 'WSLENV=PATH/l:${WSLENV}'], shell = True)

# Build Makefile
build = subprocess.run([NIOS2SHELL, 'make', 'all', '-C', WSL_PATH + MAKEFILE], shell = True)

# Run
run = subprocess.run([NIOS2SHELL,'nios2-download','-g', ADC_ELF], shell = True)
```

### Final Code

I've made some variables in order to create an-easy-to-manage-directory-variable-group, *kinda*. So the final code looks something like this:

<script src="https://gist.github.com/nguterresn/9f8d2df685027b63c134b833627d1be7.js"></script>
