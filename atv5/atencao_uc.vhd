library ieee;
use ieee.std_logic_1164.all;

entity atencao_uc is
  port (
    clock, reset, voltar_in, atencao_in: in std_logic;
    atencao, db_estado: out std_logic
  );
end entity;

architecture arch of atencao_uc is
  type tipo_estado is (normal, atencionado);
  signal Eatual, Eprox: tipo_estado;
begin
  process(reset, clock)
  begin
    if reset = '1' then
      Eatual <= normal;
    elsif rising_edge(clock) then
      Eatual <= Eprox;
    end if;
  end process;

  process(clock, atencao_in, voltar_in)
  begin
    case Eatual is
      when normal =>
        if atencao_in = '1' then
          Eprox <= atencionado;
        else
          Eprox <= normal;
        end if;
      when atencionado =>
        if voltar_in = '1' then
          Eprox <= normal;
        else
          Eprox <= atencionado;
        end if;
      when others => Eprox <= normal;
    end case;
  end process;

  with Eatual select atencao <= '1' when atencionado, '0' when others;
  with Eatual select db_estado <= '1' when atencionado, '0' when others;
end architecture; 