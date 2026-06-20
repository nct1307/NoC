library verilog;
use verilog.vl_types.all;
entity Wishbone_Core_Adapter is
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        core_req_i      : in     vl_logic;
        core_we_i       : in     vl_logic;
        core_addr_i     : in     vl_logic_vector(31 downto 0);
        core_wdata_i    : in     vl_logic_vector(31 downto 0);
        core_be_i       : in     vl_logic_vector(3 downto 0);
        core_ready_o    : out    vl_logic;
        core_rdata_o    : out    vl_logic_vector(31 downto 0);
        wb_data_i       : in     vl_logic_vector(31 downto 0);
        wb_ack_i        : in     vl_logic;
        wb_addr_o       : out    vl_logic_vector(31 downto 0);
        wb_data_o       : out    vl_logic_vector(31 downto 0);
        wb_we_o         : out    vl_logic;
        wb_stb_o        : out    vl_logic;
        wb_cyc_o        : out    vl_logic;
        wb_sel_o        : out    vl_logic_vector(3 downto 0)
    );
end Wishbone_Core_Adapter;
