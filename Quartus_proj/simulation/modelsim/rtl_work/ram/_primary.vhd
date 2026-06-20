library verilog;
use verilog.vl_types.all;
entity ram is
    generic(
        MEM_SIZE        : integer := 1024
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        addr            : in     vl_logic_vector(31 downto 0);
        wdata           : in     vl_logic_vector(31 downto 0);
        be              : in     vl_logic_vector(3 downto 0);
        we              : in     vl_logic;
        en              : in     vl_logic;
        rdata           : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MEM_SIZE : constant is 1;
end ram;
