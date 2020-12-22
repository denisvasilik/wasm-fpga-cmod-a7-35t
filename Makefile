PWD=$(shell pwd)

all: project

prepare:
	@mkdir -p work

prepare-dependencies:
	(cd ../wasm-fpga-bus && make hxs)
	(cd ../wasm-fpga-engine && make hxs)
	(cd ../wasm-fpga-loader && make hxs)
	(cd ../wasm-fpga-store && make hxs)
	(cd ../wasm-fpga-stack && make hxs)
	(cd ../wasm-fpga-uart && make hxs)

project: prepare prepare-dependencies
	@vivado -mode batch \
			-source scripts/create_project.tcl \
			-notrace \
			-nojournal \
			-tempDir work \
			-log work/vivado.log

write_block_design:
	@vivado -mode batch \
		-source scripts/write_block_design.tcl \
		-notrace \
		-nojournal \
		-tempDir work \
		-log work/vivado.log

clean:
	@find ip ! -iname *.xci -type f -exec rm {} +
	@rm -rf .Xil vivado*.log vivado*.str vivado*.jou
	@rm -rf work \
		src-gen \
		hxs_gen \
		*.egg-info \
		dist \
	@rm -rf ip/**/hdl \
		ip/**/synth \
		ip/**/example_design \
		ip/**/sim \
		ip/**/simulation \
		ip/**/misc \
		ip/**/doc

.PHONY: all prepare project clean
