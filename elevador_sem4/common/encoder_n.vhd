-------------------Laboratorio Digital-------------------------------------
-- Arquivo   : encoder_n.vhd
-- Projeto   : Projeto Elevador
-------------------------------------------------------------------------
-- Descricao : encoder generico para n bits de entrada
-------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     16/03/2023  1.0     Henrique Duran    Encoder n bits
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity encoder_n is
    generic (
        constant N: natural := 5 -- numero de entradas do encoder
    );
    port (
        input  : in  std_logic_vector(N-1 downto 0);
        output : out std_logic_vector(natural(ceil(log2(real(N))))-1 downto 0)
    );
end entity;

architecture behavioral of encoder_n is

    function f_log2 (x : integer) return natural is
        variable i : natural;
    begin
        i := 0;  
        while (2**i < x) and i < 31 loop
            i := i + 1;
        end loop;
        return i;
    end function;

begin
    output <= std_logic_vector(to_unsigned(f_log2(to_integer(unsigned(input))), output'length));
end architecture;