library verilog;
use verilog.vl_types.all;
entity uart_receiver is
    generic(
        CLKS_PER_BIT    : integer := 87;
        s_IDLE          : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        s_RX_START_BIT  : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        s_RX_DATA_BITS  : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        s_RX_STOP_BIT   : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        s_CLEANUP       : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0)
    );
    port(
        i_Clock         : in     vl_logic;
        i_Rx_Serial     : in     vl_logic;
        o_Rx_DV         : out    vl_logic;
        o_Rx_Byte       : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLKS_PER_BIT : constant is 1;
    attribute mti_svvh_generic_type of s_IDLE : constant is 1;
    attribute mti_svvh_generic_type of s_RX_START_BIT : constant is 1;
    attribute mti_svvh_generic_type of s_RX_DATA_BITS : constant is 1;
    attribute mti_svvh_generic_type of s_RX_STOP_BIT : constant is 1;
    attribute mti_svvh_generic_type of s_CLEANUP : constant is 1;
end uart_receiver;
