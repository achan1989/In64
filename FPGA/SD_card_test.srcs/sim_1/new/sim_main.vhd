----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.08.2013 13:49:00
-- Design Name: 
-- Module Name: main_sim - Behavioral
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

entity main_sim is
    Port ( uart_tx : out std_ulogic;
           sd_cs_out : out std_ulogic;
           sd_clk_out : out std_ulogic;
           sd_mosi : out std_ulogic);
end main_sim;


architecture sim_arch of main_sim is

component main
    Port ( clk : in std_ulogic;
            reset_switch : in std_ulogic;
            uart_tx : out std_ulogic;
           sd_cs_out : out std_ulogic;
           sd_clk_out : out std_ulogic;
           sd_mosi : out std_ulogic;
               sd_miso : in std_ulogic);
end component;

signal clk : std_ulogic := '0';
signal sd_miso : std_ulogic := '0';
signal reset : std_ulogic := '1';

begin

main_being_tested: main
    port map(   clk => clk,
                reset_switch => reset,
                uart_tx => uart_tx,
                sd_cs_out =>sd_cs_out,
                sd_clk_out => sd_clk_out,
                sd_mosi => sd_mosi,
                sd_miso => sd_miso);
                
input_clock: process begin
    clk <= '0';
    sd_miso <= '1';
    wait for 10ns;
    clk <= '1';
    sd_miso <= '0';
    wait for 10ns;
end process;

end sim_arch;
