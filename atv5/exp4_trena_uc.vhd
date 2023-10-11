library ieee;
use ieee.std_logic_1164.all;

entity exp4_trena_uc is
    port (
         clock              : in std_logic;
         reset              : in std_logic;
         mensurar           : in std_logic;
         fim_medida         : in std_logic;
         fim_transmissao    : in std_logic;
         transmissao_pronto : in std_logic;
         transmitir         : out std_logic;
         zera_transmissor   : out std_logic;
         prox_digito        : out std_logic;
         zera_contador      : out std_logic;
         medir              : out std_logic;
         pronto             : out std_logic;
         db_estado          : out std_logic_vector(3 downto 0)
     );
end entity;

architecture arch of exp4_trena_uc is
    type tipo_estado is (inicial, medir_sensor, transmitir_ascii, proximo, final);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    process (clock, mensurar, fim_medida, fim_transmissao, transmissao_pronto) 
    begin
      case Eatual is
        when inicial           =>   if mensurar='1' then    Eprox <= medir_sensor;
                                    else                 Eprox <= inicial;
                                    end if;

        when medir_sensor =>  if fim_medida= '1' then    Eprox <= transmitir_ascii;
                                   else                  Eprox <= medir_sensor;
                                   end if;

        when transmitir_ascii => if fim_transmissao='1' then Eprox <= proximo;
                                    else        Eprox <= transmitir_ascii;
                                    end if;

        when proximo => if transmissao_pronto='1' then Eprox <= final;
                                 else Eprox <= transmitir_ascii;
                                 end if;

        when final             =>                         Eprox <= inicial;

        when others            =>                         Eprox <= inicial;
      end case;
    end process;

  with Eatual select 
    medir <= '1' when medir_sensor, '0' when others;
  with Eatual select
      transmitir <= '1' when transmitir_ascii, '0' when others;
  with Eatual select
      zera_transmissor <= '1' when proximo, '0' when others;
  with Eatual select
      prox_digito <= '1' when proximo, '0' when others;
  with Eatual select
      zera_contador <= '1' when final, '0' when others;
  with Eatual select
      pronto <= '1' when final, '0' when others;
  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when medir_sensor,
                   "0010" when transmitir_ascii, 
                   "0011" when proximo,
                   "0100" when final, 
                   "1110" when others;

end architecture;
