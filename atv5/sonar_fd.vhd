library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity sonar_fd is
  port (
    clock               : in std_logic;
    reset               : in std_logic;
    transmitir          : in std_logic;
    echo                : in std_logic;
    zera_transmissor    : in std_logic;
    zera_cont_digitos   : in std_logic;
    conta_digito        : in std_logic;
    zera_cont_medir     : in std_logic;
    conta_medir         : in std_logic;
    zera_cont_angulo    : in std_logic;
    conta_angulo        : in std_logic;
    tx_step             : in std_logic; -- 0 for angle, 1 for distance
    entrada_serial      : in std_logic;
    zera_rx             : in std_logic;
    atencao             : out std_logic;
    voltar              : out std_logic;
    trigger             : out std_logic;
    saida_serial        : out std_logic;
    fim_medida          : out std_logic;
    fim_transmissao     : out std_logic;
    transmissao_pronto  : out std_logic;
    pwm                 : out std_logic;
    medida0             : out std_logic_vector (3 downto 0);
    medida1             : out std_logic_vector (3 downto 0);
    medida2             : out std_logic_vector (3 downto 0)
  );
end entity;

architecture arch of sonar_fd is
    component interface_hcsr04 is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            echo      : in  std_logic;
            medir    : in  std_logic;
            trigger   : out std_logic;
            medida    : out std_logic_vector(11 downto 0);
            pronto    : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    component tx_serial_7O1 is
        port (
             clock           : in  std_logic;
             reset           : in  std_logic;
             partida         : in  std_logic;
             dados_ascii     : in  std_logic_vector(6 downto 0);
             saida_serial    : out std_logic;
             pronto          : out std_logic
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
    end component;

    component comparador is
        generic (
          constant N : integer := 7
        );
        port (
          a, b : in std_logic_vector(N-1 downto 0);
          eq : out std_logic
        );
    end component;

    component controle_servo is
        port (
        clock : in std_logic;
        reset : in std_logic;
        posicao : in std_logic_vector(2 downto 0);
        controle : out std_logic
        );
    end component;

    component contadorg_updown_m is
        generic (
            constant M: integer := 50 -- modulo do contador
        );
        port (
            clock  : in  std_logic;
            zera_as: in  std_logic;
            zera_s : in  std_logic;
            conta  : in  std_logic;
            Q      : out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            inicio : out std_logic;
            fim    : out std_logic;
            meio   : out std_logic 
       );
    end component;

    component rom_angulos_8x24 is
        port (
            endereco : in  std_logic_vector(2 downto 0);
            saida    : out std_logic_vector(23 downto 0)
        ); 
    end component;


    component mux_4x1_n is
        generic (
            constant BITS: integer := 4
        );
        port( 
            D3      : in  std_logic_vector (BITS-1 downto 0);
            D2      : in  std_logic_vector (BITS-1 downto 0);
            D1      : in  std_logic_vector (BITS-1 downto 0);
            D0      : in  std_logic_vector (BITS-1 downto 0);
            SEL     : in  std_logic_vector (1 downto 0);
            MUX_OUT : out std_logic_vector (BITS-1 downto 0)
        );
    end component;

    component rx_serial_7O1 is
        port (
            clock               : in  std_logic;
            reset               : in  std_logic;
            dado_serial         : in  std_logic;
            dados_ascii         : out std_logic_vector(6 downto 0);
            paridade_recebida   : out std_logic;
            pronto_rx           : out std_logic;
            db_estado           : out std_logic_vector(3 downto 0);
            db_dado_serial      : out std_logic
        );
    end component;

    type digitos_distancia is array (0 to 2) of std_logic_vector(6 downto 0);

    signal s_medir : std_logic;
    signal s_medida : std_logic_vector(11 downto 0);
    signal s_distancia_atual : digitos_distancia;
    signal s_digito_ascii : std_logic_vector(6 downto 0);
    signal s_digito_distancia, s_digito_angulo : std_logic_vector(6 downto 0);
    signal s_char_recebido : std_logic_vector(6 downto 0);
    signal s_indice_digito : std_logic_vector(1 downto 0);
    signal s_selecao_angulo : std_logic_vector(2 downto 0);
    signal s_angulo_atual : std_logic_vector(23 downto 0);

begin

    INTERFACE : interface_hcsr04
    port map (
         clock => clock,
         reset => reset,
         echo => echo,
         medir => s_medir,
         trigger => trigger,
         medida => s_medida,
         pronto => fim_medida,
         db_estado => open
     );

    TX : tx_serial_7O1
    port map (
         clock          => clock, 
         reset          => zera_transmissor, 
         partida        => transmitir, 
         dados_ascii    => s_digito_ascii,
         saida_serial   => saida_serial, 
         pronto         => fim_transmissao
    );

    RX : rx_serial_7O1
    port map (
        clock => clock,
        reset => zera_rx,
        dado_serial => entrada_serial,
        dados_ascii => s_char_recebido,
        paridade_recebida => open,
        pronto_rx => open,
        db_estado => open,
        db_dado_serial => open
    );

    CONTA_DIG : contador_m
    generic map (M => 4, N => 2)
    port map (
        clock    => clock,
        zera     => zera_cont_digitos,
        conta    => conta_digito,
        Q        => s_indice_digito,
        fim      => transmissao_pronto,
        meio     => open
    );

    MEDIR_CONT : contador_m
    generic map(
        M => 10000,
        N => 18
    )
    port map (
        clock => clock,
        zera  => zera_cont_medir,
        conta => conta_medir,
        Q     => open,
        fim   => s_medir,
        meio  => open
    );
    
    ANGULO_CONT : contadorg_updown_m
    generic map(
        M => 8
    )
    port map(
        clock => clock,
        zera_as => '0',
        zera_s => zera_cont_angulo,
        conta => conta_angulo,
        Q => s_selecao_angulo,
        inicio => open,
        fim => open,
        meio => open
    );

    ROM_ANGULOS : rom_angulos_8x24
    port map(
        endereco => s_selecao_angulo,
        saida => s_angulo_atual
    );

    SERVO: controle_servo
    port map(
        clock => clock,
        reset => reset,
        posicao => s_selecao_angulo,
        controle => pwm
    );

    s_distancia_atual(0) <= "011" & s_medida(3 downto 0);
    s_distancia_atual(1) <= "011" & s_medida(7 downto 4);
    s_distancia_atual(2) <= "011" & s_medida(11 downto 8);

    MUX_DIST: mux_4x1_n
    generic map(
        BITS => 7
    )
    port map (
        D3 => "0101100",
        D2 => s_distancia_atual(2),
        D1 => s_distancia_atual(1),
        D0 => s_distancia_atual(0),
        SEL => s_indice_digito,
        MUX_OUT => s_digito_distancia
    );

    MUX_ANG: mux_4x1_n
    generic map(
        BITS => 7
    )
    port map (
        D3 => "0100011",
        D2 => s_angulo_atual(22 downto 16),
        D1 => s_angulo_atual(14 downto 8),
        D0 => s_angulo_atual(6 downto 0),
        SEL => s_indice_digito,
        MUX_OUT => s_digito_angulo
    );

    ATENCAO_COMP : comparador
    generic map(
        N => 7
    )
    port map(
        a => s_char_recebido,
        b => "1100001",
        eq => atencao
    );

    VOLTAR_COMP : comparador
    generic map(
        N => 7
    )
    port map(
        a => s_char_recebido,
        b => "1110110",
        eq => voltar
    );
    
    with tx_step select
        s_digito_ascii <= s_digito_angulo when '0',
                          s_digito_distancia when others;

    medida0 <= s_medida(3 downto 0);
    medida1 <= s_medida(7 downto 4);
    medida2 <= s_medida(11 downto 8);

end architecture;
