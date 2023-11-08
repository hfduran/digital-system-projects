-----------------Laboratorio Digital-------------------------------------
-- Arquivo   : comparador_n.vhd
-- Projeto   : Experiencia 6 - Jogo do Desafio da Memória
-------------------------------------------------------------------------
-- Descricao : comparador com numero de bits (N) como generic
--             
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2019  1.0     Edson Midorikawa  criacao
--     30/09/2022  1.4     Edson Midorikawa  revisao do codigo
--     07/03/2023  1.5     Edson Midorikawa  revisao do codigo
-------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity comparador_n is
    generic (
        constant N: integer := 8
    );
    port (
        A     : in  std_logic_vector (N-1 downto 0);
        B     : in  std_logic_vector (N-1 downto 0);
        igual : out std_logic;
        menor : out std_logic;
        maior : out std_logic
    );
end entity;

architecture comportamental of comparador_n is
begin

    igual <= '1' when A=B else
             '0';

    menor <= '1' when A<B else
             '0';

    maior <= '1' when A>B else
             '0';
  
end architecture;


