library verilog;
use verilog.vl_types.all;
entity timer is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        we              : in     vl_logic;
        addr            : in     vl_logic_vector(1 downto 0);
        din             : in     vl_logic_vector(31 downto 0);
        dout            : out    vl_logic_vector(31 downto 0);
        current_val     : out    vl_logic_vector(31 downto 0)
    );
end timer;
