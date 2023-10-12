library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm_uc is 
    port ( 
        clock       : in  std_logic;
        reset       : in  std_logic;
        tick        : in  std_logic;
        pulso       : in  std_logic;
        zera        : out std_logic;
        conta       : out std_logic;
        pronto      : out std_logic;
        db_estado   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture fsm_arch of contador_cm_uc is
    type tipo_estado is (
        inicial,
        preparacao,
        espera,
        contagem,
        final
    );
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
    process (pulso, tick, Eatual) 
    begin
        case Eatual is
            when inicial    =>      if pulso='1'    then Eprox <= preparacao;
                                    else            Eprox <= inicial;
                                    end if;
            when preparacao =>                      Eprox <= espera;
            when espera     =>      if tick='1'     then Eprox <= contagem;
                                    elsif pulso='0' then Eprox <= final;
                                    else            Eprox <= espera;
                                    end if;
            when contagem   =>      Eprox <= espera;
            when final      =>      Eprox <= inicial;
            when others     =>      Eprox <= inicial;
        end case;
    end process;

    -- saidas de controle
    with Eatual select 
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    with Eatual select
        conta <= '1' when contagem, '0' when others;

    with Eatual select
        db_estado <= "0000" when inicial, 
                    "0001" when preparacao,
                    "0010" when espera,
                        "0011" when contagem,
                    "1111" when final, 
                    "1110" when others;

end architecture fsm_arch;