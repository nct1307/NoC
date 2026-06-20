library verilog;
use verilog.vl_types.all;
entity tile_ram_wrapper is
    generic(
        MY_X            : integer := 1;
        MY_Y            : integer := 1;
        MEM_SIZE        : integer := 4096
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        ni_ch_out       : out    vl_logic_vector(0 to 35);
        ni_flow_in      : in     vl_logic_vector(0 to 1);
        ni_ch_in        : in     vl_logic_vector(0 to 35);
        ni_flow_out     : out    vl_logic_vector(0 to 1)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MY_X : constant is 1;
    attribute mti_svvh_generic_type of MY_Y : constant is 1;
    attribute mti_svvh_generic_type of MEM_SIZE : constant is 1;
end tile_ram_wrapper;
