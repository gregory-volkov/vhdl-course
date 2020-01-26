library ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all;
use work.p.all; 

entity reciever is 
generic (N : integer := 16); 
port (
  clk, aresetn : in std_logic; 
  I_tdata : in toutput; 
  I_tvalid : in std_logic; 
  I_tready : out std_logic
);
end reciever ;

architecture rtl of reciever is 
type test_seq is array(0 to 10) of toutput;
signal number : unsigned(N - 1 downto 0); 
signal O_tvalid_prim : std_logic; 
signal o_valid     : std_logic;
signal freezeWhen7 : unsigned(7 downto 0);
signal counter : integer; 
constant answers : test_seq := (
        (stat => inserted, data => conv_unsigned(2, N)),
        (stat => inserted, data => conv_unsigned(5, N)),
        (stat => inserted, data => conv_unsigned(6, N)),
        (stat => inserted, data => conv_unsigned(3, N)),
        (stat => overflow, data => conv_unsigned(8, N)),
        (stat => found, data => conv_unsigned(6, N)),
        (stat => overflow, data => conv_unsigned(11, N)),
        (stat => overflow, data => conv_unsigned(12, N)),
        (stat => inserted, data => conv_unsigned(1, N)),
        (stat => inserted, data => conv_unsigned(6, N)),
        (stat => overflow, data => conv_unsigned(7, N))
      );
begin

I_tready <= '1' when freezeWhen7 /= conv_unsigned(7, 8) else '0';

  process (clk, aresetn) is
  variable w8 : std_logic;
  variable tmp : unsigned(N - 1 downto 0);
  
  begin
    if aresetn = '1' then 
      counter <= 0;
      freezeWhen7 <= conv_unsigned(0, 8);
    elsif clk'event and clk = '1' then 
        if freezeWhen7 = conv_unsigned(7, 8) then
            freezeWhen7 <= conv_unsigned(0, 8);
        else
            freezeWhen7 <= freezeWhen7 + 1;
        end if;
        if I_tvalid = '1' then
            assert I_tdata = answers(counter) report "Correct answer" severity warning;
            counter <= counter + 1; 
         end if;
    end if; 
  end process; 
end rtl; 