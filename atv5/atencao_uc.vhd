library ieee;
use ieee.std_logic_1164.all;

entity atencao_uc is
  port (
    clock, voltar_in, atencao_in: in std_logic;
    atencao: out std_logic
  );
end entity;

architecture arch of atencao_uc is
  type tipo_estado is (normal, estado_atencao);
  signal Eatual, Eprox: tipo_estado;

begin
  processo_estado: process(clock, voltar_in, atencao_in)
  begin
    if (clock'event and clock = '1') then
      case Eatual is
        when normal =>
          if (atencao_in = '1') then
            Eprox <= estado_atencao;
          else
            Eprox <= normal;
          end if;
        when estado_atencao =>
          if (voltar_in = '1') then
            Eprox <= normal;
          else
            Eprox <= estado_atencao;
          end if;
      end case;
    end if;
  end process;

  processo_atencao: process(Eatual)
  begin
    case Eatual is
      when normal =>
        atencao <= '0';
      when estado_atencao =>
        atencao <= '1';
    end case;
  end process;
end architecture; 