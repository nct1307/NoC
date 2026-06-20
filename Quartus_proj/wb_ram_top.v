module wb_ram_top #(
    parameter MEM_SIZE = 1024
) (
    input wire clk_i,
    input wire rst_i, 
    
    // Wishbone Interface
    input wire [31:0] wb_adr_i,
    input wire [31:0] wb_dat_i,
    input wire [3:0]  wb_sel_i,
    input wire        wb_we_i,
    input wire        wb_cyc_i,
    input wire        wb_stb_i,
    
    output wire [31:0] wb_dat_o, 
    output wire        wb_ack_o  
);

    // --- Dây nối nội bộ ---
    wire [31:0] w_addr;
    wire [31:0] w_wdata;
    wire [31:0] w_rdata; 
    wire [3:0]  w_be;
    wire        w_we;
    wire        w_en;

    // =================================================================
    // 1. GỌI ADAPTER: ram_slave_interface (Bản mới có FSM)
    // =================================================================
    ram_slave_interface adapter_inst (
        .clk_i      (clk_i),
        .rst        (rst_i), // Map: rst_i (Top) -> rst (Adapter)

        // --- Phía Wishbone (Nối ra ngoài Top) ---
        .wb_addr_i  (wb_adr_i),    
        .wb_data_i  (wb_dat_i),    
        .wb_data_o  (wb_dat_o),    
        .wb_we_i    (wb_we_i),
        .wb_stb_i   (wb_stb_i),
        .wb_cyc_i   (wb_cyc_i),
        .wb_sel_i   (wb_sel_i),
        .wb_ack_o   (wb_ack_o),

        // --- Phía RAM (Nối vào module RAM bên dưới) ---
        .mem_addr_o (w_addr),
        .mem_wdata_o(w_wdata),
        .mem_rdata_i(w_rdata),   
        .mem_we_o   (w_we),
        .mem_en_o   (w_en),
        .mem_sel_o  (w_be)
    );

    // =================================================================
    // 2. RAM CORE
    // =================================================================
    ram #(
        .MEM_SIZE(MEM_SIZE)
    ) ram_inst (
        .clk   (clk_i),
        .rst   (rst_i), 
        
        // Input từ Adapter
        .addr  (w_addr),
        .wdata (w_wdata),
        .be    (w_be),
        .we    (w_we),
        .en    (w_en),
        
        // Output trả về Adapter
        .rdata (w_rdata) 
    );

endmodule