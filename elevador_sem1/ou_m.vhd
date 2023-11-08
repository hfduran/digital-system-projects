library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ou_m is
    generic (
        constant M : natural := 5
    );
    port (
        entrada : in std_logic_vector(M-1 downto 0);
        saida : out std_logic
    );
end entity;

architecture behavioral of ou_m is
    --signal temp : std_logic;
begin
    process(entrada)
    begin
        saida <= '0';
	    --temp <= '0';
        for i in 0 to M-1 loop
            if entrada(i) = '1' then
                saida <= '1';
                exit;
            end if;
            --temp <= temp or entrada(i);
        end loop;
        --saida <= temp;
    end process;
end architecture;
