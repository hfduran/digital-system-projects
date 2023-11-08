library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ultimo_andar is
    port (
        andares_chamados : in std_logic_vector(4 downto 0);
        ultimo_andar_cima : out std_logic_vector(2 downto 0);
        ultimo_andar_baixo: out std_logic_vector(2 downto 0)
    );
end entity;

architecture arch of ultimo_andar is

    component prox_andar is
        port (
            dados : in std_logic_vector(4 downto 0);
            direction : in std_logic;
            atual : in std_logic_vector(2 downto 0);
            prox : out std_logic_vector(2 downto 0)
        );
    end component;
    
begin

    subida: prox_andar
    port map(
        dados => andares_chamados,
        direction => '0',
        atual => "100",
        prox => ultimo_andar_cima
    );

    descida: prox_andar
    port map(
        dados => andares_chamados,
        direction => '1',
        atual => "000",
        prox => ultimo_andar_baixo
    );

end architecture;