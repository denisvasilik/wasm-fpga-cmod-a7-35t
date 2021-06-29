library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity BlinkGenerator is
  generic(
    DutyCycle : natural := 500
  );
  port (
    Clk : in std_logic;
    nRst : in std_logic;
    Enable1ms : in std_logic;
    BlinkSignal : out std_logic
  );
end entity;

architecture BlinkGeneratorDefault of BlinkGenerator is

begin

    BlinkGenerator : process (Clk, nRst)
      variable DutyCycleCount : unsigned (9 downto 0);
      constant DutyCycleMax : natural := DutyCycle * 2;
    begin
        if nRst = '0' then
            BlinkSignal <= '0';
            DutyCycleCount := to_unsigned(DutyCycleMax - 2, DutyCycleCount'LENGTH);
        elsif rising_edge(Clk) then
            if Enable1ms = '1' then
                if (DutyCycleCount < DutyCycle) then
                  BlinkSignal <= '1';
                else
                  BlinkSignal <= '0';
                end if;
                if (DutyCycleCount = to_unsigned(DutyCycleMax - 1, DutyCycleCount'LENGTH)) then
                    DutyCycleCount := to_unsigned(0, DutyCycleCount'LENGTH);
                else
                    DutyCycleCount := DutyCycleCount + 1;
                end if;
            end if;
        end if;
    end process;

end;