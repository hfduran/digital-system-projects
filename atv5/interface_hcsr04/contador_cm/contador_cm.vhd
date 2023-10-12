library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_cm is
generic (
    constant R : integer;
    constant N : integer
);
port (
    clock   : in  std_logic;
    reset   : in  std_logic;
    pulso   : in  std_logic;
    digito0 : out std_logic_vector(3 downto 0);
    digito1 : out std_logic_vector(3 downto 0);
    digito2 : out std_logic_vector(3 downto 0);
    fim     : out std_logic;
    pronto  : out std_logic
);
end entity;

architecture arch of contador_cm is
    component contador_cm_uc is 
        port ( 
            clock       : in  std_logic;
            reset       : in  std_logic;
            tick        : in  std_logic;
            pulso       : in  std_logic;
            zera        : out std_logic;
            conta       : out std_logic;
            pronto      : out std_logic;
            db_estado   : out std_logic_vector(3 downto 0)
        );
    end component;

    component contador_bcd_3digitos is 
        port ( 
            clock   : in  std_logic;
            zera    : in  std_logic;
            conta   : in  std_logic;
            digito0 : out std_logic_vector(3 downto 0);
            digito1 : out std_logic_vector(3 downto 0);
            digito2 : out std_logic_vector(3 downto 0);
            fim     : out std_logic
        );
    end component;

    component contador_m is
        generic (
            constant M : integer := 50;  
            constant N : integer := 6 
        );
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector (N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component contador_m;

    signal s_clock, s_zera, s_conta, s_tick: std_logic;

begin
    s_clock <= clock;
    UC: contador_cm_uc
        port map(
            clock       => s_clock,
            reset       => reset,
            pulso       => pulso,
            tick        => s_tick,
            conta       => s_conta,
            zera        => s_zera,
            pronto      => pronto,
            db_estado   => open
        );

    CM: contador_m
        generic map (
            M => R,
            N => N
        )
        port map (
            clock => s_clock,
            zera  => s_zera,
            conta => '1',
            Q     => open,
            fim   => open,
            meio  => s_tick
        );
        
    CBCD: contador_bcd_3digitos
        port map (
            clock   => s_clock,
            zera    => s_zera,
            conta   => s_conta,
            digito0 => digito0,
            digito1 => digito1,
            digito2 => digito2,
            fim     => fim
        );
end architecture;