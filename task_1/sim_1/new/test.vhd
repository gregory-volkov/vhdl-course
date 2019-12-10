library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test is end entity;
architecture beh of test is
signal a: STD_LOGIC_VECTOR (122 downto 0);

begin 
    DUT: entity work.one_count port map(a => a);
    
    process is begin
    a <= (10 downto 1 => '1', others => '0');  
    wait for 10 ns;
    end process;
    
end beh;