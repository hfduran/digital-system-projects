library ieee;
use ieee.std_logic_1164.all;

entity exp3_sensor is
    port(
        clock : in std_logic;
        reset : in std_logic;
        medir : in std_logic;
        echo : in std_logic;
        trigger : out std_logic;
        hex0 : out std_logic_vector(6 downto 0);
        hex1 : out std_logic_vector(6 downto 0);
        hex2 : out std_logic_vector(6 downto 0);
        pronto : out std_logic;
        db_medir : out std_logic;
        db_echo : out std_logic;
        db_trigger : out std_logic;
        db_estado : out std_logic_vector(6 downto 0)
    );
end entity;

architecture structural of exp3_sensor is
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

    component edge_detector is
        port (  
            clock     : in  std_logic;
            signal_in : in  std_logic;
            output    : out std_logic
        );
    end component edge_detector;

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component hexa7seg;

    signal s_db_estado: std_logic_vector(3 downto 0);
    signal s_medida: std_logic_vector(11 downto 0);
    signal s_medir_pulso, s_trigger, s_echo, s_medir: std_logic;

begin

    s_medir <= medir;
    s_echo <= echo;
    trigger <= s_trigger;

    db_trigger <= s_trigger;
    db_medir <= s_medir;
    db_echo <= s_echo;

    U0: edge_detector
        port map (
            clock     => clock,
            signal_in => s_medir,
            output    => s_medir_pulso
        );

    interface: interface_hcsr04
        port map (
            clock     => clock,
            reset     => reset,
            medir     => s_medir_pulso,
            echo      => s_echo,
            trigger   => s_trigger,
            medida    => s_medida,
            pronto    => pronto,
            db_estado => s_db_estado
        );

    H5: hexa7seg
        port map (
            hexa => s_db_estado,
            sseg => db_estado
        );
    
    H0: hexa7seg
        port map (
            hexa => s_medida(3 downto 0),
            sseg => hex0
        );
    
    H1: hexa7seg
        port map (
            hexa => s_medida(7 downto 4),
            sseg => hex1
        );
    
    H2: hexa7seg
        port map (
            hexa => s_medida(11 downto 8),
            sseg => hex2
        );

end architecture;