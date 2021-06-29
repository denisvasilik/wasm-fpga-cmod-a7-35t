library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.WasmFpgaPackage.all;

entity TimeGenerator is
  port (
    Clk : in std_logic;
    nRst : in std_logic;
    Enable1us : out std_logic;
    Enable1ms : out std_logic;
    Enable1s : out std_logic
  );
end;

architecture TimeGeneratorDefault of TimeGenerator is

  signal PreEnable1us : std_logic;

begin

    Enable1usGenerator : process(Clk, nRst)
      variable usCount : unsigned (6 downto 0);
    begin
        if nRst = '0' then
          usCount := to_unsigned(96,7);
          Enable1us <= '0';
          PreEnable1us <= '0';
        elsif rising_edge(Clk) then
          if (usCount = 100 - 2) then
            PreEnable1us <= '1';
          else
            PreEnable1us <= '0';
          end if;
          if (PreEnable1us = '1') then
            usCount := to_unsigned(0,7);
          else
            usCount := usCount + 1;
          end if;
          Enable1us <= PreEnable1us;
        end if;
      end process;

    Enable1msGenerator : process (Clk, nRst)
      variable msCount : unsigned (9 downto 0);
    begin
      if nRst = '0' then
        msCount := to_unsigned(998,10);
        Enable1ms <= '0';
      elsif rising_edge(Clk) then
        Enable1ms <= '0';
        if (PreEnable1us = '1') then
          if (msCount = 1000 - 1) then
            Enable1ms <= '1';
            msCount := to_unsigned(0,10);
          else
            msCount := msCount + 1 ;
          end if;
        end if;
      end if;
    end process;

    Enable1sGenerator : process (Clk, nRst)
      variable sCount : unsigned (9 downto 0);
    begin
      if nRst = '0' then
        sCount := to_unsigned(998,10);
        Enable1s <= '0';
      elsif rising_edge(Clk) then
        Enable1s <= '0';
        if (Enable1ms = '1') then
          if (sCount = 1000 - 1) then
            Enable1s <= '1';
            sCount := to_unsigned(0,10);
          else
            sCount := sCount + 1 ;
          end if;
        end if;
      end if;
    end process;

end;
