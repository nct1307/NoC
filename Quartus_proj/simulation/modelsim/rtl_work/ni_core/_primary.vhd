library verilog;
use verilog.vl_types.all;
entity ni_core is
    generic(
        MY_X            : integer := 0;
        MY_Y            : integer := 0;
        BUFFER_DEPTH    : integer := 2
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_we_i         : in     vl_logic;
        wb_adr_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_ack_o        : out    vl_logic;
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        channel_out     : out    vl_logic_vector(0 to 35);
        channel_in      : in     vl_logic_vector(0 to 35);
        flow_ctrl_in    : in     vl_logic_vector(0 to 1);
        flow_ctrl_out   : out    vl_logic_vector(0 to 1)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MY_X : constant is 1;
    attribute mti_svvh_generic_type of MY_Y : constant is 1;
    attribute mti_svvh_generic_type of BUFFER_DEPTH : constant is 1;
end ni_core;
