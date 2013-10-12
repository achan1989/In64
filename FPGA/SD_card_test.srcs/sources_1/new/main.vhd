----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.08.2013 20:08:06
-- Design Name: 
-- Module Name: main - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    Port ( clk : in std_ulogic;
            reset_switch : in std_ulogic;
            uart_tx : out std_ulogic;
           sd_cs_out : out std_ulogic;
           sd_clk_out : out std_ulogic;
           sd_mosi : out std_ulogic;
           sd_miso : in std_ulogic;
           sd_power : out std_ulogic;
           read_strobe_dbg : out std_ulogic);
end main;

architecture Behavioral of main is

    component kcpsm6
      generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                      interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
               scratch_pad_memory_size : integer := 64);
      port (                   address : out std_logic_vector(11 downto 0);
                           instruction : in std_logic_vector(17 downto 0);
                           bram_enable : out std_logic;
                               in_port : in std_logic_vector(7 downto 0);
                              out_port : out std_logic_vector(7 downto 0);
                               port_id : out std_logic_vector(7 downto 0);
                          write_strobe : out std_logic;
                        k_write_strobe : out std_logic;
                           read_strobe : out std_logic;
                             interrupt : in std_logic;
                         interrupt_ack : out std_logic;
                                 sleep : in std_logic;
                                 reset : in std_logic;
                                   clk : in std_logic);
    end component;
    
    component test_program                             
        generic(             C_FAMILY : string := "S6"; 
                    C_RAM_SIZE_KWORDS : integer := 1;
                 C_JTAG_LOADER_ENABLE : integer := 0);
        Port (      address : in std_logic_vector(11 downto 0);
                instruction : out std_logic_vector(17 downto 0);
                     enable : in std_logic;
                        rdl : out std_logic;                    
                        clk : in std_logic);
    end component;
    
    component uart_tx6 is
        Port (             data_in : in std_logic_vector(7 downto 0);
                            en_16_x_baud : in std_logic;
                              serial_out : out std_logic;
                            buffer_write : in std_logic;
                             buffer_data_present : out std_logic;
                            buffer_half_full : out std_logic;
                             buffer_full : out std_logic;
                            buffer_reset : in std_logic;
                             clk : in std_logic);
    end component;
    
    signal         address : std_logic_vector(11 downto 0);
    signal     instruction : std_logic_vector(17 downto 0);
    signal     bram_enable : std_logic;
    signal         in_port : std_logic_vector(7 downto 0);
    signal        out_port : std_logic_vector(7 downto 0);
    signal         port_id : std_logic_vector(7 downto 0);
    signal    write_strobe : std_logic;
    signal  k_write_strobe : std_logic;
    signal     read_strobe : std_logic;
    signal       interrupt : std_logic;
    signal   interrupt_ack : std_logic;
    signal    kcpsm6_sleep : std_logic;
    signal    kcpsm6_reset : std_logic;
    signal sd_cs : std_ulogic := '1';
    signal sd_clk : std_ulogic := '0';
    
    -- Signals for UART_TX6
    signal      uart_tx_data_in : std_logic_vector(7 downto 0);
    signal     write_to_uart_tx : std_ulogic;
    signal         uart_tx_full : std_ulogic;
    signal         uart_tx_reset : std_ulogic;
    
    -- Signals used to define baud rate
    signal           baud_count : integer range 0 to 53 := 0; 
    signal         en_16_x_baud : std_ulogic := '0';
  
begin


cpu: kcpsm6
    generic map (                 hwbuild => X"00", 
                         interrupt_vector => X"3FF",
                  scratch_pad_memory_size => 64)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => k_write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     sleep => kcpsm6_sleep,
                     reset => kcpsm6_reset or (not reset_switch),
                       clk => clk);
                       
kcpsm6_sleep <= '0';
interrupt <= '0';
read_strobe_dbg <= read_strobe;

programRom: test_program
    generic map(             C_FAMILY => "S6",   --Family 'S6', 'V6' or '7S'
                    C_RAM_SIZE_KWORDS => 1,      --Program size '1', '2' or '4'
                 C_JTAG_LOADER_ENABLE => 1)      --Include JTAG Loader when set to '1' 
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => kcpsm6_reset,
                       clk => clk);
                       
tx: uart_tx6 
 port map (              data_in => uart_tx_data_in,
                    en_16_x_baud => en_16_x_baud,
                      serial_out => uart_tx,
                    buffer_write => write_to_uart_tx,
             buffer_data_present => open,
                buffer_half_full => open,
                     buffer_full => uart_tx_full,
                    buffer_reset => uart_tx_reset,              
                                                     clk => clk);
                                                     
in_port <= (7 => sd_miso, 2 => uart_tx_full, others => '-');
                                                     

--input_ports: process(clk)
--begin
--    if rising_edge(clk) then
--        case port_id(0) is
--            when '0' => in_port <= (7 => sd_miso, 6 downto 0 => '-');
--            when '1' => in_port(2) <= uart_tx_full;
--            when others => null;
--        end case;
--    end if;
--end process;


-- Always send CPU output to the UART...
uart_tx_data_in <= out_port;
-- But don't trigger a write unless the CPU output was actually meant for the UART (OUT on port 3).
write_to_uart_tx <= '1' when (write_strobe = '1' and port_id(0) = '1') else '0';
                       
output_ports: process(clk)
begin
    if rising_edge(clk) then
        if write_strobe = '1' then
            case port_id(0) is
                when '0' =>
                    sd_clk <= out_port(0);
                    sd_cs <= out_port(1);
                    sd_mosi <= out_port(7);
                --when '1' =>
                  --  write_to_uart_tx <= '1';
                  --  uart_tx_data_in <= out_port;
                when others => null;
            end case;
        --else
          --  write_to_uart_tx <= '0';
        end if;
    end if;
end process;


-----------------------------------------------------------------------------------------
-- RS232 (UART) baud rate 
-----------------------------------------------------------------------------------------
--
-- To set serial communication baud rate to 115,200 then en_16_x_baud must pulse 
-- High at 1,843,200Hz which is every 54.28 cycles at 100MHz. In this implementation 
-- a pulse is generated every 54 cycles resulting is a baud rate of 115,741 baud which
-- is only 0.5% high and well within limits.
--
baud_rate: process(clk)
begin
  if rising_edge(clk) then
    if baud_count = 53 then                    -- counts 54 states including zero
      baud_count <= 0;
      en_16_x_baud <= '1';                     -- single cycle enable pulse
     else
      baud_count <= baud_count + 1;
      en_16_x_baud <= '0';
    end if;
  end if;
end process baud_rate;


-----------------------------------------------------------------------------------------
-- Constant-Optimised Output Ports 
-----------------------------------------------------------------------------------------
--
-- One constant-optimised output port is used to facilitate resetting of the UART macros.
--

constant_output_ports: process(clk)
begin
if rising_edge(clk) then
  if k_write_strobe = '1' then
      uart_tx_reset <= out_port(0);
      sd_power <= out_port(7);
  end if;
end if; 
end process constant_output_ports;


sd_cs_out <= sd_cs;
sd_clk_out <= sd_clk;
  

end Behavioral;