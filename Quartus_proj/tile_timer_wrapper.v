module tile_timer_wrapper
#(
    parameter X_COORD = 0,      // Tọa độ X của Tile này
    parameter Y_COORD = 1,      // Tọa độ Y của Tile này
    parameter BUFFER_DEPTH = 3
)
(
    input wire clk,
    input wire rst, 

    // --- Giao tiếp với Router (NoC) ---
    input  wire [0:35] ni_ch_in,    // Input từ Router
    input  wire [0:1]  ni_flow_in,  // Flow control từ Router
    output wire [0:35] ni_ch_out,   // Output tới Router
    output wire [0:1]  ni_flow_out, // Flow control tới Router

    // --- Debug Output (Nối ra LED trên Board) ---
    output wire [31:0] timer_debug_leds
);

    // Dây nối trung gian chuẩn Wishbone
    wire        wb_cyc;
    wire        wb_stb;
    wire        wb_we;
    wire [31:0] wb_adr;
    wire [31:0] wb_dat_m2s; // Master to Slave (Ghi vào Timer)
    wire [31:0] wb_dat_s2m; // Slave to Master (Đọc từ Timer)
    wire [3:0]  wb_sel;
    wire        wb_ack;

    // =========================================================
    // 1. INSTANCE: NETWORK INTERFACE
    // =========================================================
    // NI đóng vai trò Wishbone Master
    ni_ip #(
        .MY_X(X_COORD),
        .MY_Y(Y_COORD),
        .BUFFER_DEPTH(BUFFER_DEPTH)
    ) ni_timer (
        .clk           (clk),
        .rst           (rst), 

        // NoC Side
        .channel_in    (ni_ch_in),
        .flow_ctrl_in  (ni_flow_in),
        .channel_out   (ni_ch_out),
        .flow_ctrl_out (ni_flow_out),

        // Wishbone Master Side
        .wb_cyc_o      (wb_cyc),
        .wb_stb_o      (wb_stb),
        .wb_we_o       (wb_we),
        .wb_adr_o      (wb_adr),
        .wb_dat_o      (wb_dat_m2s),
        .wb_sel_o      (wb_sel),
        .wb_ack_i      (wb_ack),
        .wb_dat_i      (wb_dat_s2m)
    );

    // =========================================================
    // 2. INSTANCE: TIMER TOP (Bao gồm Adapter + Timer Core)
    // =========================================================
    // Timer đóng vai trò Wishbone Slave
    wb_timer_top timer_system_inst (
        .clk_i    (clk),
        .rst      (rst), 

        // Wishbone Slave Side
        .wb_cyc_i (wb_cyc),
        .wb_stb_i (wb_stb),
        .wb_we_i  (wb_we),
        .wb_adr_i (wb_adr),
        .wb_dat_i (wb_dat_m2s),
        .wb_sel_i (wb_sel),
        .wb_ack_o (wb_ack),
        .wb_dat_o (wb_dat_s2m),

        // Debug Output
        .timer_value (timer_debug_leds)
    );

endmodule