set project_origin "../"
set project_work  "work"
set project_name "WasmFpgaCmodA7-35T"
set project_part "xc7a35tcpg236-1"
set project_src  "src"
set project_src_gen "hxs_gen"
set project_venv ".venv"
set project_ip "ip"
set project_tb "tb"
set project_package "package"
set project_scripts "scripts"
set project_constraints "constraints"
set board_design_filepath "${project_work}/${project_name}.srcs/sources_1/bd/WasmFpga/WasmFpga.bd"
set board_design_wrapper_filepath "${project_work}/${project_name}.srcs/sources_1/bd/WasmFpga/hdl/WasmFpga_wrapper.vhd"

proc printMessage {outMsg} {
    puts " --------------------------------------------------------------------------------"
    puts " -- $outMsg"
    puts " --------------------------------------------------------------------------------"
}

printMessage "Project: ${project_name}   Part: ${project_part}   Source Folder: ${project_src}"

# Create project
printMessage "Create the Vivado project"
create_project ${project_name} ${project_work} -part ${project_part} -force

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "${project_work}/${project_name}.cache/ip" -objects $obj
set_property -name "part" -value ${project_part} -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_FIFO XPM_MEMORY" -objects $obj
set_property -name "xsim.array_display_limit" -value "64" -objects $obj

# Need to enable VHDL 2008
set_param project.enableVHDL2008 1

#------------------------------------------------------------------------
printMessage "Set IP repository paths"

set obj [get_filesets sources_1]

set_property ip_repo_paths [list \
  "[file normalize "${project_ip}"]" \
  "[file normalize "${project_venv}"]" \
] $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

#------------------------------------------------------------------------
printMessage "Include VHDL files into project"

if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

set obj [get_filesets sources_1]
set files_vhd [list \
 [file normalize "${project_src}/WasmFpgaTop.vhd" ]\
 [file normalize "${project_src}/WasmFpgaPackage.vhd" ]\
 [file normalize "${project_src}/BlinkGenerator.vhd" ]\
 [file normalize "${project_src}/TimeGenerator.vhd" ]\
]
add_files -norecurse -fileset $obj $files_vhd

foreach i $files_vhd {
    set file_obj [get_files -of_objects [get_filesets sources_1] [file tail [list $i]]]
    set_property -name "file_type" -value "VHDL" -objects $file_obj
}

set file [file normalize "${project_src}/TimeGenerator.vhd"]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "VHDL 2008" -objects $file_obj

set obj [get_filesets sources_1]
set_property -name "top" -value "WasmFpgaTop" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "top_file" -value "${project_src}/WasmFpgaTop.vhd" -objects $obj

#------------------------------------------------------------------------
# Block design and other IP inclusion
printMessage "Adding IP cores..."

set files [list \
 "[file normalize "${project_ip}/SystemClockGenerator/SystemClockGenerator.xci"]"\
 "[file normalize "${project_ip}/SystemResetGenerator/SystemResetGenerator.xci"]"\
]

add_files -fileset sources_1 $files

#------------------------------------------------------------------------
printMessage "Creating block design..."
source "${project_scripts}/wasm_fpga_block_design.tcl"

make_wrapper -files [get_files ${board_design_filepath}] -top
add_files -norecurse -fileset $obj $board_design_wrapper_filepath

#------------------------------------------------------------------------
printMessage "Adding constraint files..."

if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

set files_cons [list \
 "[file normalize "${project_constraints}/WasmFpgaIO.xdc"]"\
 "[file normalize "${project_constraints}/WasmFpgaTiming.xdc"]"\
]

add_files -fileset constrs_1 $files_cons

foreach i $files_cons {
    #puts $i
    set file_obj [get_files -of_objects [get_filesets constrs_1] [list $i]]
    set_property -name "file_type" -value "XDC" -objects $file_obj
    set_property -name "used_in_implementation" -value "1" -objects $file_obj
    set_property -name "used_in_synthesis" -value "1" -objects $file_obj
}

#------------------------------------------------------------------------
printMessage "Adding simulation files..."

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

#------------------------------------------------------------------------
printMessage "Generating project files..."

generate_target all [get_files  "${project_work}/${project_name}.srcs/sources_1/bd/WasmFpga/WasmFpga.bd"]

#------------------------------------------------------------------------
printMessage "Adding files for simulation..."

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
set files [list \
 "[file normalize "${project_tb}/tb_WasmFpgaTop.vhd"]"\
 "[file normalize "${project_tb}/tb_FileIo.vhd"]"\
 "[file normalize "${project_tb}/tb_pkg_helper.vhd"]"\
 "[file normalize "${project_tb}/tb_pkg.vhd"]"\
 "[file normalize "${project_tb}/tb_std_logic_1164_additions.vhd"]"\
 "[file normalize "${project_tb}/tb_Types.vhd"]"\
 "[file normalize "${project_tb}/N25Q128A13E_VG12/include/Decoders.h"]"\
 "[file normalize "${project_tb}/N25Q128A13E_VG12/include/DevParam.h"]"\
 "[file normalize "${project_tb}/N25Q128A13E_VG12/include/PLRSDetectors.h"]"\
 "[file normalize "${project_tb}/N25Q128A13E_VG12/include/StackDecoder.h"]"\
 "[file normalize "${project_tb}/N25Q128A13E_VG12/include/TimingData.h"]"\
 "[file normalize "${project_tb}/N25Q128A13E_VG12/include/UserData.h"]"\
 "[file normalize "${project_tb}/N25Q128A13E_VG12/top/StimTasks.v"]"\
 "[file normalize "${project_tb}/N25Q128A13E_VG12/code/N25Qxxx.v"]"\
 "[file normalize "${project_tb}/N25Q128A13E_VG12/top/ClockGenerator.v"]"\
]
add_files -norecurse -fileset $obj $files

foreach i $files {
    set file_obj [get_files -of_objects [get_filesets sim_1] [list $i]]
    set_property "file_type" "VHDL" $file_obj
}

set file "${project_tb}/N25Q128A13E_VG12/include/Decoders.h"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "Verilog Header" $file_obj

set file "${project_tb}/N25Q128A13E_VG12/include/DevParam.h"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "Verilog Header" $file_obj

set file "${project_tb}/N25Q128A13E_VG12/include/PLRSDetectors.h"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "Verilog Header" $file_obj

set file "${project_tb}/N25Q128A13E_VG12/include/StackDecoder.h"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "Verilog Header" $file_obj

set file "${project_tb}/N25Q128A13E_VG12/include/TimingData.h"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "Verilog Header" $file_obj

set file "${project_tb}/N25Q128A13E_VG12/include/UserData.h"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "Verilog Header" $file_obj

set file "${project_tb}/N25Q128A13E_VG12/top/StimTasks.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "Verilog" $file_obj

set file "${project_tb}/N25Q128A13E_VG12/code/N25Qxxx.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "Verilog" $file_obj

set file "${project_tb}/N25Q128A13E_VG12/top/ClockGenerator.v"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sim_1] [list "*$file"]]
set_property "file_type" "Verilog" $file_obj

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" "tb_WasmFpgaTop" $obj

#------------------------------------------------------------------------
printMessage "Adding constraint files..."

#------------------------------------------------------------------------
close_project -verbose

#------------------------------------------------------------------------
printMessage "Project: ${project_name}   Part: ${project_part}   Source Folder: ${project_src}"
