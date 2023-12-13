--------------------------------------------------------------------
-- Arquivo   : interface_hcsr04_uc.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : unidade de controle do circuito de interface com
--             sensor de distancia
--             
--             implementa arredondamento da medida
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     03/09/2022  1.1     Edson Midorikawa  revisao
--------------------------------------------------------------------
--

library IEEE;
use IEEE.std_logic_1164.all;

entity interface_hcsr04_uc is 
    port ( 
        clock      : in  std_logic;
        reset      : in  std_logic;
        medir      : in  std_logic;
        echo       : in  std_logic;
        fim_medida : in  std_logic;
        zera       : out std_logic;
        gera       : out std_logic;
        registra   : out std_logic;
        pronto     : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0) 
    );
end interface_hcsr04_uc;

architecture fsm_arch of interface_hcsr04_uc is
    type tipo_estado is (inicial, preparacao, envia_trigger, 
                         espera_echo, medida, armazenamento, final);
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

    -- logica de proximo estado
    -- process (medir, echo, fim_medida, Eatual, clock) 
    -- begin
    --   case Eatual is
    --     when inicial =>         if medir='1' then Eprox <= preparacao;
    --                             else              Eprox <= inicial;
    --                             end if;
    --     when preparacao =>      Eprox <= envia_trigger;
    --     when envia_trigger =>   Eprox <= espera_echo;
    --     when espera_echo =>     if echo='0' and medir='0' then Eprox <= espera_echo;
    --                             elsif medir='1' then Eprox <= preparacao;
    --                             else Eprox <= medida;
    --                             end if;
    --     when medida =>          if fim_medida='1' then Eprox <= armazenamento;
    --                             elsif medir='1' then Eprox <= preparacao;
    --                             else                   Eprox <= medida;
    --                             end if;
    --     when armazenamento =>   Eprox <= final;
    --     when final =>           Eprox <= inicial;
    --     when others =>          Eprox <= inicial;
    --   end case;
    -- end process;

    Eprox <=
        inicial         when    (Eatual = final)                        or
                                (Eatual = inicial and medir='0')        else
        preparacao      when    (Eatual = inicial and medir = '1')      or
                                (Eatual = espera_echo and medir='1')    or
                                (Eatual = medida and medir='1')         else
        envia_trigger   when    (Eatual = preparacao)                   else
        espera_echo     when    (Eatual = envia_trigger)                or
                                (Eatual = espera_echo and echo = '0' and medir = '0') else
        medida          when    (Eatual = espera_echo and echo='1')     or
                                (Eatual = medida and fim_medida = '0')  else
        armazenamento   when    (Eatual = medida and fim_medida = '1')  else
        final           when    (Eatual = armazenamento)                else
        inicial;
        

  -- saidas de controle
  with Eatual select 
--      zera <= '1' when inicial | preparacao, '0' when others;
      zera <= '1' when preparacao, '0' when others;
  with Eatual select
      gera <= '1' when envia_trigger, '0' when others;
  with Eatual select
      registra <= '1' when armazenamento, '0' when others;
  with Eatual select
      pronto <= '1' when final, '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial, 
                   "0001" when preparacao, 
                   "0010" when envia_trigger, 
                   "0011" when espera_echo,
                   "0100" when medida, 
                   "0101" when armazenamento, 
                   "1111" when final, 
                   "1110" when others;

end architecture fsm_arch;
