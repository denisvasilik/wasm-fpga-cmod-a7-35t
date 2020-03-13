PWD=$(shell pwd)

all: project

prepare:
	@mkdir -p work

project: prepare
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
	@rm -rf .Xil \
		vivado*.log \
		vivado*.str \
		vivado*.jou \
		work \

.PHONY: all prepare project clean
