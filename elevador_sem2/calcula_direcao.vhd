library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calcula_direcao is
    port (
        ultimo_andar_cima : in std_logic_vector(2 downto 0);
        andar_atual : in std_logic_vector(2 downto 0);
        calculo_direcao : out std_logic
    );
end entity;

architecture estrutural of calcula_direcao is
    component comparador_n is
        generic (
            constant N: integer := 3
        );
        port (
            A     : in  std_logic_vector (N-1 downto 0);
            B     : in  std_logic_vector (N-1 downto 0);
            igual : out std_logic;
            menor : out std_logic;
            maior : out std_logic
        );
    end component;

    signal s_menor : std_logic;
    signal s_maior : std_logic;
begin

    comp: comparador_n
    port map(
        A => ultimo_andar_cima,
        B => andar_atual,
        igual => open,
        menor => s_menor,
        maior => s_maior
    );

    calculo_direcao <=
    '1' when (s_maior = '1' and s_menor = '0') else
    '0' when (s_maior = '0' and s_menor = '1') else
    '0';

end architecture;