library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fluxo_dados is
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
end entity;

architecture estrutural of fluxo_dados is

    component registrador_n is
        generic (
            constant N: integer := 3
        );
        port (
            clock  : in  std_logic;
            clear  : in  std_logic;
            enable : in  std_logic;
            D      : in  std_logic_vector (N - 1 downto 0);
            Q      : out std_logic_vector (N - 1 downto 0) 
        );
    end component;

    component contador_m is
        generic (
            constant M: integer := 5000 -- modulo do contador
        );
        port (
            clock   : in  std_logic;
            zera_as : in  std_logic;
            zera_s  : in  std_logic;
            conta   : in  std_logic;
            Q       : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
            fim     : out std_logic;
            meio    : out std_logic
        );
    end component;
    
    component comparador_n is
        generic (
            constant N: integer := 3
        );
        port (
            A     : in  std_logic_vector (N-1 downto 0);
            B     : in  std_logic_vector (N-1 downto 0);
            igual : out std_logic;
            menor : out std_logic;
            maior : out std_logic
        );
    end component;
    
    component edge_detector is
        port (
            clock  : in  std_logic;
            reset  : in  std_logic;
            sinal  : in  std_logic;
            pulso  : out std_logic
        );
    end component;
  
    component encoder_n is
        generic (
            constant N: natural := 5 -- numero de entradas do encoder
        );
        port (
            input  : in  std_logic_vector(N-1 downto 0);
            output : out std_logic_vector(natural(ceil(log2(real(N))))-1 downto 0)
        );
    end component;

    component banco_registradores is
	    port (
		clk : in std_logic;
		registra : in std_logic;
		limpa : in std_logic;
		reset : in std_logic;
		dados_entrada : in std_logic_vector(2 downto 0);
		dados_saida : out std_logic_vector(4 downto 0)
	    );
    end component;

    component ou_m is
        generic (
            constant M : natural := 5
        );
        port (
            entrada : in std_logic_vector(M-1 downto 0);
            saida : out std_logic
        );
    end component;

    component ultimo_andar is
        port (
            andares_chamados : in std_logic_vector(4 downto 0);
            ultimo_andar_cima : out std_logic_vector(2 downto 0);
            ultimo_andar_baixo : out std_logic_vector(2 downto 0)
        );
    end component;

    component calcula_direcao is
        port (
            ultimo_andar_cima : in std_logic_vector(2 downto 0);
            andar_atual : in std_logic_vector(2 downto 0);
            calculo_direcao : out std_logic
        );
    end component;

    signal s_CC_mais_recente: std_logic_vector(2 downto 0);

    signal s_botoesCC      : std_logic_vector(4 downto 0);
    signal s_botoesCABaixo : std_logic_vector(4 downto 0);
    signal s_botoesCACima  : std_logic_vector(4 downto 0);
    signal s_chaves        : std_logic_vector(4 downto 0);

    signal limpaTudo : std_logic;

    signal s_or_botoesCC          : std_logic;
    signal s_not_or_botoesCC      : std_logic;
    signal s_or_botoesCACima      : std_logic;
    signal s_not_or_botoesCACima  : std_logic;
    signal s_or_botoesCABaixo     : std_logic;
    signal s_not_or_botoesCABaixo : std_logic;

    signal s_or_chaves  : std_logic;
    signal s_andarAtual : std_logic_vector(2 downto 0);
    signal s_ultimoAndar: std_logic_vector(2 downto 0);
    signal s_ultimoAndar_Baixo: std_logic_vector(2 downto 0);
    signal s_ultimoAndar_Cima: std_logic_vector(2 downto 0);

    signal s_mem_entradaCC      : std_logic_vector(2 downto 0);
    signal s_mem_entradaCACima  : std_logic_vector(2 downto 0);
    signal s_mem_entradaCABaixo : std_logic_vector(2 downto 0);

    signal s_chamouCC      : std_logic;
    signal s_chamouCABaixo : std_logic;
    signal s_chamouCACima  : std_logic;

    signal s_andares_chamados_CC      : std_logic_vector(4 downto 0);
    signal s_andares_chamados_CACima  : std_logic_vector(4 downto 0);
    signal s_andares_chamados_CABaixo : std_logic_vector(4 downto 0);
    signal s_todos_andares_chamados : std_logic_vector(4 downto 0);

    signal s_paradas_cima  : std_logic_vector(4 downto 0);
    signal s_paradas_baixo : std_logic_vector(4 downto 0);

    signal s_encoded_chaves        : std_logic_vector(2 downto 0);
    signal s_encoded_botoesCC      : std_logic_vector(2 downto 0);
    signal s_encoded_botoesCACima  : std_logic_vector(2 downto 0);
    signal s_encoded_botoesCABaixo : std_logic_vector(2 downto 0);

    signal s_chegouUltimo : std_logic;

