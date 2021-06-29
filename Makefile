MICRON_MODEL_LINK=https://media-www.micron.com/-/media/client/global/documents/products/sim-model/nor-flash/serial/bfm/n25q/n25q128a13e_3v_micronxip_vg12,-d-,tar.gz
PWD=$(shell pwd)

all: project

convert:
	wat2wasm resources/WasmFpgaModule.wat -o resources/WasmFpgaModule.wasm
	wat2wasm resources/WasmFpgaModule.wat -v 2> resources/WasmFpgaModule.txt
	rm WasmFpgaModule.wasm

prepare:
	@mkdir -p work
	@mkdir -p resources
	curl ${MICRON_MODEL_LINK} -o resources/n25q128a13e_3v_micronxip_vg12.tar.gz
	tar -xf resources/n25q128a13e_3v_micronxip_vg12.tar.gz -C ./tb
	patch tb/N25Q128A13E_VG12/code/N25Qxxx.v patches/0001-Fix-N25Qxxx-for-VHDL-simulation.patch
	sed -i "s,include/,,g" tb/N25Q128A13E_VG12/include/DevParam.h
	sed -i "s,include/,,g" tb/N25Q128A13E_VG12/include/Decoders.h
	sed -i "s,mem_Q128_bottom.vmf,../../../../../resources/mem.vmf,g" tb/N25Q128A13E_VG12/include/UserData.h
	sed -i "s,sfdp.vmf,../../../../../resources/sfdp.vmf,g" tb/N25Q128A13E_VG12/include/UserData.h

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

create-flash:
	cp work/WasmFpgaCmodA7-35T.runs/impl_1/WasmFpgaTop.bit resources/WasmFpgaTop.bit
	@vivado -mode batch \
			-source scripts/create_flash.tcl \
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
