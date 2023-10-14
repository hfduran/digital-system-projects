------------------------------------------------------------------
-- Arquivo   : rx_serial_7O1_fd.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 2 
-- > implementa configuracao 7O1
-- > 
-- > bit de paridade calculada usando portas XOR (veja linha 76)
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao
--     19/09/2022  2.1     Edson Midorikawa  revisao (db_estado)
--     17/08/2023  3.0     Edson Midorikawa  revisao para 7O1
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_7O1_fd is
    port (
        clock               : in  std_logic;
        reset               : in  std_logic;
        zera                : in  std_logic;
        conta               : in  std_logic;
        carrega             : in  std_logic;
        limpa               : in  std_logic;
        desloca             : in  std_logic;
        registra            : in  std_logic;
        entrada_serial      : in std_logic;
        dados_ascii         : out  std_logic_vector(6 downto 0);
        paridade_recebida   : out  std_logic;
        fim                 : out std_logic
    );
end entity;

architecture rx_serial_7O1_fd_arch of rx_serial_7O1_fd is
     
    component deslocador_n
    generic (
        constant N : integer
    );
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        carrega        : in  std_logic; 
        desloca        : in  std_logic; 
        entrada_serial : in  std_logic; 
        dados          : in  std_logic_vector(N-1 downto 0);
        saida          : out std_logic_vector(N-1 downto 0)
    );
    end component;

    component contador_m
    generic (
        constant M : integer;
        constant N : integer
    );
    port (
        clock : in  std_logic;
        zera  : in  std_logic;
        conta : in  std_logic;
        Q     : out std_logic_vector(N-1 downto 0);
        fim   : out std_logic;
        meio  : out std_logic
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
    
    signal s_saida_desloc: std_logic_vector(10 downto 0);

begin

    U1: deslocador_n 
        generic map (
            N => 11
        )  
        port map (
            clock          => clock, 
            reset          => limpa, 
            carrega        => '0', 
            desloca        => desloca, 
            entrada_serial => entrada_serial, 
            dados          => "11111111111", 
            saida          => s_saida_desloc
        );

    U2: contador_m 
        generic map (
            M => 12, 
            N => 4
        ) 
        port map (
            clock => clock, 
            zera  => zera, 
            conta => conta,
            Q     => open, 
            fim   => fim, 
            meio  => open
        );

    U3: registrador_n
        generic map (
            N => 7
        )
        port map (
            clock  => clock, 
            clear  => reset, 
            enable => registra, 
            D      => s_saida_desloc(7 downto 1), 
            Q      => dados_ascii
        );

    paridade_recebida <= s_saida_desloc(8);
    
end architecture;
