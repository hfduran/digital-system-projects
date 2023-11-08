--------------------------------------------------------------------
-- Arquivo   : unidade_controle.vhd
-- Projeto   : Experiencia 3 - Projeto de uma unidade de controle
--------------------------------------------------------------------
-- Descricao : unidade de controle 
--
--             1) codificação VHDL (maquina de Moore)
--
--             2) definicao de valores da saida de depuracao
--                db_estado
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     20/01/2022  1.0     Edson Midorikawa  versao inicial
--     22/01/2023  1.1     Edson Midorikawa  revisao
--     01/02/2023  2.0     Henrique Duran    desafio
--     05/02/2023  2.1     Henrique Duran    exp 4
--     14/03/2023  3.0     Henrique Duran    Elevador parte 1
--------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is 
    port ( 
        clock     : in  std_logic; 
        reset     : in  std_logic; 
        iniciar   : in  std_logic;
        andarZero : in  std_logic;
        chamouCC  : in  std_logic;
        temChamada: in  std_logic;
        calcDir   : in  std_logic;
        calcDirCC : in  std_logic;
        chegouCima  : in  std_logic;
        chegouBaixo : in std_logic;
        ultimo      : in  std_logic;
        fimT      : in  std_logic;
        contaT    : out std_logic;
        liga      : out std_logic;
        direcao   : out std_logic;
        zeraT     : out std_logic;
        limpaCima : out std_logic;
        limpaBaixo: out std_logic;
        semDir    : out std_logic;
        zeraM     : out std_logic;
		db_estado : out std_logic_vector(3 downto 0)
    );
end entity;

architecture fsm of unidade_controle is
    type t_estado is (Inicial, VaiParaZero, Parado, CalculaDirecao, Sobe, LimpaC, EsperaCima, Desce, LimpaB, EsperaBaixo, Limpa, Espera, CalculaDirecaoCC);
    signal Eatual, Eprox: t_estado;
begin

    -- memoria de estado
    process (clock,reset)
    begin
        if reset='1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    -- logica de proximo estado
    Eprox <=
        Inicial       when  (Eatual=Inicial      and iniciar='0')                    else
        
        VaiParaZero   when  (Eatual=Inicial      and iniciar='1')                    or
                            (Eatual=VaiParaZero  and andarZero='0')                  else

        Parado when (Eatual=VaiParaZero and andarZero='1') or
                    (Eatual=Espera and fimT='1' and chamouCC='0') or
                    (Eatual=Parado and temChamada='0') else

        CalculaDirecao when (Eatual=Parado and temChamada='1') else

        Sobe when (Eatual=CalculaDirecao and calcDir='1') or
                  (Eatual=EsperaCima and fimT='1') or
                  (Eatual=Sobe and chegouCima='0') else

        LimpaC when (Eatual=Sobe and chegouCima='1' and ultimo='0') else

        EsperaCima when (Eatual=LimpaC) or
                        (Eatual=EsperaCima and fimT='0') or
                        (Eatual=CalculaDirecaoCC and calcDirCC='1') else

        Desce when (Eatual=CalculaDirecao and calcDir='0') or
                   (Eatual=EsperaBaixo and fimT='1') or
                   (Eatual=Desce and chegouBaixo='0') else

        LimpaB when (Eatual=Desce and chegouBaixo='1' and ultimo='0') else

        EsperaBaixo when (Eatual=LimpaB) or
                         (Eatual=EsperaBaixo and fimT='0') or
                         (Eatual=CalculaDirecaoCC and calcDirCC='0') else

        Limpa when (Eatual=Sobe and chegouCima='1' and ultimo='1') or
                   (Eatual=Desce and chegouBaixo='1' and ultimo='1') else

        Espera when (Eatual=Limpa) or
                    (Eatual=Espera and chamouCC='0' and fimT='0') else

        CalculaDirecaoCC when (Eatual=Espera and chamouCC='1') else

        Inicial;

    -- logica de saída (maquina de Moore)
    with Eatual select
    zeraM <= '1' when VaiParaZero,
             '0' when others;
    
    with Eatual select
    direcao <= '0' when VaiParaZero|Desce|LimpaB|EsperaBaixo,
               '1' when Sobe|LimpaC|EsperaCima,
               '0' when others;

    with Eatual select
    liga <= '1' when Sobe|Desce|VaiParaZero,
            '0' when others;

    with Eatual select
    limpaCima <= '1' when LimpaC|Limpa,
             '0' when others;

    with Eatual select
    limpaBaixo <= '1' when LimpaB|Limpa,
             '0' when others;

    with Eatual select
    contaT <= '1' when EsperaCima|EsperaBaixo|Espera,
              '0' when others;

    with Eatual select
    zeraT <= '1' when Limpa|LimpaC|LimpaB,
             '0' when others;

    with Eatual select
    semDir <= '1' when Limpa|Espera|CalculaDirecaoCC|CalculaDirecao,
              '0' when others;

    -- saida de depuracao (db_estado)
    with Eatual select
        db_estado <= "0000" when inicial,         -- 0
                     "0001" when VaiParaZero,     -- 1
                     "0010" when Parado,          -- 2
                     "0101" when Sobe,            -- 5
                     "1101" when Desce,           -- d
                     "1001" when EsperaCima,       -- 9
                     "1000" when EsperaBaixo,      -- 8
                     "1110" when Espera,          -- E
                     "1111" when others;          -- F

end architecture fsm;
