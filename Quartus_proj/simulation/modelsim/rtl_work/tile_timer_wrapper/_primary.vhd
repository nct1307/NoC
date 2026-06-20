library verilog;
use verilog.vl_types.all;
entity tile_timer_wrapper is
    generic(
        X_COORD         : integer := 0;
        Y_COORD         : integer := 1;
        BUFFER_DEPTH    : integer := 3
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        ni_ch_in        : in     vl_logic_vector(0 to 35);
        ni_flow_in      : in     vl_logic_vector(0 to 1);
        ni_ch_out       : out    vl_logic_vector(0 to 35);
        ni_flow_out     : out    vl_logic_vector(0 to 1);
        timer_debug_leds: out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of X_COORD : constant is 1;
    attribute mti_svvh_generic_type of Y_COORD : constant is 1;
    attribute mti_svvh_generic_type of BUFFER_DEPTH : constant is 1;
end tile_timer_wrapper;
