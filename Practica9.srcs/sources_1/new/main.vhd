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
    dispOut : inout  std_logic_vector(7 downto 0);
    rs : out std_logic;
    rw : out std_logic;
    enable : out std_logic;
    clk : in std_logic
 );
end main;

architecture Behavioral of main is
    type DISP_STATE is (PowerUp, Init1, Init2, Init3, InitConfig1, InitConfig2, InitConfig3, SendAlberto, InitL2, Pos1_L2, SendDaniel, WaitTime, WaitBF, Idle);
    signal state : DISP_STATE := PowerUp;
    signal nextState: DISP_STATE := PowerUp;
    
    signal alberto : std_logic_vector(0 to 41) := "000001001100000010000101010010010100001111"; --Grupos de 6 bits
    signal daniel : std_logic_vector(0 to 35) := "000100000001001110001001000101001100"; --Grupos de 6 bits

begin

process(clk)
variable timer : integer := 0;
variable timeToWait: integer := 0;
variable currentStart : integer := 0;
variable currentEnd : integer := 5;

begin
    case(state) is
      when(PowerUp) => 
        state <= WaitTime;
        nextState <= Init1;
        timeToWait := 2500000; -- 25 ms
      
      when(Init1) => 
        state <= WaitTime;
        nextState <= Init2;
        timeToWait := 1000000; -- 10 ms
        rs <= '0';
        rw <= '0';
        dispOut <= "00111100";
        enable <= '1';
        
      when(Init2) => 
        state <= WaitTime;
        nextState <= Init3;
        timeToWait := 20000; -- 200 microsegundos
        rs <= '0';
        rw <= '0';
        dispOut <= "00111100";
        enable <= '1';
        
      when(Init3) => 
        state <= WaitTime;
        nextState <= InitConfig1;
        timeToWait := 20000; -- 200 microsegundos
        rs <= '0';
        rw <= '0';
        dispOut <= "00111100";        
        enable <= '1';
      
      when(InitConfig1) =>
        state <= WaitBF;
        nextState <= InitConfig2;
        dispOut <= "00001111";
        rs <= '0';
        rw <= '0';
        enable <= '1';
        
      when(InitConfig2) =>
        state <= WaitBF;
        nextState <= InitConfig3;
        dispOut <= "00000001";
        rs <= '0';
        rw <= '0';
        enable <= '1';

      when(InitConfig3) =>
        state <= WaitBF;
        nextState <= SendAlberto;
        dispOut <= "00000111";
        rs <= '0';
        rw <= '0';
        enable <= '1';
    
    
      when (SendAlberto) => 
        if(currentEnd < 41) then
            state <= WaitBf;
            nextState <= SendAlberto;
            dispOut <= "01" & alberto(0 to 5);
            alberto <= alberto(6 to 41) & "000000";
            rs <= '1';
            rw <= '0';
            enable <= '1';
            currentStart := currentEnd + 1;
            currentEnd := currentEnd + 6;
        else
            currentStart := 0;
            currentEnd := 5;
            nextState <= InitL2; 
        end if;
       
        
      when (InitL2) =>
        state <= WaitBF;
        nextState <= Pos1_L2;
        dispOut <= "00111000";
        rs <= '0';
        rw <= '0';
        enable <= '1';
        
      when (Pos1_L2) =>
        state <= WaitBF;
        nextState <= SendDaniel;
        dispOut <= "11000000";
        rs <= '0';
        rw <= '0';
        enable <= '1';
        
      when (SendDaniel) => 
        if(currentEnd < 35) then
            state <= WaitBf;
            nextState <= SendDaniel;
            dispOut <= "01" & daniel(0 to 5);
            daniel <= daniel(6 to 35) & "000000";
            rs <= '1';
            rw <= '0';
            enable <= '1';
            currentStart := currentEnd + 1;
            currentEnd := currentEnd + 6;
        else
            nextState <= Idle; 
        end if;
        
      when(WaitTime) =>
        enable <= '0';
        timer := timer + 1;
        if(timer > timeToWait) then
            state <= nextState;
            timer := 0;
        end if;
        
      when(WaitBF) => 
        timer := timer + 1;
        enable <= '0';
        rs <= '0';
        rw <= '1';
        
        if(dispOut(7) = '0' and timer > 500000) then
            state <= nextState;
            timer := 0;
        end if;        
      when(Idle) => 
        
      end case;

end process;
    
end Behavioral;
