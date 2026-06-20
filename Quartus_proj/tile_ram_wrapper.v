module tile_ram_wrapper
#(
    parameter MY_X = 1,
    parameter MY_Y = 1,
    parameter MEM_SIZE = 4096
)
(
    input wire clk,
    input wire rst, 

    // Giao tiếp Router (NoC)
    output wire [0:35] ni_ch_out,
    input  wire [0:1]  ni_flow_in,
    input  wire [0:35] ni_ch_in,
    output wire [0:1]  ni_flow_out
);

    // Dây nối nội bộ (Wishbone signals)
    wire        wb_cyc, wb_stb, wb_we, wb_ack;
    wire [31:0] wb_adr, wb_dat_wr, wb_dat_rd;
    wire [3:0]  wb_sel; 

    // 1. NI RAM (NI đóng vai trò Wishbone Master)
    ni_ip #(
        .MY_X(MY_X), 
        .MY_Y(MY_Y)
    ) ni_inst (
        .clk(clk), 
        .rst(rst), 
        
        // Phía RAM (Wishbone Master)
        .wb_cyc_o(wb_cyc), 
        .wb_stb_o(wb_stb), 
        .wb_we_o (wb_we),
        .wb_adr_o(wb_adr), 
        .wb_dat_o(wb_dat_wr),
        .wb_sel_o(wb_sel), 
        
        .wb_ack_i(wb_ack), 
        .wb_dat_i(wb_dat_rd),
        
        // Phía Router
        .channel_out  (ni_ch_out), 
        .flow_ctrl_in (ni_flow_in),
        .channel_in   (ni_ch_in), 
        .flow_ctrl_out(ni_flow_out)
    );

    // 2. RAM SYSTEM (WB RAM TOP - Wishbone Slave)
    wb_ram_top #(
        .MEM_SIZE(MEM_SIZE)
    ) ram_inst (
        .clk_i    (clk),
        .rst_i    (rst), 

        // Phía NI
        .wb_cyc_i (wb_cyc),
        .wb_stb_i (wb_stb),
        .wb_we_i  (wb_we),
        .wb_adr_i (wb_adr),
        .wb_dat_i (wb_dat_wr),
        .wb_sel_i (wb_sel), 
        
        .wb_ack_o (wb_ack),
        .wb_dat_o (wb_dat_rd)
    );

endmodule