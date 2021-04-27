----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2021 02:48:06 PM
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
 Port (
    dispOut : out  std_logic_vector(7 downto 0);
    rs : out std_logic;
    rw : out std_logic;
    enable : out std_logic;
    clk : in std_logic
 );
end main;

ARCHITECTURE behavior OF main IS
  SIGNAL   lcd_enable : STD_LOGIC;
  SIGNAL   lcd_bus    : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL   lcd_busy   : STD_LOGIC;
  COMPONENT lcd_controller IS
    PORT(
       clk        : IN  STD_LOGIC; --system clock
       reset_n    : IN  STD_LOGIC; --active low reinitializes lcd
       lcd_enable : IN  STD_LOGIC; --latches data into lcd controller
       lcd_bus    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0); --data and control signals
       busy       : OUT STD_LOGIC; --lcd controller busy/idle feedback
       rw, rs, e  : OUT STD_LOGIC; --read/write, setup/data, and enable for lcd
       lcd_data   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)); --data signals for lcd
  END COMPONENT;
BEGIN

  --instantiate the lcd controller
  dut: lcd_controller
    PORT MAP(clk => clk, reset_n => '1', lcd_enable => lcd_enable, lcd_bus => lcd_bus, 
             busy => lcd_busy, rw => rw, rs => rs, e => enable, lcd_data => dispOut);
  
  PROCESS(clk)
    VARIABLE char  :  INTEGER RANGE 0 TO 16 := 0;
  BEGIN
    IF(clk'EVENT AND clk = '1') THEN
      IF(lcd_busy = '0' AND lcd_enable = '0') THEN
        lcd_enable <= '1';
        IF(char < 16) THEN
          char := char + 1;
        END IF;
        CASE char IS
          WHEN 1 => lcd_bus <= "1001000001"; -- A
          WHEN 2 => lcd_bus <= "1001001100"; -- L
          WHEN 3 => lcd_bus <= "1001000010"; -- B
          WHEN 4 => lcd_bus <= "1001000101"; -- E
          WHEN 5 => lcd_bus <= "1001010010"; -- R
          WHEN 6 => lcd_bus <= "1001010100"; -- T
          WHEN 7 => lcd_bus <= "1001001111"; -- O
          WHEN 8 => lcd_bus <= "0011000000"; -- Cambiar línea
          WHEN 9 => lcd_bus <= "1001000100"; -- D
          WHEN 10 => lcd_bus <= "1001000001"; -- A
          WHEN 12 => lcd_bus <= "1001001110"; -- N
          WHEN 13 => lcd_bus <= "1001001001"; -- I
          WHEN 14 => lcd_bus <= "1001000101"; -- E
          WHEN 15 => lcd_bus <= "1001001100"; -- L
          WHEN OTHERS => lcd_enable <= '0';
        END CASE;
      ELSE
        lcd_enable <= '0';
      END IF;
    END IF;
  END PROCESS;
  
END behavior;
