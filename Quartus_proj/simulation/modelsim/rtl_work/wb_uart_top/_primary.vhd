library verilog;
use verilog.vl_types.all;
entity wb_uart_top is
    port(
        clk_i           : in     vl_logic;
        rst             : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_we_i         : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_ack_o        : out    vl_logic;
        uart_tx         : out    vl_logic;
        uart_rx         : in     vl_logic
    );
end wb_uart_top;
