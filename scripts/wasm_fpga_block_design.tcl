
################################################################
# This is a generated script based on design: WasmFpga
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source WasmFpga_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name WasmFpga

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
denisvasilik.com:denisvasilik:wasm_fpga_bus:1.0\
denisvasilik.com:denisvasilik:wasm_fpga_control:1.0\
denisvasilik.com:denisvasilik:wasm_fpga_engine:1.0\
denisvasilik.com:denisvasilik:wasm_fpga_loader:1.0\
denisvasilik.com:denisvasilik:wasm_fpga_module:1.0\
denisvasilik.com:denisvasilik:wasm_fpga_stack:1.0\
denisvasilik.com:denisvasilik:wasm_fpga_store:1.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set Busy [ create_bd_port -dir O Busy ]
  set Clk [ create_bd_port -dir I -type clk Clk ]
  set Debug [ create_bd_port -dir I Debug ]
  set Loaded [ create_bd_port -dir O Loaded ]
  set Run [ create_bd_port -dir I Run ]
  set Trap [ create_bd_port -dir O Trap ]
  set nRst [ create_bd_port -dir I -type rst nRst ]

  # Create instance: wasm_fpga_bus, and set properties
  set wasm_fpga_bus [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_bus:1.0 wasm_fpga_bus ]

  # Create instance: wasm_fpga_control, and set properties
  set wasm_fpga_control [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_control:1.0 wasm_fpga_control ]

  # Create instance: wasm_fpga_engine, and set properties
  set wasm_fpga_engine [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_engine:1.0 wasm_fpga_engine ]

  # Create instance: wasm_fpga_loader, and set properties
  set wasm_fpga_loader [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_loader:1.0 wasm_fpga_loader ]

  # Create instance: wasm_fpga_module_interconnect, and set properties
  set wasm_fpga_module_interconnect [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_interconnect:1.0 wasm_fpga_module_interconnect ]

  # Create instance: wasm_fpga_module_memory, and set properties
  set wasm_fpga_module_memory [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_module:1.0 wasm_fpga_module_memory ]

  # Create instance: wasm_fpga_stack, and set properties
  set wasm_fpga_stack [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_stack:1.0 wasm_fpga_stack ]

  # Create instance: wasm_fpga_store, and set properties
  set wasm_fpga_store [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_store:1.0 wasm_fpga_store ]

  # Create instance: wasm_fpga_store_interconnect, and set properties
  set wasm_fpga_store_interconnect [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_interconnect:1.0 wasm_fpga_store_interconnect ]

  # Create instance: wasm_fpga_store_memory, and set properties
  set wasm_fpga_store_memory [ create_bd_cell -type ip -vlnv denisvasilik.com:denisvasilik:wasm_fpga_module:1.0 wasm_fpga_store_memory ]

  # Create interface connections
  connect_bd_intf_net -intf_net wasm_fpga_bus_0_M_MODULE_WB [get_bd_intf_pins wasm_fpga_bus/M_MODULE_WB] [get_bd_intf_pins wasm_fpga_module_interconnect/S_WB]
  connect_bd_intf_net -intf_net wasm_fpga_bus_0_M_STACK_WB [get_bd_intf_pins wasm_fpga_bus/M_STACK_WB] [get_bd_intf_pins wasm_fpga_stack/S_WB]
  connect_bd_intf_net -intf_net wasm_fpga_bus_M_STORE_WB [get_bd_intf_pins wasm_fpga_bus/M_STORE_WB] [get_bd_intf_pins wasm_fpga_store_interconnect/S_WB]
  connect_bd_intf_net -intf_net wasm_fpga_control_0_M_ENGINE_WB [get_bd_intf_pins wasm_fpga_control/M_ENGINE_WB] [get_bd_intf_pins wasm_fpga_engine/S_WB]
  connect_bd_intf_net -intf_net wasm_fpga_control_0_M_LOADER_WB [get_bd_intf_pins wasm_fpga_control/M_LOADER_WB] [get_bd_intf_pins wasm_fpga_loader/S_WB]
  connect_bd_intf_net -intf_net wasm_fpga_engine_M_BUS_WB [get_bd_intf_pins wasm_fpga_bus/S_WB] [get_bd_intf_pins wasm_fpga_engine/M_BUS_WB]
  connect_bd_intf_net -intf_net wasm_fpga_loader_M_MODULE_WB [get_bd_intf_pins wasm_fpga_loader/M_MODULE_WB] [get_bd_intf_pins wasm_fpga_module_interconnect/S_LOADER_WB]
  connect_bd_intf_net -intf_net wasm_fpga_loader_M_STORE_WB [get_bd_intf_pins wasm_fpga_loader/M_STORE_WB] [get_bd_intf_pins wasm_fpga_store/S_WB]
  connect_bd_intf_net -intf_net wasm_fpga_module_interconnect_M_MEMORY_WB [get_bd_intf_pins wasm_fpga_module_interconnect/M_MEMORY_WB] [get_bd_intf_pins wasm_fpga_module_memory/S_WB]
  connect_bd_intf_net -intf_net wasm_fpga_store_M_MEMORY_WB [get_bd_intf_pins wasm_fpga_store/M_MEMORY_WB] [get_bd_intf_pins wasm_fpga_store_interconnect/S_LOADER_WB]
  connect_bd_intf_net -intf_net wasm_fpga_store_interconnect_M_MEMORY_WB [get_bd_intf_pins wasm_fpga_store_interconnect/M_MEMORY_WB] [get_bd_intf_pins wasm_fpga_store_memory/S_WB]

  # Create port connections
  connect_bd_net -net Clk_0_1 [get_bd_ports Clk] [get_bd_pins wasm_fpga_bus/Clk] [get_bd_pins wasm_fpga_control/Clk] [get_bd_pins wasm_fpga_engine/Clk] [get_bd_pins wasm_fpga_loader/Clk] [get_bd_pins wasm_fpga_module_memory/Clk] [get_bd_pins wasm_fpga_stack/Clk] [get_bd_pins wasm_fpga_store/Clk] [get_bd_pins wasm_fpga_store_memory/Clk]
  connect_bd_net -net Debug_0_1 [get_bd_ports Debug] [get_bd_pins wasm_fpga_control/Debug]
  connect_bd_net -net Run_0_1 [get_bd_ports Run] [get_bd_pins wasm_fpga_control/Run]
  connect_bd_net -net nRst_0_1 [get_bd_ports nRst] [get_bd_pins wasm_fpga_bus/nRst] [get_bd_pins wasm_fpga_control/nRst] [get_bd_pins wasm_fpga_engine/nRst] [get_bd_pins wasm_fpga_loader/nRst] [get_bd_pins wasm_fpga_module_memory/nRst] [get_bd_pins wasm_fpga_stack/nRst] [get_bd_pins wasm_fpga_store/nRst] [get_bd_pins wasm_fpga_store_memory/nRst]
  connect_bd_net -net wasm_fpga_control_0_Busy [get_bd_ports Busy] [get_bd_pins wasm_fpga_control/Busy]
  connect_bd_net -net wasm_fpga_engine_Trap [get_bd_ports Trap] [get_bd_pins wasm_fpga_engine/Trap]
  connect_bd_net -net wasm_fpga_loader_Loaded [get_bd_ports Loaded] [get_bd_pins wasm_fpga_loader/Loaded] [get_bd_pins wasm_fpga_module_interconnect/Loaded] [get_bd_pins wasm_fpga_store_interconnect/Loaded]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


