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

    constant CLK12M_PERIOD : time := 83.333 ns;

    signal Clk12M : std_logic := '0';
    signal Rst : std_logic := '1';
    signal nRst : std_logic := '0';

    signal WasmFpga_FileIo : T_WasmFpga_FileIo;
    signal FileIo_WasmFpga : T_FileIo_WasmFpga;

    signal SpiFlash_MiSo : std_logic;
    signal SpiFlash_MoSi : std_logic;
    signal SpiFlash_SClk : std_logic;
    signal SpiFlash_CsNeg : std_logic;
    signal SpiFlash_nWp : std_logic;
    signal SpiFlash_nHold : std_logic;

begin

    nRst <= not Rst;

    WasmFpga_FileIo.Busy <= '0';

    Clk12MGen : process is
    begin
        Clk12M <= not Clk12M;
        wait for CLK12M_PERIOD / 2;
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
            Clk => Clk12M,
            Rst => Rst,
            WasmFpga_FileIo => WasmFpga_FileIo,
            FileIo_WasmFpga => FileIo_WasmFpga
        );

    WasmFpgaTop_i : entity work.WasmFpgaTop
        port map (
            Clk12M => Clk12M,
            Rst => Rst,
            Trap => WasmFpga_FileIo.Trap,
            Loaded => WasmFpga_FileIo.Loaded,
            UartRx => '0',
            UartTx => open,
            MiSo => SpiFlash_MiSo,
            MoSi => SpiFlash_MoSi,
            SClk => SpiFlash_SClk,
            nCs => SpiFlash_CsNeg,
            nWp => SpiFlash_nWp,
            nHold => SpiFlash_nHold,
            Active => open
       );

    N25Q128A13E_i : entity work.N25Qxxx
        port map (
            S => SpiFlash_CsNeg,
            C => SpiFlash_SClk,
            HOLD_DQ3 => SpiFlash_nHold,
            DQ0 => SpiFlash_MoSi,
            DQ1 => SpiFlash_MiSo,
            Vcc => x"00000BB8",
            Vpp_W_DQ2 => SpiFlash_nWp
        );

end;
