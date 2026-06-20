library verilog;
use verilog.vl_types.all;
entity RV32I is
    generic(
        PROGRAM_FILE    : string  := "default.txt"
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        mem_ready       : in     vl_logic;
        mem_rdata       : in     vl_logic_vector(31 downto 0);
        mem_req         : out    vl_logic;
        mem_we          : out    vl_logic;
        mem_addr        : out    vl_logic_vector(31 downto 0);
        mem_wdata       : out    vl_logic_vector(31 downto 0);
        mem_be          : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PROGRAM_FILE : constant is 1;
end RV32I;
