library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package tb_Types is

    type T_WasmFpga_FileIo is
    record
        Busy : std_logic;
        Trap : std_logic;
        Loaded : std_logic;
    end record;

    type T_FileIo_WasmFpga is
    record
        Run : std_logic;
        Step : std_logic;
        Debug : std_logic;
    end record;

end package;

package body tb_Types is

end package body;
