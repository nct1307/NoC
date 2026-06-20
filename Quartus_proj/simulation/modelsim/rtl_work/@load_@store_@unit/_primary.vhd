library verilog;
use verilog.vl_types.all;
entity Load_Store_Unit is
    port(
        funct3          : in     vl_logic_vector(2 downto 0);
        addr_offset     : in     vl_logic_vector(1 downto 0);
        mem_write       : in     vl_logic;
        data_store_in   : in     vl_logic_vector(31 downto 0);
        data_load_in    : in     vl_logic_vector(31 downto 0);
        mem_be          : out    vl_logic_vector(3 downto 0);
        mem_wdata       : out    vl_logic_vector(31 downto 0);
        data_load_out   : out    vl_logic_vector(31 downto 0)
    );
end Load_Store_Unit;
