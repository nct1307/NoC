//module ram_slave_interface (
//    input wire clk_i,
//    input wire rst_i,
//
//    // Wishbone Inputs
//    input wire [31:0] wb_adr_i,
//    input wire [31:0] wb_dat_i,
//    input wire [3:0]  wb_sel_i,
//    input wire        wb_we_i,
//    input wire        wb_cyc_i,
//    input wire        wb_stb_i,
//    
//    // Wishbone Output: CH? CÓ ACK THÔI (Data ?? th?ng RAM lo)
//    output reg        wb_ack_o, 
//
//    // RAM Control Signals
//    output wire [31:0] ram_addr,
//    output wire [31:0] ram_wdata,
//    output wire [3:0]  ram_be,
//    output wire        ram_we,
//    output wire        ram_en
//);
//    // --- Logic Gi?i mã ---
//    assign ram_en = wb_cyc_i && wb_stb_i;
//    assign ram_we = ram_en && wb_we_i;
//    
//    // Pass-through tín hi?u
//    assign ram_addr  = wb_adr_i;
//    assign ram_wdata = wb_dat_i;
//    assign ram_be    = wb_sel_i;
//
//    // --- Logic ACK (Handshake) ---
//    always @(posedge clk_i) begin
//        if (rst_i) begin
//            wb_ack_o <= 0;
//        end else begin
//            if (ram_en) wb_ack_o <= 1;
//            else wb_ack_o <= 0;
//        end
//    end
//endmodule 

module ram_slave_interface /*wishbone_slave_adapter*/ (
    input clk_i,
    input rst,

    // --- Giao dien Wishbone ---
    input  [31:0] wb_addr_i,   // Dia chi tu Master
    input  [31:0] wb_data_i,   // Du lieu ghi tu Master
    output [31:0] wb_data_o,   // Du lieu doc tra ve Master
    input         wb_we_i,     // Write Enable: 1 = ghi, 0 = doc
    input         wb_stb_i,    // Strobe: bao hieu request hop le
    input         wb_cyc_i,    // Cycle: bao hieu giao dich dang dien ra
    input  [ 3:0] wb_sel_i,    // Byte select
    output        wb_ack_o,    // Acknowledge tra ve Master

    // --- Giao dien noi vao Memory / IP Core ---
    output [31:0] mem_addr_o,  // Dia chi gui vao RAM
    output [31:0] mem_wdata_o, // Du lieu ghi vao RAM
    input  [31:0] mem_rdata_i, // Du lieu doc tu RAM
    output        mem_we_o,    // Write Enable cho RAM
    output        mem_en_o,    // Chip Enable cho RAM
    output [ 3:0] mem_sel_o    // Byte select cho RAM
);

    // --- 1. Dinh nghia FSM ---
    localparam STATE_IDLE     = 2'b00; // Trang thai ranh
    localparam STATE_ACK      = 2'b01; // Phat ACK = 1 trong 1 chu ky
    localparam STATE_COOLDOWN = 2'b10; // ACK = 0, dam bao ket thuc giao dich

    reg [1:0] state, next_state;

    // --- 2. Thanh ghi trang thai ---
    always @(posedge clk_i) begin
        if (rst)
            state <= STATE_IDLE;
        else
            state <= next_state;
    end

    // --- 3. Logic chuyen trang thai ---
    always @(*) begin
        next_state = state;
        case (state)
            STATE_IDLE: begin
                // Neu thay request hop le (STB va CYC deu bang 1)
                // thi chap nhan giao dich
                if (wb_stb_i && wb_cyc_i) 
                    next_state = STATE_ACK;
            end

            STATE_ACK: begin
                // Gi? ACK trong 1 chu ky
                // Sau do chuyen sang trang thai ha ACK
                next_state = STATE_COOLDOWN;
            end

            STATE_COOLDOWN: begin
                // Tro ve IDLE de san sang nhan giao dich tiep theo
                next_state = STATE_IDLE;
            end
            
            default: next_state = STATE_IDLE;
        endcase
    end

    // --- 4. Logic xuat tin hieu phia Wishbone ---
    // ACK chi bat len trong trang thai STATE_ACK
    assign wb_ack_o = (state == STATE_ACK);

    // Du lieu doc tu RAM tra truc tiep ra Bus
    assign wb_data_o = mem_rdata_i;

    // --- 5. Logic ket noi phia Memory ---
    // Noi day dia chi, du lieu va byte enable
    assign mem_addr_o  = wb_addr_i;
    assign mem_wdata_o = wb_data_i;
    assign mem_sel_o   = wb_sel_i;

    // Tin hieu dieu khien RAM
    // Chip Enable: RAM duoc kich hoat khi co request hop le
    assign mem_en_o = wb_stb_i && wb_cyc_i; 
    
    // Write Enable: Chi ghi khi Master yeu cau ghi va chip dang duoc chon
    assign mem_we_o = wb_stb_i && wb_we_i;

endmodule