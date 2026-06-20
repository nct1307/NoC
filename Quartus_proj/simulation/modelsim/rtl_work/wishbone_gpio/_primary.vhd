library verilog;
use verilog.vl_types.all;
entity wishbone_gpio is
    port(
        clk_i           : in     vl_logic;
        rst             : in     vl_logic;
        wb_addr_i       : in     vl_logic_vector(31 downto 0);
        wb_data_i       : in     vl_logic_vector(31 downto 0);
        wb_we_i         : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_data_o       : out    vl_logic_vector(31 downto 0);
        wb_ack_o        : out    vl_logic;
        gpio_pins       : inout  vl_logic_vector(31 downto 0)
    );
end wishbone_gpio;
