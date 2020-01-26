-- sends its counter value
-- doesn't send a value each 7th cycle
-- respects the O_tready signal

library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;

entity generator is 
generic (N : integer := 16); 
port (
  clk, aresetn : in std_logic; 
  O_tdata : out unsigned(N - 1 downto 0); 
  O_tvalid : out std_logic; 
  O_tready : in std_logic
);
end generator;

architecture rtl of generator is 
type test_seq is array(0 to 10) of unsigned(N - 1 downto 0);
signal number : unsigned(N - 1 downto 0); 
signal O_tvalid_prim : std_logic; 
signal o_valid     : std_logic;
signal skipWhen6 : unsigned(7 downto 0);
signal counter : integer; 
constant numbers : test_seq := (
        conv_unsigned(2, N),
        conv_unsigned(5, N),
        conv_unsigned(6, N),
        conv_unsigned(3, N),
        conv_unsigned(8, N),
        conv_unsigned(6, N),
        conv_unsigned(11, N),
        conv_unsigned(12, N),
        conv_unsigned(1, N),
        conv_unsigned(6, N),
        conv_unsigned(7, N)
      );
begin

O_tvalid <= O_tvalid_prim; 
O_tvalid_prim <= '1' when skipWhen6 /= conv_unsigned(6, 8) else '0'; 

-- process (counter) is 
-- variable w8 : integer;
-- begin
--    if aresetn = '1' then
--        O_tdata <= conv_unsigned(0, N);
--    else
--        O_tdata <= number;
--    end if;    
-- end process;

 O_tdata <= number;
  process (clk, aresetn) is
  variable w8 : integer;
  variable tmp : unsigned(N - 1 downto 0);
  begin
    if aresetn = '1' then 
      counter <= 1;
      number <= conv_unsigned(2, N);
      skipWhen6 <= conv_unsigned(0, 8);
    elsif clk'event and clk = '1' then 
      if O_tready = '1' then
         if skipWhen6 = conv_unsigned(6, 8) then
            skipWhen6 <= conv_unsigned(0, 8);
        else
            skipWhen6 <= skipWhen6 + 1;
        end if;
         if O_tvalid_prim = '1' then 
            if counter < 10 then
                counter <= counter + 1;
                number <= numbers(counter);
            else
                counter <= counter + 1;
            end if;
         end if;
      end if; 
    end if; 
  end process; 
end rtl; 