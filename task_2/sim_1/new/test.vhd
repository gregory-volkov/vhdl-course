library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test is end entity;

architecture rtl of test is
constant bits_n : integer := 3;
signal clk, rst, is_a, is_b : std_logic;
signal x_in, y_in, z_in : std_logic_vector(bits_n - 1 downto 0);

procedure delay(n: integer; signal clk: std_logic) is 
begin
    for i in 1 to n loop
        wait until clk'event and clk = '1';
    end loop;
end delay;

begin


DUT: entity work.vec_mul 
    generic map(N => bits_n)
    port map(rst => rst, clk => clk, is_a => is_a, is_b => is_b, x_in => x_in, y_in => y_in, z_in => z_in);

rst <= '1', '0' after 20 ns; 

process is 
begin 
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
end process;

process is 
begin
    is_b <= '0';
    is_a <= '1';
    
    -- a = 2i - 1j - 4k
    x_in <= B"010";
    y_in <= B"111";
    z_in <= B"100";    
    
    delay(3, clk);
    is_a <= '0';
    delay(1, clk);
    
    -- b = 2i + 1j - 2k
    x_in <= B"010";
    y_in <= B"001";
    z_in <= B"110";
    delay(1, clk);
    
    -- The answer should be:
    -- '000110'i
    -- '111100'j
    -- '000100'k
    
    is_b <= '1';
    
    delay(10, clk);
end process;

end rtl;
