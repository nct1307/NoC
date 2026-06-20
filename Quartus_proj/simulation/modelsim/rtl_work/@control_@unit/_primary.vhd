library verilog;
use verilog.vl_types.all;
entity Control_Unit is
    port(
        funct7          : in     vl_logic_vector(6 downto 0);
        opcode          : in     vl_logic_vector(6 downto 0);
        funct3          : in     vl_logic_vector(2 downto 0);
        MemReadD        : out    vl_logic;
        MemWriteD       : out    vl_logic;
        JumpD           : out    vl_logic;
        RegWriteD       : out    vl_logic;
        BranchD         : out    vl_logic;
        MuxjalrD        : out    vl_logic;
        WriteBackD      : out    vl_logic;
        ALUSrcA_D       : out    vl_logic_vector(1 downto 0);
        ALUSrcB_D       : out    vl_logic_vector(1 downto 0);
        ALUOpD          : out    vl_logic_vector(3 downto 0);
        ImmControlD     : out    vl_logic_vector(2 downto 0)
    );
end Control_Unit;
