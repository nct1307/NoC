library verilog;
use verilog.vl_types.all;
entity uart_transmitter is
    generic(
        CLKS_PER_BIT    : integer := 2;
        s_IDLE          : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi0);
        s_TX_START_BIT  : vl_logic_vector(0 to 2) := (Hi0, Hi0, Hi1);
        s_TX_DATA_BITS  : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi0);
        s_TX_STOP_BIT   : vl_logic_vector(0 to 2) := (Hi0, Hi1, Hi1);
        s_CLEANUP       : vl_logic_vector(0 to 2) := (Hi1, Hi0, Hi0)
    );
    port(
        i_Clock         : in     vl_logic;
        i_Tx_DV         : in     vl_logic;
        i_Tx_Byte       : in     vl_logic_vector(7 downto 0);
        o_Tx_Active     : out    vl_logic;
        o_Tx_Serial     : out    vl_logic;
        o_Tx_Done       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLKS_PER_BIT : constant is 1;
    attribute mti_svvh_generic_type of s_IDLE : constant is 1;
    attribute mti_svvh_generic_type of s_TX_START_BIT : constant is 1;
    attribute mti_svvh_generic_type of s_TX_DATA_BITS : constant is 1;
    attribute mti_svvh_generic_type of s_TX_STOP_BIT : constant is 1;
    attribute mti_svvh_generic_type of s_CLEANUP : constant is 1;
end uart_transmitter;
