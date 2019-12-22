library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity one_count is port ( 
    a : in  STD_LOGIC_VECTOR (122 downto 0);
    result: out unsigned(7 downto 0)
);
end one_count;

architecture Behavioral of one_count is

begin

process(a)
variable count : unsigned(7 downto 0) := "00000000";
begin
    count := "00000000";
    for i in 0 to 15 loop  
        if(a(i) = '1') then
            count := count + 1; 
        end if;
    end loop;
    result <= count;
end process;

end Behavioral;
