library verilog;
use verilog.vl_types.all;
entity gpio_basic is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        addr            : in     vl_logic_vector(1 downto 0);
        we              : in     vl_logic;
        wdata           : in     vl_logic_vector(31 downto 0);
        rdata           : out    vl_logic_vector(31 downto 0);
        gpio_pins       : inout  vl_logic_vector(31 downto 0)
    );
end gpio_basic;
