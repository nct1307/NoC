library verilog;
use verilog.vl_types.all;
entity uart is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        addr_i          : in     vl_logic_vector(1 downto 0);
        write_data      : in     vl_logic_vector(31 downto 0);
        write_en        : in     vl_logic;
        i_uart_sel      : in     vl_logic;
        read_data       : out    vl_logic_vector(31 downto 0);
        uart_tx         : out    vl_logic;
        uart_rx         : in     vl_logic
    );
end uart;
