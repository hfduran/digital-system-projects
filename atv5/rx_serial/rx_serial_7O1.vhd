-------------------------------------------------------------------
-- Arquivo   : rx_serial_7O1.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
-------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
-- > implementa configuracao 7O1 e taxa de 115200 bauds
-- > 
-- > componente edge_detector (U4) trata pulsos largos
-- > de PARTIDA (veja linha 83)
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--     31/08/2022  2.0     Edson Midorikawa  revisao do codigo
--     19/09/2022  2.1     Edson Midorikawa  revisao (db_estado)
--     17/08/2023  3.0     Edson Midorikawa  revisao para 7O1
--     10/09/2023  4.0     Henrique Duran    rx serial
-------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_7O1 is
    port (
        clock               : in  std_logic;
        reset               : in  std_logic;
        dado_serial         : in  std_logic;
        dado_recebido0      : out std_logic_vector(6 downto 0);
        dado_recebido1      : out std_logic_vector(6 downto 0);
        paridade_recebida   : out std_logic;
        pronto_rx           : out std_logic;
        db_estado           : out std_logic_vector(6 downto 0);
        db_dado_serial      : out std_logic
    );
end entity;

architecture estrutural of rx_serial_7O1 is
    
    component rx_serial_7O1_fd is
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
    end component;

    component rx_serial_uc is 
        port ( 
            clock     : in  std_logic;
            reset     : in  std_logic;
            tick      : in  std_logic;
            fim       : in  std_logic;
            dado      : in  std_logic;
            zera      : out std_logic;
            limpa     : out std_logic;
            conta     : out std_logic;
            carrega   : out std_logic;
            desloca   : out std_logic;
            pronto    : out std_logic;
            registra  : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
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

    component hexa7seg
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;  

    signal s_reset: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim : std_logic;
    signal s_limpa, s_pronto, s_registra : std_logic;
    signal s_estado : std_logic_vector(3 downto 0);
    signal s_dados_ascii : std_logic_vector(6 downto 0);
    signal s_dado_recebido0, s_dado_recebido1 : std_logic_vector(3 downto 0);
    signal s_dado_serial: std_logic;

begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset   <= reset;
    s_dado_serial <= dado_serial;

    -- unidade de controle
    
    U1_UC: rx_serial_uc
           port map (
               clock     => clock,
               reset     => s_reset,
               tick      => s_tick,
               fim       => s_fim,
               dado      => s_dado_serial,
               zera      => s_zera,
               limpa     => s_limpa,
               conta     => s_conta,
               carrega   => s_carrega,
               desloca   => s_desloca,
               pronto    => s_pronto,
               registra  => s_registra,
               db_estado => s_estado
               
           );

    -- fluxo de dados
    U2_FD: rx_serial_7O1_fd 
           port map (
               clock            => clock,
               reset            => s_reset,
               zera             => s_zera,
               conta            => s_conta,
               carrega          => s_carrega,
               limpa            => s_limpa,
               desloca          => s_desloca,
               registra         => s_registra,
               entrada_serial   => s_dado_serial,
               dados_ascii      => s_dados_ascii,
               paridade_recebida=> paridade_recebida,
               fim              => s_fim
           );


    -- gerador de tick
    -- fator de divisao para 9600 bauds (5208=50M/9600)
    -- fator de divisao para 115.200 bauds (434=50M/115200)
    U3_TICK: contador_m 
             generic map (
                 M => 434, -- 115200 bauds
                 N => 13
             ) 
             port map (
                 clock => clock, 
                 zera  => s_zera, 
                 conta => '1', 
                 Q     => open, 
                 fim   => open,
                 meio  => s_tick
             );
 
    
    HEX0: hexa7seg
          port map (
              hexa => s_estado,
              sseg => db_estado
          );

    HEX1: hexa7seg
          port map (
              hexa => s_dado_recebido0,
              sseg => dado_recebido0
    );

    HEX2: hexa7seg
    port map (
        hexa => s_dado_recebido1,
        sseg => dado_recebido1
    );

    pronto_rx <= s_pronto;

    s_dado_recebido0 <= s_dados_ascii(3 downto 0);
    s_dado_recebido1 <= '0' & s_dados_ascii(6 downto 4);

    db_dado_serial <= s_dado_serial;

end architecture;
