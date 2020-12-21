library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaPackage.all;

entity WasmFpgaTop is
  port (
    Clk12M : in std_logic;
    Rst : in std_logic;
    Run : in std_logic;
    Busy : out std_logic;
    Trap : out std_logic;
    Loaded : out std_logic;
    Active : out std_logic
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

  signal usCount : unsigned (6 downto 0);
  signal msCount : unsigned (9 downto 0);
  signal sCount : unsigned (9 downto 0);
  signal Enable1us : std_logic;
  signal PreEnable1us : std_logic;
  signal Enable1ms : std_logic;
  signal Enable1s : std_logic;

  signal LedCount100ms : unsigned (9 downto 0);
  signal LedCount500ms : unsigned (9 downto 0);

  signal LedPulse100ms : std_logic;
  signal LedPulse500ms : std_logic;

  constant LedCountMax500ms : natural := 1000;
  constant LedDutyCycle500ms : natural := 500;
  constant LedCountMax100ms : natural := 200;
  constant LedDutyCycle100ms : natural := 100;

begin

  nRst <= interconnect_aresetn(0);

  Active <= LedPulse500ms;

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

  WasmFpga_wrapper_i : WasmFpga_wrapper
    port map (
      Busy => Busy,
      Clk => Clk100M,
      Debug => '0',
      Loaded => Loaded,
      Run => Run,
      Trap => Trap,
      nRst => nRst
    );

    LedPulseGen : process (Clk100M, nRst)
    begin
        if nRst = '0' then
            LedCount100ms <= to_unsigned(LedCountMax100ms - 2, LedCount500ms'LENGTH);
            LedCount500ms <= to_unsigned(LedCountMax500ms - 2, LedCount500ms'LENGTH);
        elsif rising_edge(Clk100M) then
            if Enable1ms = '1' then
                if (LedCount500ms = to_unsigned(LedCountMax500ms - 1, LedCount500ms'LENGTH)) then
                    LedCount500ms <= to_unsigned(0, LedCount500ms'LENGTH);
                else
                    LedCount500ms <= LedCount500ms + 1;
                end if;
                if (LedCount100ms = to_unsigned(LedCountMax100ms - 1, LedCount100ms'LENGTH)) then
                    LedCount100ms <= to_unsigned(0, LedCount100ms'LENGTH);
                else
                    LedCount100ms <= LedCount100ms + 1;
                end if;
                if (LedCount500ms < LedDutyCycle500ms) then
                  LedPulse500ms <= '1';
                else
                  LedPulse500ms <= '0';
                end if;
                if (LedCount100ms < LedDutyCycle100ms) then
                  LedPulse100ms <= '1';
                else
                  LedPulse100ms <= '0';
                end if;
            end if;
        end if;
    end process;

    Enable1usGen : process(Clk100M, nRst)
      begin
        if (nRst = '0') then
          usCount <= to_unsigned(96,7);
          Enable1us <= '0';
          PreEnable1us <= '0';
        elsif rising_edge(Clk100M) then
          if (usCount = 100 - 2) then
            PreEnable1us <= '1';
          else
            PreEnable1us <= '0';
          end if;
          if (PreEnable1us = '1') then
            usCount <= to_unsigned(0,7);
          else
            usCount <= usCount + 1;
          end if;
          Enable1us <= PreEnable1us;
        end if;
      end process;

    Enable1msGen : process (Clk100M, nRst)
    begin
      if (nRst = '0') then
        msCount  <= to_unsigned(998,10);
        Enable1ms <= '0';
      elsif rising_edge(Clk100M) then
        Enable1ms <= '0';
        if (PreEnable1us = '1') then
          if (msCount = 1000 - 1) then
            Enable1ms <= '1';
            msCount <= to_unsigned(0,10);
          else
            msCount <= msCount + 1 ;
          end if;
        end if;
      end if;
    end process;

    Enable1sGen : process (Clk100M, nRst)
    begin
      if (nRst = '0') then
        sCount    <= to_unsigned(998,10);
        Enable1s <= '0';
      elsif rising_edge(Clk100M) then
        Enable1s <= '0';
        if (Enable1ms = '1') then
          if (sCount = 1000 - 1) then
            Enable1s <= '1';
            sCount <= to_unsigned(0,10);
          else
            sCount <= sCount + 1 ;
          end if;
        end if;
      end if;
    end process;

end;
