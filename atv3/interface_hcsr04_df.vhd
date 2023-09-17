library IEEE;
use IEEE.std_logic_1164.all;

entity interface_hcsr04_df is
    port ( 
        clock       : in  std_logic;
        reset       : in  std_logic;
        zera        : in  std_logic;
        gera        : in  std_logic;
        registra    : in  std_logic;
        echo        : in  std_logic;
        fim_medida  : out std_logic;
        trigger     : out std_logic;
        digito0     : out std_logic_vector(3 downto 0);
        digito1     : out std_logic_vector(3 downto 0);
        digito2     : out std_logic_vector(3 downto 0)
    );
end interface_hcsr04_df;

architecture structural of interface_hcsr04_df is
    component gerador_pulso is
        generic (
            largura: integer:= 25
        );
        port(
            clock  : in  std_logic;
            reset  : in  std_logic;
            gera   : in  std_logic;
            para   : in  std_logic;
            pulso  : out std_logic;
            pronto : out std_logic
        );
    end component gerador_pulso;

    component contador_cm is
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
    end component;

    component registrador_n is
        generic (
            constant N: integer := 4 
        );
        port (
            clock  : in  std_logic;
            clear  : in  std_logic;
            enable : in  std_logic;
            D      : in  std_logic_vector (N-1 downto 0);
            Q      : out std_logic_vector (N-1 downto 0) 
        );
    end component registrador_n;

    signal s_clock, s_zera, s_registra, s_reset : std_logic;
    signal s_digito0, s_digito1, s_digito2 : std_logic_vector(3 downto 0);

begin
    s_clock <= clock;
    s_zera <= zera;
    s_registra <= registra;
    s_reset <= reset;
    contador_cm_inst: contador_cm
        generic map ( R => 2941, N => 12 )
        port map (
            clock   => s_clock,
            reset   => s_zera,
            pulso   => echo,
            digito0 => s_digito0,
            digito1 => s_digito1,
            digito2 => s_digito2,
            fim     => open,
            pronto  => fim_medida
        );

    gerador_pulso_inst: gerador_pulso
        generic map ( largura => 500 )
        port map (
            clock  => s_clock,
            reset  => s_zera,
            gera   => gera,
            para   => '0',
            pulso  => trigger,
            pronto => open
        );

    registrador_digito0: registrador_n
      generic map (
        N => 4
      )
      port map (
        clock  => s_clock,
        clear  => s_reset,
        enable => s_registra,
        D      => s_digito0,
        Q      => digito0
      );
    
    registrador_digito1: registrador_n
      generic map (
        N => 4
      )
      port map (
        clock  => s_clock,
        clear  => s_reset,
        enable => s_registra,
        D      => s_digito1,
        Q      => digito1
      );

    registrador_digito2: registrador_n
      generic map (
        N => 4
      )
      port map (
        clock  => s_clock,
        clear  => s_reset,
        enable => s_registra,
        D      => s_digito2,
        Q      => digito2
      );
end architecture;