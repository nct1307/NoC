library verilog;
use verilog.vl_types.all;
entity tile_core_wrapper is
    generic(
        MY_X            : integer := 0;
        MY_Y            : integer := 0;
        PROG_FILE       : string  := "default.txt"
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
    attribute mti_svvh_generic_type of PROG_FILE : constant is 1;
end tile_core_wrapper;
