library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prox_andar is
    port (
        dados : in std_logic_vector(4 downto 0);
        direction : in std_logic;
        atual : in std_logic_vector(2 downto 0);
        prox : out std_logic_vector(2 downto 0)
    );
end entity;

architecture behavioral of prox_andar is
    signal next_up : std_logic_vector(2 downto 0);
    signal next_down : std_logic_vector(2 downto 0);
begin

    up_proc: process(dados, next_up, atual)
        variable exited : std_logic := '0';
    begin
        for i in 0 to 4 loop
            if dados(i) = '1' and to_integer(unsigned(atual)) <= i then
                next_up <= std_logic_vector(to_unsigned(i, next_up'length));
                exited := '1';
                exit;
            end if;
        end loop;
        if exited = '0' then
            next_up <= atual;
        end if;
    end process;

    down_proc: process(dados, next_down, atual)
        variable exited : std_logic := '0';
    begin
        for i in 4 downto 0 loop
            if dados(i) = '1' and (to_integer(unsigned(atual)) >= i) then
                next_down <= std_logic_vector(to_unsigned(i, next_down'length));
                exited := '1';
                exit;
            end if;
        end loop;
        if exited = '0' then
            next_down <= atual;
        end if;
    end process;
    
    with direction select prox <=
        next_up when '1',
        next_down when '0',
        next_up when others;

end architecture;
