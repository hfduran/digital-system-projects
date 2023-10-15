library ieee;
use ieee.std_logic_1164.all;

entity sonar is
    port (
         clock : in std_logic;
         reset : in std_logic;
         echo : in std_logic;
         liga : in std_logic;
         entrada_serial: in std_logic;
         trigger : out std_logic;
         pwm : out std_logic;
         saida_serial : out std_logic;
         fim_posicao : out std_logic;
         medida0 : out std_logic_vector (6 downto 0);
         medida1 : out std_logic_vector (6 downto 0);
         medida2 : out std_logic_vector (6 downto 0);
         db_estado : out std_logic_vector (6 downto 0);
         db_modo : out std_logic
     );
end entity sonar;

architecture structural of sonar is

    component sonar_uc is
        port (
            clock              : in std_logic;
            reset              : in std_logic;
            fim_medida         : in std_logic;
            fim_transmissao    : in std_logic;
            transmissao_pronto : in std_logic;
            liga               : in std_logic;
            atencao            : in std_logic;
            transmitir         : out std_logic;
            zera_transmissor   : out std_logic;
            zera_rx            : out std_logic;
            zera_cont_digitos  : out std_logic;
            zera_cont_medir    : out std_logic;
            zera_cont_angulo   : out std_logic;
            conta_digito       : out std_logic;
            conta_medir        : out std_logic;
            conta_angulo       : out std_logic;
            tx_step            : out std_logic;
            pronto             : out std_logic;
            db_estado          : out std_logic_vector(3 downto 0)
        );
    end component;

    component sonar_fd is
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
    end component;

    component atencao_uc is
        port (
          clock, reset, voltar_in, atencao_in: in std_logic;
          atencao, db_estado: out std_logic
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
    signal s_fim_transmissao, s_transmissao_pronto, s_fim_medida, s_conta_digito, s_zera_transmissor,
    s_zera_cont_digitos, s_conta_medir, s_zera_cont_medir, s_transmitir, s_medir, s_tx_step,
    s_conta_angulo, s_zera_cont_angulo, s_zera_rx, s_volta_in, s_atencao_in, s_atencao: std_logic;

begin

    UC : sonar_uc
    port map (
        clock              => clock,
        reset              => reset,
        fim_medida         => s_fim_medida,
        fim_transmissao    => s_fim_transmissao,
        liga               => liga,
        atencao            => s_atencao,
        zera_cont_angulo   => s_zera_cont_angulo,
        conta_angulo       => s_conta_angulo,
        tx_step            => s_tx_step,
        transmissao_pronto => s_transmissao_pronto,
        transmitir         => s_transmitir,
        zera_transmissor   => s_zera_transmissor,
        conta_digito       => s_conta_digito,
        zera_cont_medir    => s_zera_cont_medir,
        conta_medir        => s_conta_medir,
        zera_rx             => s_zera_rx,
        zera_cont_digitos  => s_zera_cont_digitos,
        pronto             => fim_posicao,
        db_estado          => s_estado
     );

    FD : sonar_fd
    port map (
         clock              => clock,
         reset              => reset,
         transmitir         => s_transmitir,
         echo               => echo,
         zera_cont_angulo   => s_zera_cont_angulo,
         conta_angulo       => s_conta_angulo,
         tx_step            => s_tx_step,
         voltar             => s_volta_in,
         atencao           => s_atencao_in,
         zera_cont_digitos  => s_zera_cont_digitos,
         zera_transmissor   => s_zera_transmissor,
         zera_rx            => s_zera_rx,
         entrada_serial     => entrada_serial,
         conta_digito       => s_conta_digito,
         trigger            => trigger,
         zera_cont_medir    => s_zera_cont_medir,
         conta_medir        => s_conta_medir,
         saida_serial       => saida_serial,
         fim_medida         => s_fim_medida,
         transmissao_pronto => s_transmissao_pronto,
         fim_transmissao    => s_fim_transmissao,
         pwm                => pwm,
         medida0            => s_medida0,
         medida1            => s_medida1,
         medida2            => s_medida2
    );

    AUC : atencao_uc
    port map (
        clock => clock,
        reset => reset,
        voltar_in => s_volta_in,
        atencao_in => s_atencao_in,
        atencao => s_atencao,
        db_estado => open
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

    db_modo <= s_atencao;

end architecture;
