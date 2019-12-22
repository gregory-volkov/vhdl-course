library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vec_mul is 
    generic ( N : integer := 2);
    port (
        clk : in std_logic;
        is_a : in std_logic;
        is_b : in std_logic;
        rst : in std_logic;
        
        x_in: in std_logic_vector(N - 1 downto 0);
        y_in: in std_logic_vector(N - 1 downto 0);
        z_in: in std_logic_vector(N - 1 downto 0);
        
        x_out : out signed(2 * N - 1 downto 0);
        y_out : out signed(2 * N - 1 downto 0);
        z_out : out signed(2 * N - 1 downto 0));
end vec_mul;

architecture rtl of vec_mul is 
    signal a_x, a_y, a_z :  signed(N - 1 downto 0);
begin 
    process (clk) is 
    begin
        if clk'event and clk = '1' then
            if rst = '1' then
                a_x <= to_signed(0, N);
                a_y <= to_signed(0, N);
                a_z <= to_signed(0, N);
            else
                if is_a = '1' then
                    a_x <= signed(x_in);
                    a_y <= signed(y_in);
                    a_z <= signed(z_in);
                end if;
                if is_b = '1' then
                    x_out <= a_y * signed(z_in) - a_z * signed(y_in);
                    y_out <= a_z * signed(x_in) - a_x * signed(z_in);
                    z_out <= a_x * signed(y_in) - a_y * signed(x_in);
                end if;
            end if;
        end if;
    end process;
end rtl;
