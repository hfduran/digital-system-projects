--------------------------------------------------------------------------
-- Arquivo   : circuito_contador_m_tb.vhd
-- Projeto   :Experiencia 4 - Desenvolvimento de Projeto de 
--                            Circuitos Digitais em FPGA
--------------------------------------------------------------------------
-- Descricao : testbench para contador_m (contador modulo m)
--
--             instancia contador para M=5000 com clock=1KHz
-- 
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     31/01/2020  1.0     Edson Midorikawa  criacao
--     31/08/2022  2.0     Edson Midorikawa  revisao do codigo
--     27/01/2023  2.1     Edson Midorikawa  revisao do codigo
--------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

-- entidade do testbench
entity circuito_elevador_tb is
end entity;

architecture tb of circuito_elevador_tb is

  -- Componente a ser testado (Device Under Test -- DUT)
  component circuito_elevador is
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
  end component;
  
  ---- Declaracao de sinais de entrada para conectar o componente
  signal clock_in   : std_logic := '0';
  signal reset_in      : std_logic := '0';
  signal iniciar_in    : std_logic := '0';
  signal chaves_in     : std_logic_vector (4 downto 0) := "00001";
  signal botoesCC_in     : std_logic_vector (4 downto 0) := "00000";
  signal botoesCACima_in     : std_logic_vector (4 downto 0) := "00000";
  signal botoesCABaixo_in     : std_logic_vector (4 downto 0) := "00000";

  ---- Declaracao dos sinais de saida
  signal motor_enable_out: std_logic;
  signal saida_motor1_out: std_logic;
  signal saida_motor2_out: std_logic;
  signal semDir_out: std_logic := '0';
  signal db_timer_out : std_logic := '0';
  signal db_estado_out : std_logic_vector(6 downto 0) := "0000000";
  signal db_andarAtual_out : std_logic_vector(6 downto 0) := "0000000";
  signal db_ultimoAndar_out : std_logic_vector(6 downto 0) := "0000000";

  -- Configurações do clock
  signal keep_simulating : std_logic := '0'; -- delimita o tempo de geração do clock
  constant clockPeriod   : time := 20 ns;
  
  -- Casos de teste
  signal caso  : integer := 0;

begin
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período especificado. 
  -- Quando keep_simulating=0, clock é interrompido, bem como a simulação de eventos
  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;
  
  ---- DUT para Caso de Teste 1
  circuito_elevador_inst: circuito_elevador
    port map (
      clock           => clock_in,
      reset           => reset_in,
      iniciar         => iniciar_in,
      chaves          => chaves_in,
      botoesCC        => botoesCC_in,
      botoesCABaixo   => botoesCABaixo_in,
      botoesCACima    => botoesCACima_in,
      motor_enable    => motor_enable_out,
      saida_motor1    => saida_motor1_out,
      saida_motor2    => saida_motor2_out,
      semDir          => semDir_out,
      db_timer        => db_timer_out,
      db_estado       => db_estado_out,
      db_andarAtual   => db_andarAtual_out,
      db_ultimoAndar  => db_ultimoAndar_out
    );
 
  ---- Gera sinais de estimulo para a simulacao
  stimulus: process is
  begin

    -- inicio da simulacao
    assert false report "inicio da simulacao" severity note;
    keep_simulating <= '1';  -- inicia geracao do sinal de clock

    caso <= 0;
    reset_in <= '1';
    wait for 1* 10 us;

    caso <= 1;
    reset_in <= '0';
    iniciar_in <= '1';
    wait for 5* 10 us;

    caso <= 2;
    botoesCABaixo_in <= "00100";
    wait for 5* 10 us;
    botoesCABaixo_in <= "00000";
    wait for 5* 10 us;

    caso <= 3;
    chaves_in <= "00010";
    wait for 5* 10 us;
    chaves_in <= "00000";
    wait for 5* 10 us;
    chaves_in <= "00100";
    wait for 25* 10 us;
 
    ---- final do testbench
    assert false report "fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait; -- fim da simulação: processo aguarda indefinidamente
  end process;


end architecture;