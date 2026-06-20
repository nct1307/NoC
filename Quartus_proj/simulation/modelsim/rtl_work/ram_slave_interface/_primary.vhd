library verilog;
use verilog.vl_types.all;
entity ram_slave_interface is
    port(
        clk_i           : in     vl_logic;
        rst             : in     vl_logic;
        wb_addr_i       : in     vl_logic_vector(31 downto 0);
        wb_data_i       : in     vl_logic_vector(31 downto 0);
        wb_data_o       : out    vl_logic_vector(31 downto 0);
        wb_we_i         : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_ack_o        : out    vl_logic;
        mem_addr_o      : out    vl_logic_vector(31 downto 0);
        mem_wdata_o     : out    vl_logic_vector(31 downto 0);
        mem_rdata_i     : in     vl_logic_vector(31 downto 0);
        mem_we_o        : out    vl_logic;
        mem_en_o        : out    vl_logic;
        mem_sel_o       : out    vl_logic_vector(3 downto 0)
    );
end ram_slave_interface;