begin
    s_chaves        <= chaves;
    s_botoesCC      <= botoesCC;
    s_botoesCABaixo <= botoesCABaixo;
    s_botoesCACima  <= botoesCACima;

    limpaTudo <= limpaBaixo or limpaCima;

    chamouCC <= s_chamouCC;
    
    db_andarAtual <= s_andarAtual;

    s_not_or_botoesCC      <= not(s_or_botoesCC);
    s_not_or_botoesCACima  <= not(s_or_botoesCACima);
    s_not_or_botoesCABaixo <= not(s_or_botoesCABaixo);

    s_todos_andares_chamados <= s_andares_chamados_CC or s_andares_chamados_CABaixo or s_andares_chamados_CACima;

    s_paradas_baixo <= s_andares_chamados_CABaixo or s_andares_chamados_CC;
    s_paradas_cima  <= s_andares_chamados_CACima  or s_andares_chamados_CC;

    chegouBaixo <= s_paradas_baixo(to_integer(unsigned(s_andarAtual))) or s_chegouUltimo;
    chegouCima  <= s_paradas_cima(to_integer(unsigned(s_andarAtual))) or s_chegouUltimo;

    s_chegouUltimo <= '1' when s_ultimoAndar = s_andarAtual else '0';
    ultimo <= s_chegouUltimo;

    db_ultimo_andar <= s_ultimoAndar;

    with direcao select s_ultimoAndar <=
    s_ultimoAndar_Cima when '1',
    s_ultimoAndar_Baixo when '0',
    "111" when others;

    with (limpaBaixo or limpaCima) select s_mem_entradaCC <=
        s_encoded_botoesCC when '0',
        s_andarAtual when '1',
        s_andarAtual when others;

    with limpaCima select s_mem_entradaCACima <=
        s_encoded_botoesCACima when '0',
        s_andarAtual when '1',
        s_andarAtual when others;

    with limpaBaixo select s_mem_entradaCABaixo <=
        s_encoded_botoesCABaixo when '0',
        s_andarAtual when '1',
        s_andarAtual when others;

    orChaves: ou_m
        port map (
            entrada => s_chaves,
            saida => s_or_chaves
        );

    orBotoesCC: ou_m
        port map (
            entrada => s_botoesCC,
            saida => s_or_botoesCC
        );

    orBotoesCACima: ou_m
        port map (
            entrada => s_botoesCACima,
            saida => s_or_botoesCACima
        );

    orBotoesCABaixo: ou_m
        port map (
            entrada => s_botoesCABaixo,
            saida => s_or_botoesCABaixo
        );

    orTodosAndaresChamados: ou_m
        port map (
            entrada => s_todos_andares_chamados,
            saida => temChamada
        );

    memCC : banco_registradores
        port map (
            clk           => clock,
            registra      => s_chamouCC,
            limpa         => limpaTudo,
            reset         => zeraM,
            dados_entrada => s_mem_entradaCC,
            dados_saida   => s_andares_chamados_CC
        );

    memCACima : banco_registradores
        port map (
            clk           => clock,
            registra      => s_chamouCACima,
            limpa         => limpaCima,
            reset         => zeraM,
            dados_entrada => s_mem_entradaCACima,
            dados_saida   => s_andares_chamados_CACima
        );
    
    memCABaixo : banco_registradores
        port map (
            clk           => clock,
            registra      => s_chamouCABaixo,
            limpa         => limpaBaixo,
            reset         => zeraM,
            dados_entrada => s_mem_entradaCABaixo,
            dados_saida   => s_andares_chamados_CABaixo
        );

    CC_ed: edge_detector
        port map(
            clock => clock,
            reset => s_not_or_botoesCC,
            sinal => s_or_botoesCC,
            pulso => s_chamouCC
        );

    CACima_ed: edge_detector
        port map(
            clock => clock,
            reset => s_not_or_botoesCACima,
            sinal => s_or_botoesCACima,
            pulso => s_chamouCACima
        );

    CABaixo_ed: edge_detector
        port map(
            clock => clock,
            reset => s_not_or_botoesCABaixo,
            sinal => s_or_botoesCABaixo,
            pulso => s_chamouCABaixo
        );
    
    encoderAndares : encoder_n
        generic map (
            N => 5
        )
        port map(
            input => chaves,
            output => s_encoded_chaves
        );

    encoderBotoesCC : encoder_n
        port map (
            input  => botoesCC,
            output => s_encoded_botoesCC
        );

    encoderBotoesCACima : encoder_n
        port map (
            input  => botoesCACima,
            output => s_encoded_botoesCACima
        );

    encoderBotoesCABaixo : encoder_n
        port map (
            input  => botoesCABaixo,
            output => s_encoded_botoesCABaixo
        );
    
    comparador_Andar_Zero : comparador_n
        generic map (
            N => 3
        )
        port map (
            A => s_andarAtual,
            B => "000",
            igual => andarZero,
            maior => open,
            menor => open
        );
        
    registraAndar : registrador_n
        port map (
            clock => clock,
            clear => '0',
            enable => s_or_chaves,
            D => s_encoded_chaves,
            Q => s_andarAtual
        );

    registra_CC_mais_recente : registrador_n
        port map (
            clock => clock,
            clear => '0',
            enable => s_or_botoesCC,
            D => s_encoded_botoesCC,
            Q => s_CC_mais_recente
        );
    
    timerPorta : contador_m
        generic map (
            M => 5000
        )
        port map (
            clock => clock,
            zera_as => zeraT,
            zera_s => '0',
            conta => contaT,
            Q => open,
            fim => fimT,
            meio => open
        );

    ultimo_andar_inst: ultimo_andar
      port map (
        andares_chamados => s_todos_andares_chamados,
        ultimo_andar_cima     => s_ultimoAndar_Cima,
        ultimo_andar_baixo    => s_ultimoAndar_Baixo
      );

    calcula_direcao_inst_todos: calcula_direcao
      port map (
        ultimo_andar_cima => s_ultimoAndar_Cima,
        andar_atual       => s_andarAtual,
        calculo_direcao   => calcDir
      );

    calcula_direcao_inst_cc: calcula_direcao
      port map (
        ultimo_andar_cima => s_CC_mais_recente,
        andar_atual       => s_andarAtual,
        calculo_direcao   => calcDirCC
      );    
end architecture;
