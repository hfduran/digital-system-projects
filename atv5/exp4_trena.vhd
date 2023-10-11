library ieee;
use ieee.std_logic_1164.all;

entity exp4_trena is
    port (
         clock : in std_logic;
         reset : in std_logic;
         echo : in std_logic;
         trigger : out std_logic;
         saida_serial : out std_logic;
         medida0 : out std_logic_vector (6 downto 0);
         medida1 : out std_logic_vector (6 downto 0);
         medida2 : out std_logic_vector (6 downto 0);
         pronto : out std_logic;
         db_estado : out std_logic_vector (6 downto 0)
     );
end entity exp4_trena;

architecture structural of exp4_trena is

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

    component exp4_trena_uc is
      port (
        clock              : in std_logic;
        reset              : in std_logic;
        mensurar           : in std_logic;
        fim_medida         : in std_logic;
        fim_transmissao    : in std_logic;
        transmissao_pronto : in std_logic;
        transmitir         : out std_logic;
        zera_transmissor   : out std_logic;
        prox_digito        : out std_logic;
        zera_contador      : out std_logic;
        medir              : out std_logic;
        pronto             : out std_logic;
        db_estado          : out std_logic_vector(3 downto 0)
      );
    end component;

    component exp4_trena_fd is
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
    end component;

    component edge_detector is
        port (  
            clock     : in  std_logic;
            signal_in : in  std_logic;
            output    : out std_logic
        );
    end component;

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_medida0, s_medida1, s_medida2, s_estado : std_logic_vector(3 downto 0);
    signal s_fim_transmissao, s_transmissao_pronto, s_fim_medida, s_avancar_digito, s_zera_transmissor, s_zera_contador, s_transmitir, s_medir : std_logic;
    signal s_mensurar : std_logic;

begin

    UC : exp4_trena_uc
    port map (
         clock  => clock,
         reset  => reset,
         mensurar  => s_mensurar,
         fim_medida  => s_fim_medida,
         fim_transmissao  => s_fim_transmissao,
         transmissao_pronto    => s_transmissao_pronto,
         transmitir          => s_transmitir,
         zera_transmissor    => s_zera_transmissor,
         prox_digito      => s_avancar_digito,
         zera_contador => s_zera_contador,
         medir  => s_medir,
         pronto  => pronto,
         db_estado  => s_estado
     );

    FD : exp4_trena_fd
    port map (
         clock  => clock,
         reset  => reset,
         medir  => s_medir,
         transmitir  => s_transmitir,
         echo  => echo,
         zera_contador => s_zera_contador,
         zera_transmissor  => s_zera_transmissor,
         prox_digito      => s_avancar_digito,
         trigger  => trigger,
         saida_serial  => saida_serial,
         fim_medida  => s_fim_medida,
         transmissao_pronto  => s_transmissao_pronto,
         fim_transmissao  => s_fim_transmissao,
         medida0  => s_medida0,
         medida1  => s_medida1,
         medida2  => s_medida2
     );

    MENSURAR_CONT : contador_m
    generic map(
        M => 250000,
        N => 18
    )
    port map (
        clock => clock,
        zera  => reset,
        conta => '1',
        Q     => open,
        fim   => s_mensurar,
        meio  => open
     );

    HEX0 : hexa7seg
    port map (
        hexa => s_medida0,
        sseg => medida0
     );

    HEX1 : hexa7seg
    port map (
        hexa => s_medida1,
        sseg => medida1
     );

    HEX2 : hexa7seg
    port map (
        hexa => s_medida2,
        sseg => medida2
     );

    HEX_ESTADO : hexa7seg
    port map (
        hexa => s_estado,
        sseg => db_estado
     );

end architecture;
