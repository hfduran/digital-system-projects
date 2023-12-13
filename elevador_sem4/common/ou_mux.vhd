library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ou_mux is
    port (
        dado      : in  std_logic_vector(4 downto 0);
        sel       : in  std_logic_vector(2 downto 0);
        direction : in std_logic;
        saida     : out std_logic
    );
end entity;

architecture behavioral of ou_mux is
    component ou_m is
        generic (
            constant M : natural := 5
        );
        port (
            entrada : in  std_logic_vector(M-1 downto 0);
            saida   : out std_logic
        );
    end component;
    
    signal arr_up : std_logic_vector(4 downto 0);
    signal arr_down : std_logic_vector(4 downto 0);
begin
    -- gera as portas ou para a dir cima
    up_ger: for i in 0 to 4 generate
	ou_up: ou_m
	    generic map (
	    	M => 5 - i
	    )
	    port map (
	    	entrada => dado(4 downto i),
	        saida => arr_up(i)
	    );	    
	end generate;

    -- gera as portas ou para dir baixo
    down_ger: for i in 4 downto 0 generate
	ou_down: ou_m
	    generic map (
	    	M => i + 1
	    )
	    port map (
	    	entrada => dado(i downto 0),
		saida => arr_down(i)
	    );
	end generate;

    with direction select saida <=
        arr_up(to_integer(unsigned(sel))) when '1',
        arr_down(to_integer(unsigned(sel))) when '0',
        '0' when others;

end architecture;
