library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparador is
  generic (
    constant N : integer := 7
  );
  port (
    a, b : in std_logic_vector(N-1 downto 0);
    eq : out std_logic
  );
end entity;

architecture arch of comparador is
begin
  eq <= '1' when a = b else '0';
end architecture;