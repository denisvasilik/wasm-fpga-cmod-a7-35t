# WebAssembly FPGA Runtime for CMOD A7-35T

Top level project of the WebAssembly runtime for the [CMOD A7-35T] evaluation board.
Its a thin layer consisting of a top level and block design. The block design
brings everything together to build the WebAssemby runtime. The following IPs are
part of it:

* WebAssembly Control
* WebAssembly Loader
* WebAssembly Engine
* WebAssembly Stack
* WebAssembly Store
* WebAssembly Bus
* WebAssembly Interconnect
* WebAssembly Memory

## Prerequisites

* Vivado 2019.2

## Build

This repository contains a Makefile that offers some targets for convenience.

### Create Vivado project

The `project` target sets up the Vivado project for development.

    ~$ make project

### Write board design to TCL script

The Make target `write_block_design` is used to write changes of the block design
to the file `scripts/wasm_fpga_block_design.tcl`.

    ~$ make write_block_design

### Clean

The target `clean` removes temporary files or files that are not under version 
control.

    ~$ make clean

## Known Issues

Bitstream cannot be created since the project is experimental and under development.

[CMOD A7-35T]:https://store.digilentinc.com/cmod-a7-breadboardable-artix-7-fpga-module/
