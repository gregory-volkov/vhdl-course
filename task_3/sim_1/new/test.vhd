library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.p.all;

entity test is 
    constant N : integer := 16;
    constant k : integer := 3;
end entity; 

architecture beh of test is 
signal clk:  std_logic;
signal aresetn : std_logic;

signal I_tvalid : std_logic; 
signal I_tready : std_logic;
signal I_tdata  : unsigned(N - 1 downto 0);

signal O_tvalid : std_logic;
signal O_tready : std_logic;
signal O_tdata  : std_logic_vector(23 downto 0);

begin
  			
  aresetn <= '1', '0' after 40 ns;

--  process is 
--  begin
--    while true loop 
--      clk <= '0'; 
--      wait for 5 ns;
--      clk <= '1' ;
--      wait for 5 ns; 
--    end loop; 
--  end process; 
  
process is 
begin 
    clk <= '0';
    wait for 5 ns;
    clk <= '1';
    wait for 5 ns;
end process;
  
  G : entity work.generator
  generic map (N => N)
  port map (
    aresetn => aresetn, clk => clk,
    O_tdata => I_tdata,
	O_tvalid => I_tvalid,
    O_tready => I_tready
  ); 

  DUT : entity work.bin_tree
  generic map (N => N, k => k)
  port map (clk => clk, aresetn => aresetn, I_tvalid => I_tvalid,
            I_tready => I_tready, I_tdata => I_tdata, O_tvalid => O_tvalid,
				O_tready => O_tready, O_tdata => O_tdata);
	
  R : entity work.reciever
    generic map (N => N)
  port map ( 
    aresetn => aresetn, clk => clk, 
    I_tdata => O_tdata,
	 I_tvalid => O_tvalid,
    I_tready => O_tready
  );

end beh;
 