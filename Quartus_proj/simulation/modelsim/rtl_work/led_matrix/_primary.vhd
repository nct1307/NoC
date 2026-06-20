library verilog;
use verilog.vl_types.all;
entity led_matrix is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        addr_i          : in     vl_logic_vector(1 downto 0);
        write_data      : in     vl_logic_vector(31 downto 0);
        write_en        : in     vl_logic;
        read_data       : out    vl_logic_vector(31 downto 0);
        led_pins        : out    vl_logic_vector(31 downto 0)
    );
end led_matrix;
