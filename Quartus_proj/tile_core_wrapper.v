`timescale 1ns / 1ps

module tile_core_wrapper
#(
    parameter MY_X = 0,
    parameter MY_Y = 0,
    parameter PROG_FILE = "default.txt" // Tham so nap file hex cho Core
)
(
    input wire clk,
    input wire rst, 

    // --- Giao tiếp Router (Nối ra NoC Router bên ngoài) ---
    output wire [0:35] ni_ch_out,
    input  wire [0:1]  ni_flow_in,
    input  wire [0:35] ni_ch_in,
    output wire [0:1]  ni_flow_out
);

    // =========================================================================
    // 1. DÂY KET NOI NOI BO (INTERNAL WIRES)
    // =========================================================================

    // --- Giữa Core và Adapter (Giao diện Data Memory Custom) ---
    wire        core_mem_req;
    wire        core_mem_we;
    wire [31:0] core_mem_addr;
    wire [31:0] core_mem_wdata;
    wire [3:0]  core_mem_be;
    wire        core_mem_ready;
    wire [31:0] core_mem_rdata;

    // --- Giữa Adapter và NI (Giao diện Wishbone) ---
    wire        wb_cyc;
    wire        wb_stb;
    wire        wb_we;
    wire [31:0] wb_adr;
    wire [31:0] wb_dat_m2s; // Master to Slave (Adapter -> NI)
    wire [3:0]  wb_sel;
    
    wire        wb_ack;
    wire [31:0] wb_dat_s2m; // Slave to Master (NI -> Adapter)

    // =========================================================================
    // 2. KHỞI TẠO CORE (RV32I)
    // =========================================================================

    RV32I #(
        .PROGRAM_FILE(PROG_FILE) 
    ) core_inst (
        .clk        (clk),
        .rst        (rst), 

        // Output request từ Core
        .mem_req    (core_mem_req),
        .mem_we     (core_mem_we),
        .mem_addr   (core_mem_addr),
        .mem_wdata  (core_mem_wdata),
        .mem_be     (core_mem_be),
        
        // Input phản hồi về Core
        .mem_ready  (core_mem_ready),
        .mem_rdata  (core_mem_rdata)
    );

    // =========================================================================
    // 3. KHỞI TẠO ADAPTER (Wishbone_Core_Adapter)
    // =========================================================================
    
    Wishbone_Core_Adapter adapter_inst (
        .clk_i      (clk),
        .rst_i      (rst), 

        // --- Phía Core (Slave side của Adapter) ---
        .core_req_i   (core_mem_req),
        .core_we_i    (core_mem_we),
        .core_addr_i  (core_mem_addr),
        .core_wdata_i (core_mem_wdata),
        .core_be_i    (core_mem_be),
        .core_ready_o (core_mem_ready),
        .core_rdata_o (core_mem_rdata),

        // --- Phía Wishbone (Master side nối sang NI) ---
        .wb_addr_o    (wb_adr),
        .wb_data_o    (wb_dat_m2s),
        .wb_we_o      (wb_we),
        .wb_stb_o     (wb_stb),
        .wb_cyc_o     (wb_cyc),
        .wb_sel_o     (wb_sel),
        
        .wb_data_i    (wb_dat_s2m),
        .wb_ack_i     (wb_ack)
    );

    // =========================================================================
    // 4. KHỞI TẠO NI (Network Interface - ni_core)
    // =========================================================================
    ni_core #(
        .MY_X(MY_X), 
        .MY_Y(MY_Y)
          
    ) ni_inst (
        .clk        (clk),
        .rst        (rst), 

        // --- Wishbone Slave Interface (Nhận từ Adapter) ---
        .wb_cyc_i   (wb_cyc),
        .wb_stb_i   (wb_stb),
        .wb_we_i    (wb_we),
        .wb_adr_i   (wb_adr),
        .wb_dat_i   (wb_dat_m2s),
        .wb_sel_i   (wb_sel),
        
        .wb_ack_o   (wb_ack),
        .wb_dat_o   (wb_dat_s2m),

        // --- Router Interface (Ra ngoài Wrapper) ---
        .channel_out(ni_ch_out),
        .flow_ctrl_in(ni_flow_in),
        .channel_in (ni_ch_in),
        .flow_ctrl_out(ni_flow_out)
    );

endmodule