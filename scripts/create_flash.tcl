set origin_dir "."
set bitstream_filepath "[file normalize "$origin_dir/resources/WasmFpgaTop.bit"]"
set wasm_filepath "[file normalize "$origin_dir/resources/WasmFpgaModule.wasm"]"
set mcs_filepath "[file normalize "$origin_dir/resources/WasmFpgaTop.mcs"]"
open_project "[file normalize "$origin_dir/work/WasmFpgaCmodA7-35T.xpr"]"
write_cfgmem -format mcs -interface spix1 -size 16 -loadbit "up 0x0 $bitstream_filepath" -loaddata "up 0x300000 $wasm_filepath" -file $mcs_filepath -force
