library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calcula_andar_atual is
    port(
        clock : in std_logic;
        reset : in std_logic;
        dir : in std_logic;
        centimeters : in unsigned(11 downto 0);
        andar_atual : out std_logic_vector(2 downto 0)
    );
end entity calcula_andar_atual;

architecture rtl of calcula_andar_atual is
    signal s_andar_atual : std_logic_vector(2 downto 0);
begin

    process(centimeters, clock, dir)
    begin
        if(rising_edge(clock)) then
            if (centimeters <= 4 and dir = '0') then
                s_andar_atual <= "000";
            elsif (centimeters <= 14 and dir = '0') then
                s_andar_atual <= "001";
            elsif (centimeters <= 25 and dir = '0') then
                s_andar_atual <= "010";
            elsif (centimeters <= 40 and dir = '0') then
                s_andar_atual <= "011";
            elsif (centimeters >= 40 and dir = '1') then
                s_andar_atual <= "011";
            elsif (centimeters >= 14 and dir = '1') then
                s_andar_atual <= "001";
            elsif (centimeters >= 25 and dir = '1') then
                s_andar_atual <= "010";
            elsif (centimeters >= 4 and dir = '1') then
                s_andar_atual <= "000";
            else
                s_andar_atual <= "100";
            end if;
        end if;
    end process;
    with reset select
        andar_atual <= "000" when '1',
        s_andar_atual when others;
end architecture;