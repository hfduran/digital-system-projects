-------------------------------------------------------------------
-- Arquivo   : banco_registradores.vhd
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_registradores is
    port (
        clk : in std_logic;
        registra : in std_logic;
        limpa : in std_logic;
        reset : in std_logic;
        dados_entrada : in std_logic_vector(2 downto 0);
        dados_saida : out std_logic_vector(4 downto 0)
    );
end entity;

architecture modelsim of banco_registradores is
    signal memoria : std_logic_vector(4 downto 0) := (others => '0');
begin
    process(clk, reset, limpa, registra, dados_entrada)
    begin
        if (rising_edge(clk)) then
            if reset = '1' then
                memoria <= (others => '0');
            elsif limpa = '1' then
                memoria(to_integer(unsigned(dados_entrada))) <= '0';
            elsif registra = '1' then
                memoria(to_integer(unsigned(dados_entrada))) <= '1';
            end if;
        end if;
    end process;

    dados_saida <= memoria;

end architecture;