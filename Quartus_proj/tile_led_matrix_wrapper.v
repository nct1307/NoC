module tile_led_matrix_wrapper
#(
    parameter X_COORD = 2,      // Tọa độ X
    parameter Y_COORD = 1,      // Tọa độ Y
    parameter BUFFER_DEPTH = 3
)
(
    input wire clk,
    input wire rst, // [CHUẨN HÓA] Active High Reset

    // --- Giao tiếp với Router (NoC) ---
    input  wire [0:35] ni_ch_in,    // Input từ Router
    input  wire [0:1]  ni_flow_in,  // Flow control từ Router
    output wire [0:35] ni_ch_out,   // Output tới Router
    output wire [0:1]  ni_flow_out, // Flow control tới Router

    // --- Phần cứng LED (Nối ra chân FPGA) ---
    output wire [31:0] led_pins_out
);

    // Dây nối trung gian chuẩn Wishbone
    wire        wb_cyc;
    wire        wb_stb;
    wire        wb_we;
    wire [31:0] wb_adr;
    wire [31:0] wb_dat_m2s; // Master to Slave (Ghi vào LED)
    wire [31:0] wb_dat_s2m; // Slave to Master (Đọc từ LED)
    wire [3:0]  wb_sel;
    wire        wb_ack;

    // [ĐÃ XÓA] wire rst_high = ~rst_n; -> Không cần nữa vì input đã là mức cao

    // =========================================================
    // 1. INSTANCE: NETWORK INTERFACE (Dùng lại ni_ip)
    // =========================================================
    ni_ip #(
        .MY_X(X_COORD),
        .MY_Y(Y_COORD),
        .BUFFER_DEPTH(BUFFER_DEPTH)
    ) ni_inst (
        .clk           (clk),
        .rst           (rst), // [SỬA] Nối thẳng rst mức cao vào (Module ni_ip đã sửa)

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
    // 2. INSTANCE: LED MATRIX TOP
    // =========================================================
    wb_led_matrix_top led_system_inst (
        .clk_i    (clk),
        .rst      (rst), // [SỬA] Nối thẳng rst mức cao (Module này vốn dĩ đã là mức cao)

        // Wishbone Slave Side
        .wb_cyc_i (wb_cyc),
        .wb_stb_i (wb_stb),
        .wb_we_i  (wb_we),
        .wb_adr_i (wb_adr),
        .wb_dat_i (wb_dat_m2s),
        .wb_sel_i (wb_sel),
        .wb_ack_o (wb_ack),
        .wb_dat_o (wb_dat_s2m),

        // LED Hardware Output
        .led_pins (led_pins_out)
    );

endmodule