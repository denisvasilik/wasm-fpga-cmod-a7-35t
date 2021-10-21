# WebAssembly FPGA Runtime for CMOD A7-35T

Top level project of the WebAssembly runtime for the [CMOD A7-35T] evaluation board.
Its a thin layer consisting of a top level and block design. The block design
brings everything together to build the WebAssemby runtime. The following IPs are
part of it:

* [WebAssembly Control]
* [WebAssembly Loader]
* [WebAssembly Engine]
* [WebAssembly Stack]
* [WebAssembly Store]
* [WebAssembly Bus]
* [WebAssembly Interconnect]
* [WebAssembly Memory]
* [WebAssembly Flash]
* [WebAssembly Debug]

## Documents

* [CMOD A7 Data Sheet]
* [CMOD A7 Schematic]
* [CMOD A7 Master XDC File]
* [CMOD A7 Reference Manual]

## Prerequisites

* Vivado 2019.2
* [The WebAssembly Binary Toolkit]

## Development

In order to work on the WebAssembly FPGA a workspace must be set up according to
the following instructions.

```console
~$ sudo apt-get install python3.6 python3-pip python3-venv python3-wheel
```

Setup a virtual environment that installs the dependencies.

```console
~$ python3 -m venv .venv
~$ source .venv/bin/activate
~$ pip3 install wheel
~$ pip3 install -r requirements.txt
```

Afterwards, the make target `project` sets up the Vivado project that is used
for development.

```bash
~$ make project
```

The make target `build` is used create a bitstream and `XSA` file. Both files can
be found in the `work` folder.

```bash
~$ make build
```

# Flash

TBD

[CMOD A7-35T]: https://store.digilentinc.com/cmod-a7-breadboardable-artix-7-fpga-module/
[WebAssembly Control]: https://github.com/denisvasilik/wasm-fpga-control
[WebAssembly Loader]: https://github.com/denisvasilik/wasm-fpga-loader
[WebAssembly Engine]: https://github.com/denisvasilik/wasm-fpga-engine
[WebAssembly Stack]: https://github.com/denisvasilik/wasm-fpga-stack
[WebAssembly Store]: https://github.com/denisvasilik/wasm-fpga-store
[WebAssembly Bus]: https://github.com/denisvasilik/wasm-fpga-bus
[WebAssembly Interconnect]: https://github.com/denisvasilik/wasm-fpga-interconnect
[WebAssembly Memory]: https://github.com/denisvasilik/wasm-fpga-memory
[WebAssembly Flash]: https://github.com/denisvasilik/wasm-fpga-flash
[WebAssembly Debug]: https://github.com/denisvasilik/wasm-fpga-debug
[CMOD A7 Master XDC File]: https://github.com/Digilent/digilent-xdc/blob/master/Cmod-A7-Master.xdc
[CMOD A7 Schematic]: https://reference.digilentinc.com/_media/reference/programmable-logic/cmod-a7/cmod_a7_sch.pdf
[CMOD A7 Data Sheet]: https://www.xilinx.com/support/documentation/data_sheets/ds181_Artix_7_Data_Sheet.pdf
[CMOD A7 Reference Manual]: https://reference.digilentinc.com/reference/programmable-logic/cmod-a7/reference-manual
[The WebAssembly Binary Toolkit]: https://github.com/WebAssembly/wabt