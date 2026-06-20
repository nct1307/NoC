library verilog;
use verilog.vl_types.all;
entity alu is
    port(
        A               : in     vl_logic_vector(31 downto 0);
        B               : in     vl_logic_vector(31 downto 0);
        opcode          : in     vl_logic_vector(3 downto 0);
        branch          : in     vl_logic_vector(2 downto 0);
        result          : out    vl_logic_vector(31 downto 0);
        Z               : out    vl_logic
    );
end alu;
