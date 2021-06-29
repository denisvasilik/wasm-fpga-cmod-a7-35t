library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaPackage.all;

entity WasmFpgaTop is
  port (
    Clk12M : in std_logic;
    Rst : in std_logic;
    Trap : out std_logic;
    Loaded : out std_logic;
    UartRx : in std_logic;
    UartTx : out std_logic;
    MiSo : in std_logic;
    MoSi : out std_logic;
    SClk : out std_logic;
    nCs : out std_logic;
    nWp : out std_logic;
    nHold : out std_logic;
    Active : out std_logic
  );
end;

architecture WasmFpgaArchitecture of WasmFpgaTop is

  component SystemClockGenerator is
    port (
      Clk100M : out std_logic;
      reset : in std_logic;
      locked : out std_logic;
      Clk12M : in std_logic
    );
  end component;

  component SystemResetGenerator is
    port (
      slowest_sync_clk : in std_logic;
      ext_reset_in : in std_logic;
      aux_reset_in : in std_logic;
      mb_debug_sys_rst : in std_logic;
      dcm_locked : in std_logic;
      mb_reset : out std_logic;
      bus_struct_reset : out std_logic_vector (0 to 0);
      peripheral_reset: out std_logic_vector (0 to 0);
      interconnect_aresetn : out std_logic_vector (0 to 0);
      peripheral_aresetn : out std_logic_vector (0 to 0)
    );
  end component;

  signal Clk100M : std_logic;
  signal nRst : std_logic;
  signal interconnect_aresetn : std_logic_vector(0 downto 0);
  signal Locked : std_logic;
  signal Enable1ms : std_logic;

begin

  nRst <= interconnect_aresetn(0);

  nWp <= '1';
  nHold <= '1';

  SystemClockGenerator_i : SystemClockGenerator
    port map (
      Clk100M => Clk100M,
      reset => Rst,
      locked => Locked,
      Clk12M => Clk12M
    );

  SystemResetGenerator_i : SystemResetGenerator
    port map (
      slowest_sync_clk => Clk100M,
      ext_reset_in => Rst,
      aux_reset_in => '0',
      mb_debug_sys_rst => '0',
      dcm_locked => Locked,
      mb_reset => open,
      bus_struct_reset => open,
      peripheral_reset => open,
      interconnect_aresetn => interconnect_aresetn,
      peripheral_aresetn => open
  );

  WasmFpga_wrapper_i : entity work.WasmFpga_wrapper
    port map (
      Clk => Clk100M,
      nCs => nCs,
      Loaded => Loaded,
      MiSo => MiSo,
      MoSi => MoSi,
      SClk => SClk,
      Trap => Trap,
      UartRx => UartRx,
      UartTx => UartTx,
      nRst => nRst
    );

  LedBlink500ms_i : entity work.BlinkGenerator
    generic map (
      DutyCycle => 500
    )
    port map (
      Clk => Clk100M,
      nRst => nRst,
      Enable1ms => Enable1ms,
      BlinkSignal => Active
    );

  TimeGenerator_i : entity work.TimeGenerator
    port map (
      Clk => Clk100M,
      nRst => nRst,
      Enable1us => open,
      Enable1ms => Enable1ms,
      Enable1s => open
    );

end;
