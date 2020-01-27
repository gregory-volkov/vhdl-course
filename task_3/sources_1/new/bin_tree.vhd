library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package p is
    constant k : integer := 3;
    constant N : integer := 16;
    -- M is a constant which parameterize the amount of bits for std_logic_vector representation of the output
    constant M : integer := 18;
    type tnode is record
        data : unsigned(N - 1 downto 0);
        undefined : std_logic;
    end record;
    type tlevel is array (0 to 2 ** (k - 1) - 1) of tnode;
    type tlevels is array (integer range <>) of tlevel;
    type tstatus is (inserted, found, overflow, invalid, search);
    type tnode_s is record
        data: unsigned(N - 1 downto 0);
        index: integer;
        stat: tstatus;
    end record;
    type toutput is record
        stat: tstatus;
        data: unsigned(N - 1 downto 0);
    end record;
    type tpipeline_data is array (integer range <>) of tnode_s;
    
    function vector2toutput (
        i_vector : in std_logic_vector(23 downto 0))
    return toutput;

    function toutput2vector (
        i_toutput : in toutput)
    return std_logic_vector;

end p;

package body p is
 
    function vector2toutput (
        i_vector : in std_logic_vector(23 downto 0))
    return toutput is
        variable bin_status : std_logic_vector(1 downto 0);
        variable status : tstatus;
        variable number : std_logic_vector(N - 1 downto 0);
    begin
        bin_status := i_vector(M - 1 downto M - 2);
        case bin_status is
            when "00" => status := invalid;
            when "01" => status := inserted;
            when "10" => status := found;
            when "11" => status := overflow;
            when others => status := invalid; 
        end case;
        number := i_vector(M - 3 downto 0);
        return (data => unsigned(number), stat => status);
    end;

    function toutput2vector (
        i_toutput : in toutput)
    return std_logic_vector is
        variable bin_status : std_logic_vector(1 downto 0);
        variable status : tstatus;
        variable out_number : std_logic_vector(N - 1 downto 0);
        variable number : unsigned(N - 1 downto 0);
    begin
        status := i_toutput.stat;
        number := i_toutput.data;
        case status is
            when invalid => bin_status := "00"; 
            when inserted => bin_status := "01";
            when found => bin_status := "10";
            when overflow => bin_status := "11";
            when others => bin_status := "00"; 
        end case;
        out_number := std_logic_vector(number);
        return (23 downto 18 => '0') & bin_status & out_number ;
    end;

end package body p;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.p.all;

entity bin_tree is
    generic (
        k : integer := k;
        N : integer := N;
        M : integer := M
    );
    port (
    clk : in std_logic;
    aresetn  : in std_logic;
    
    I_tvalid : in std_logic;
    I_tdata  : in unsigned(15 downto 0);
	I_tready : out std_logic;
    
    O_tvalid : out std_logic;
    O_tdata  : out std_logic_vector(23 downto 0);
	O_tready : in std_logic
    );
end bin_tree;

architecture rtl of bin_tree is
signal inputs : tpipeline_data(0 to k);
signal zero : unsigned(15 downto 0) := (others => '0');
signal zero_node : tnode := (data => conv_unsigned(0, N),
                                   undefined => '1'); 
signal zero_level : tlevel := (others => zero_node);
signal levels : tlevels(0 to k) := (others => zero_level);

begin
    process (clk) is 
    variable value : unsigned(N - 1 downto 0);
    variable id : integer;
    variable cur : tnode_s;
    variable w8 : integer;
    begin
        if aresetn = '1' then
	           for i in 0 to k loop
	               inputs(i).index <= 0;
	               inputs(i).data <= zero;
	               inputs(i).stat <= invalid;
	           end loop;
	           w8 := 0;
	    else
	       if clk'event and clk = '1' then
	           if O_tready = '1' then
                    
                    -- Moving data inside pipeline
                    for i in k - 1 downto 0 loop
                        cur := inputs(i);
                        id := cur.index;
                        value := cur.data;
                        if inputs(i).stat = search then
                            if levels(i)(id).undefined = '1' then
                                levels(i)(id).data <= cur.data;
                                levels(i)(id).undefined <= '0';
                                cur.stat := inserted;
                            else
                                if levels(i)(id).data = value then
                                    cur.stat := found;
                                end if;
                                if levels(i)(id).data < value then
                                    cur.index := id * 2 + 1;
                                end if;
                                if levels(i)(id).data > value then
                                    cur.index := id * 2;
                                end if;
                            end if;
                        end if;
                        inputs(i + 1) <= cur;
                    end loop;
                    inputs(0).data <= I_tdata;
                    if I_tvalid = '1' then
                        inputs(0).stat <= search;
                    else
                        inputs(0).stat <= invalid;
                    end if;
                end if;
           end if;
       end if;
end process;

I_tready <= O_tready;
O_tvalid <= '1' when not(inputs(k).stat = invalid) else '0';
O_tdata <= toutput2vector((data => inputs(k).data, stat => overflow)) 
    when inputs(k).stat = search 
    else toutput2vector((data => inputs(k).data, stat => inputs(k).stat));

end rtl;
