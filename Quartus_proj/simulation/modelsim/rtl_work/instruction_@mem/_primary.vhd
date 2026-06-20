library verilog;
use verilog.vl_types.all;
entity instruction_Mem is
    generic(
        TEST_FILE       : string  := "E:/Documents/DA1/code_noc/Quartus_proj/program_default.txt"
    );
    port(
        addr            : in     vl_logic_vector(31 downto 0);
        inst            : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of TEST_FILE : constant is 1;
end instruction_Mem;
