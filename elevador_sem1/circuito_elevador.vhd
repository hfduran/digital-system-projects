library ieee;
use ieee.std_logic_1164.all;

entity circuito_elevador is
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        iniciar : in  std_logic;
        chaves  : in  std_logic_vector (4 downto 0);
        botoesCC  : in  std_logic_vector (4 downto 0);
        botoesCABaixo: in  std_logic_vector (4 downto 0);
        botoesCACima: in  std_logic_vector (4 downto 0);
        motor_enable: out std_logic;
        saida_motor1: out std_logic;
        saida_motor2: out std_logic;
        semDir  : out std_logic;
        db_timer : out std_logic;
        db_estado: out std_logic_vector(6 downto 0);
        db_andarAtual: out std_logic_vector (6 downto 0);
        db_ultimoAndar: out std_logic_vector(6 downto 0)
    );
end entity;

architecture estrutural of circuito_elevador is
    component fluxo_dados is
        port (
            clock           : in  std_logic;
            chaves          : in  std_logic_vector(4 downto 0);
            botoesCC        : in  std_logic_vector(4 downto 0);
            botoesCABaixo   : in  std_logic_vector(4 downto 0);
            botoesCACima    : in  std_logic_vector(4 downto 0);
            zeraM           : in  std_logic;
            direcao         : in  std_logic;
            limpaBaixo      : in  std_logic;
            limpaCima       : in  std_logic;
            contaT          : in  std_logic;
            zeraT           : in  std_logic;
            andarZero       : out std_logic;
            chamouCC        : out std_logic;
            temChamada      : out std_logic;
            chegouCima      : out std_logic;
            chegouBaixo     : out std_logic;
            fimT            : out std_logic;
            ultimo          : out std_logic;
            calcDir         : out std_logic;
            calcDirCC       : out std_logic;
            db_andarAtual   : out std_logic_vector(2 downto 0);
            db_ultimo_andar : out std_logic_vector(2 downto 0)
        );
    end component;
    
    component unidade_controle is
        port ( 
            clock     : in  std_logic; 
            reset     : in  std_logic; 
            iniciar   : in  std_logic;
            andarZero : in  std_logic;
            chamouCC  : in  std_logic;
            temChamada: in  std_logic;
            calcDir   : in  std_logic;
            calcDirCC : in  std_logic;
            chegouCima  : in  std_logic;
            chegouBaixo : in std_logic;
            ultimo      : in  std_logic;
            fimT      : in  std_logic;
            contaT    : out std_logic;
            liga      : out std_logic;
            direcao   : out std_logic;
            zeraT     : out std_logic;
            limpaCima : out std_logic;
            limpaBaixo: out std_logic;
            semDir    : out std_logic;
            zeraM     : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component hexa7seg is
        port (
            hexa : in  std_logic_vector (3 downto 0);
            sseg : out std_logic_vector (6 downto 0)
        );
    end component;

    signal s_direcao : std_logic;
    signal s_liga : std_logic;
    signal s_zeraM: std_logic;
    signal s_limpaBaixo: std_logic;
    signal s_limpaCima: std_logic;
    signal s_contaT: std_logic;
    signal s_zeraT: std_logic := '0';
    signal s_andarZero: std_logic;
    signal s_chamouCC: std_logic;
    signal s_temChamada: std_logic;
    signal s_chegouCima: std_logic;
    signal s_fimT : std_logic;
    signal s_chegouBaixo: std_logic;
    signal s_ultimo : std_logic;
    signal s_calcDir : std_logic;
    signal s_calcDirCC: std_logic;
    signal s_semDir : std_logic;
    signal s_db_estado : std_logic_vector(3 downto 0);
    signal s_db_andarAtual: std_logic_vector(2 downto 0);
    signal s_db_ultimoAndar: std_logic_vector(2 downto 0);
    signal s_db_andarAtual_display: std_logic_vector(3 downto 0);
    signal s_db_ultimoAndar_display : std_logic_vector(3 downto 0);

begin

    motor_enable <= s_liga;

    with s_direcao select saida_motor1 <=
    '1' when '1',
    '0' when '0',
    '0' when others;

    with s_direcao select saida_motor2 <=
    '1' when '0',
    '0' when '1',
    '0' when others; 
    
    db_timer <= s_contaT;
    semDir <= s_semDir;

    s_db_andarAtual_display <= '0' & s_db_andarAtual;
    s_db_ultimoAndar_display <= '0' & s_db_ultimoAndar;

    fluxo_dados_inst: fluxo_dados
      port map (
        clock           => clock,
        chaves          => chaves,
        botoesCC        => botoesCC,
        botoesCABaixo   => botoesCABaixo,
        botoesCACima    => botoesCACima,
        zeraM           => s_zeraM,
        direcao         => s_direcao,
        limpaBaixo      => s_limpaBaixo,
        limpaCima       => s_limpaCima,
        contaT          => s_contaT,
        zeraT           => s_zeraT,
        andarZero       => s_andarZero,
        chamouCC        => s_chamouCC,
        temChamada      => s_temChamada,
        chegouCima      => s_chegouCima,
        chegouBaixo     => s_chegouBaixo,
        fimT            => s_fimT,
        ultimo          => s_ultimo,
        calcDir         => s_calcDir,
        calcDirCC       => s_calcDirCC,
        db_andarAtual   => s_db_andarAtual,
        db_ultimo_andar => s_db_ultimoAndar
      );

    unidade_controle_inst: unidade_controle
      port map (
        clock       => clock,
        reset       => reset,
        iniciar     => iniciar,
        andarZero   => s_andarZero,
        chamouCC    => s_chamouCC,
        temChamada  => s_temChamada,
        calcDir     => s_calcDir,
        calcDirCC   => s_calcDirCC,
        chegouCima  => s_chegouCima,
        chegouBaixo => s_chegouBaixo,
        ultimo      => s_ultimo,
        fimT        => s_fimT,
        contaT      => s_contaT,
        liga        => s_liga,
        direcao     => s_direcao,
        zeraT       => s_zeraT,
        limpaCima   => s_limpaCima,
        limpaBaixo  => s_limpaBaixo,
        semDir      => s_semDir,
        zeraM       => s_zeraM,
        db_estado   => s_db_estado
      );
        
    DisplayEstado : hexa7seg
    port map (
        hexa => s_db_estado,
        sseg => db_estado
    );
    
    DisplayAndarAtual : hexa7seg
    port map (
        hexa => s_db_andarAtual_display,
        sseg => db_andarAtual
    );
    
    DisplayUltimoAndar : hexa7seg
    port map (
        hexa => s_db_ultimoAndar_display,
        sseg => db_ultimoAndar
    );

end architecture;
