set project_work "work"
set project_name "WasmFpgaCmodA7-35T"
set project_scripts "scripts"
set board_design_filepath "${project_work}/${project_name}.srcs/sources_1/bd/WasmFpga/WasmFpga.bd"

open_project ${project_work}/WasmFpgaCmodA7-35T.xpr
open_bd_design ${board_design_filepath}
validate_bd_design -force
write_bd_tcl -include_layout ${project_scripts}/wasm_fpga_block_design.tcl -force
close_project -verbose