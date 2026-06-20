module tile_gpio_wrapper
#(
    parameter X_COORD = 1,      // Tọa độ X mặc định
    parameter Y_COORD = 0,      // Tọa độ Y mặc định
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

    // --- External Pins (Nối ra chân IO thực tế) ---
    inout  wire [31:0] gpio_pins    // Chân GPIO 3 chiều
);

    // Dây nối trung gian chuẩn Wishbone
    wire        wb_cyc;
    wire        wb_stb;
    wire        wb_we;
    wire [31:0] wb_adr;
    wire [31:0] wb_dat_m2s; // Master (NI) -> Slave (GPIO)
    wire [31:0] wb_dat_s2m; // Slave (GPIO) -> Master (NI)
    wire [3:0]  wb_sel;     // NI có xuất, nhưng Adapter GPIO không dùng (bỏ qua)
    wire        wb_ack;

    // =========================================================
    // 1. INSTANCE: NETWORK INTERFACE (Wishbone Master)
    // =========================================================
    ni_ip #(
        .MY_X(X_COORD),
        .MY_Y(Y_COORD),
        .BUFFER_DEPTH(BUFFER_DEPTH)
    ) ni_gpio (
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
        .wb_sel_o      (wb_sel),      // Kết nối wire vào đây
        .wb_ack_i      (wb_ack),
        .wb_dat_i      (wb_dat_s2m)
    );

    // =========================================================
    // 2. INSTANCE: GPIO ADAPTER (Wishbone Slave)
    // =========================================================
    // Module này đã chứa "gpio_basic" bên trong
    wishbone_gpio gpio_system_inst (
        .clk_i     (clk),
        .rst       (rst), 

        // Wishbone Interface
        // Adapter lấy địa chỉ, dữ liệu từ Master (NI)
        .wb_addr_i (wb_adr),      
        .wb_data_i (wb_dat_m2s),  
        .wb_we_i   (wb_we),
        .wb_stb_i  (wb_stb),
        .wb_cyc_i  (wb_cyc),
        
        // Adapter trả dữ liệu, ack về Master (NI)
        .wb_data_o (wb_dat_s2m),
        .wb_ack_o  (wb_ack),

        // External Pins
        .gpio_pins (gpio_pins)
    );

endmodule