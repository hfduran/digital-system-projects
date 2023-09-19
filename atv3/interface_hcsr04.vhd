library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interface_hcsr04 is
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        medir     : in  std_logic;
        echo      : in  std_logic;
        trigger   : out std_logic;
        medida    : out std_logic_vector(11 downto 0);
        pronto    : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity;

architecture structural of interface_hcsr04 is

component interface_hcsr04_df is
    port ( 
        clock       : in  std_logic;
        reset       : in  std_logic;
        echo        : in  std_logic;
        gera        : in  std_logic;
        zera        : in  std_logic;
        registra    : in  std_logic;
        trigger     : out std_logic;
        fim_medida  : out std_logic;
        digito0     : out std_logic_vector(3 downto 0);
        digito1     : out std_logic_vector(3 downto 0);
        digito2     : out std_logic_vector(3 downto 0)
    );
end component;

component interface_hcsr04_uc is 
    port ( 
        clock      : in  std_logic;
        reset      : in  std_logic;
        medir      : in  std_logic;
        echo       : in  std_logic;
        fim_medida : in  std_logic;
        zera       : out std_logic;
        gera       : out std_logic;
        registra   : out std_logic;
        pronto     : out std_logic;
        db_estado  : out std_logic_vector(3 downto 0) 
    );
end component;

signal  s_clock, s_reset, s_gera,s_zera,
        s_registra, s_fim_medida, s_echo : std_logic;
begin
    DF: interface_hcsr04_df
        port map (
            clock       => s_clock,
            reset       => s_reset,
            echo        => s_echo,
            gera        => s_gera,
            zera        => s_zera,
            registra    => s_registra,
            trigger     => trigger,
            fim_medida  => s_fim_medida,
            digito0     => medida(3 downto 0),
            digito1     => medida(7 downto 4),
            digito2     => medida(11 downto 8)
        );
    UC: interface_hcsr04_uc
        port map (
            clock      => s_clock,
            reset      => s_reset,
            medir      => medir,
            echo       => s_echo,
            fim_medida => s_fim_medida,
            zera       => s_zera,
            gera       => s_gera,
            registra   => s_registra,
            pronto     => pronto,
            db_estado  => db_estado
        );
    s_echo <= echo;
    s_clock <= clock;
    s_reset <= reset;
end architecture;