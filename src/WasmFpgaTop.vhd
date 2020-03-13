library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaPackage.all;

entity WasmFpgaTop is
  port ( 
    Clk : in std_logic;
    nRst : in std_logic;
    Run : in std_logic;
    Step : in std_logic;
    Debug : in std_logic;
    Busy : out std_logic;
    Trap : out std_logic;
    Loaded : out std_logic
  );
end entity WasmFpgaTop;

architecture WasmFpgaArchitecture of WasmFpgaTop is

  component WasmFpga_wrapper is
    port (
      Busy : out std_logic;
      Clk : in std_logic;
      Debug : in std_logic;
      Loaded : out std_logic;
      Run : in std_logic;
      Trap : out std_logic;
      nRst : in std_logic
    );
  end component;

  signal Rst : std_logic;

begin

  Rst <= not nRst;

  WasmFpga_wrapper_i : WasmFpga_wrapper
    port map (
      Busy => Busy,
      Clk => Clk,
      Debug => Debug,
      Loaded => Loaded,
      Run => Run,
      Trap => Trap,
      nRst => nRst
    );

end;
