library ieee;
use ieee.std_logic_1164.all;

entity transmissor_uc is
    port(
        clock, reset: in std_logic;
        fim_medida: in std_logic;
        fim_transmissao: in std_logic;
        reseta_transmissor: out std_logic;
        transmitir: out std_logic;
        tx_step: out std_logic_vector(1 downto 0)
    );
end entity;

architecture arch of transmissor_uc is
    type tipo_estado is (inicial, espera_fim_medida, tx_andar,
        tx_hashtag, tx_porta, tx_virgula, final);
    signal Eatual, Eprox: tipo_estado;
begin
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

    process (clock, fim_medida, fim_transmissao)
    begin
        case Eatual is
            when inicial => Eprox <= espera_fim_medida;
            when espera_fim_medida =>
                if fim_medida = '1' then
                    Eprox <= tx_andar;
                else
                    Eprox <= espera_fim_medida;
                end if;
            when tx_andar =>
                if fim_transmissao = '1' then
                    Eprox <= tx_hashtag;
                else
                    Eprox <= tx_andar;
                end if;
            when tx_hashtag =>
                if fim_transmissao = '1' then
                    Eprox <= tx_porta;
                else
                    Eprox <= tx_hashtag;
                end if;
            when tx_porta =>
                if fim_transmissao = '1' then
                    Eprox <= tx_virgula;
                else
                    Eprox <= tx_porta;
                end if;
            when tx_virgula =>
                if fim_transmissao = '1' then
                    Eprox <= final;
                else
                    Eprox <= tx_virgula;
                end if;
            when final => Eprox <= inicial;
        end case;
    end process;

    with Eatual select
        reseta_transmissor <= '1' when inicial,
        '0' when others;
    with Eatual select
        tx_step <=
        "00" when tx_andar,
        "01" when tx_hashtag,
        "10" when tx_porta,
        "11" when tx_virgula,
        "00" when others;
    with Eatual select
        transmitir <= '1' when tx_andar | tx_hashtag | tx_porta | tx_virgula,
        '0' when others;

end architecture;
