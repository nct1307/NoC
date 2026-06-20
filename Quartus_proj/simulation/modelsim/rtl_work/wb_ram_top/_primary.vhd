library verilog;
use verilog.vl_types.all;
entity wb_ram_top is
    generic(
        MEM_SIZE        : integer := 1024
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_we_i         : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_ack_o        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MEM_SIZE : constant is 1;
end wb_ram_top;
