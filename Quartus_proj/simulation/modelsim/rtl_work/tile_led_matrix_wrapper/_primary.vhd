library verilog;
use verilog.vl_types.all;
entity tile_led_matrix_wrapper is
    generic(
        X_COORD         : integer := 2;
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
        led_pins_out    : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of X_COORD : constant is 1;
    attribute mti_svvh_generic_type of Y_COORD : constant is 1;
    attribute mti_svvh_generic_type of BUFFER_DEPTH : constant is 1;
end tile_led_matrix_wrapper;
