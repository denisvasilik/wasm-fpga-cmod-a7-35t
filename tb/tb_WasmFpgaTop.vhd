library IEEE;
use IEEE.STD_LOGIC_1164.all;

use IEEE.NUMERIC_STD.all;

library work;
use work.tb_types.all;

entity tb_WasmFpgaTop is
  generic (
    stimulus_path : string := "../../../../../simstm/";
    stimulus_file : string := "WasmFpga.stm"
  );
end;

architecture behavioural of tb_WasmFpgaTop is

    constant CLK100M_PERIOD : time := 10 ns;

    signal Clk100M : std_logic := '0';
    signal Rst : std_logic := '1';
    signal nRst : std_logic := '0';

    signal WasmFpga_FileIo : T_WasmFpga_FileIo;
    signal FileIo_WasmFpga : T_FileIo_WasmFpga;

begin

    nRst <= not Rst;

    Clk100MGen : process is
    begin
        Clk100M <= not Clk100M;
        wait for CLK100M_PERIOD / 2;
    end process;

    RstGen : process is
    begin
        Rst <= '1';
        wait for 100ns;
        Rst <= '0';
        wait;
    end process;

    tb_FileIo_i : entity work.tb_FileIo
        generic map (
            stimulus_path => stimulus_path,
            stimulus_file => stimulus_file
        )
        port map (
            Clk => Clk100M,
            Rst => Rst,
            WasmFpga_FileIo => WasmFpga_FileIo,
            FileIo_WasmFpga => FileIo_WasmFpga
        );

    WasmFpgaTop_i : entity work.WasmFpgaTop
        port map (
            Clk12M => Clk100M,
            Rst => Rst,
            Run => FileIo_WasmFpga.Run,
            Busy => WasmFpga_FileIo.Busy,
            Trap => WasmFpga_FileIo.Trap,
            Loaded => WasmFpga_FileIo.Loaded,
            Active => open,
            UartRx => '0',
            UartTx => open
       );

end;
