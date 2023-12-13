library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
  port (
  clock : in std_logic;
  reset : in std_logic;
  posicao : in std_logic_vector(2 downto 0);
  controle : out std_logic
  );
end entity controle_servo;

architecture estrutural of controle_servo is

  component circuito_pwm is
    generic (
        conf_periodo : integer;
        largura_000   : integer;
        largura_001   : integer;
        largura_010   : integer;
        largura_011   : integer;
        largura_100   : integer;
        largura_101   : integer;
        largura_110   : integer;
        largura_111   : integer
    );
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        largura : in  std_logic_vector(2 downto 0);  
        pwm     : out std_logic 
    );
  end component circuito_pwm;

begin

  PWM: circuito_pwm
  generic map(
    conf_periodo => 1000000,
    largura_000 => 50000,
    largura_001 => 50000,
    largura_010 => 58333,
    largura_011 => 66666,
    largura_100 => 75000,
    largura_101 => 83333,
    largura_110 => 91666,
    largura_111 => 100000
  )
  port map(
    clock => clock,
    reset => '0',
    largura => posicao,
    pwm => controle
  );

end architecture estrutural;