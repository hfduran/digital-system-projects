library ieee;
use ieee.std_logic_1164.all;

entity exp4_trena_fd is
  port (
    clock               : in std_logic;
    reset               : in std_logic;
    medir               : in std_logic;
    transmitir          : in std_logic;
    echo                : in std_logic;
    zera_transmissor    : in std_logic;
    zera_contador       : in std_logic;
    prox_digito         : in std_logic;
    trigger             : out std_logic;
    saida_serial        : out std_logic;
    fim_medida          : out std_logic;
    fim_transmissao     : out std_logic;
    transmissao_pronto  : out std_logic;
    medida0             : out std_logic_vector (3 downto 0);
    medida1             : out std_logic_vector (3 downto 0);
    medida2             : out std_logic_vector (3 downto 0)
  );
end entity;

architecture arch of exp4_trena_fd is
    component interface_hcsr04 is
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

    type digitos is array (0 to 3) of std_logic_vector(6 downto 0);

    signal s_zera_transmissor, s_zera_contador : std_logic;
    signal s_medida : std_logic_vector(11 downto 0);
    signal s_digitos_ascii : digitos;
    signal s_digito_ascii : std_logic_vector(6 downto 0);
    signal s_indice_digito : std_logic_vector(1 downto 0);

begin

    INTERFACE : interface_hcsr04
    port map (
         clock => clock,
         reset => reset,
         medir => medir,
         echo => echo,
         trigger => trigger,
         medida => s_medida,
         pronto => fim_medida,
         db_estado => open
     );

    TX : tx_serial_7O1
    port map (
         clock          => clock, 
         reset          => s_zera_transmissor, 
         partida        => transmitir, 
         dados_ascii    => s_digito_ascii,
         saida_serial   => saida_serial, 
         pronto         => fim_transmissao
     );

    CONTA_DIG : contador_m
    generic map (M => 4, N => 2)
    port map (
        clock    => clock,
        zera     => s_zera_contador,
        conta    => prox_digito,
        Q        => s_indice_digito,
        fim      => transmissao_pronto,
        meio     => open
     );

    s_zera_transmissor <= zera_transmissor or reset;
    s_zera_contador <= zera_contador or reset;

    s_digitos_ascii(0) <= "011" & s_medida(3 downto 0);
    s_digitos_ascii(1) <= "011" & s_medida(7 downto 4);
    s_digitos_ascii(2) <= "011" & s_medida(11 downto 8);
    s_digitos_ascii(3) <= "0100011";

    with s_indice_digito select
        s_digito_ascii <= s_digitos_ascii(0) when "00",
                           s_digitos_ascii(1) when "01",
                           s_digitos_ascii(2) when "10",
                           s_digitos_ascii(3) when others;

    medida0 <= s_medida(3 downto 0);
    medida1 <= s_medida(7 downto 4);
    medida2 <= s_medida(11 downto 8);

end architecture;
