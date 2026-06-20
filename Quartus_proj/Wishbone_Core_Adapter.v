`timescale 1ns / 1ps

module Wishbone_Core_Adapter (
    input clk_i,
    input rst_i,

    // --- Giao dien phia Core ---
    input          core_req_i,
    input          core_we_i,
    input  [31:0]  core_addr_i,
    input  [31:0]  core_wdata_i,
    input  [ 3:0]  core_be_i,
    output         core_ready_o,
    output [31:0]  core_rdata_o,

    // --- Giao dien phia Wishbone ---
    input      [31:0] wb_data_i,
    input             wb_ack_i,
    
    output reg [31:0] wb_addr_o,
    output reg [31:0] wb_data_o,
    output reg        wb_we_o,
    output reg        wb_stb_o,
    output reg        wb_cyc_o,
    output reg [ 3:0] wb_sel_o 
);
    assign core_rdata_o = wb_data_i;
    assign core_ready_o = wb_ack_i; 

    // --- Dinh nghia trang thai FSM ---
    localparam IDLE        = 2'b00;
    localparam BUS_REQUEST = 2'b01;
    // DA XOA: localparam BUS_WAIT = 2'b10; -> Khong can thiet nua

    reg [1:0] state, next_state;
    reg is_write_op;

    // --- 1. Sequential Logic ---
    always @(posedge clk_i) begin
        if (rst_i) begin
            state       <= IDLE;
            is_write_op <= 1'b0;
        end else begin
            state <= next_state;
            if (state == IDLE && core_req_i) begin
                is_write_op <= core_we_i;
            end
        end
    end

    // --- 2. Next State Logic (Combinational) ---
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (core_req_i) 
                    next_state = BUS_REQUEST;
            end

            BUS_REQUEST: begin
                // Ngay khi thay ACK, nghia la giao dich hoan tat.
                // Quay ve IDLE luon de tat STB, khong can cho ACK ha xuong.
                // Core se tu dong latched du lieu tai canh len clock nay.
                if (wb_ack_i) 
                    next_state = IDLE; 
            end

            default: next_state = IDLE;
        endcase
    end

    // --- 3. Output Logic ---
    always @(*) begin
        wb_stb_o = 1'b0;
        wb_cyc_o = 1'b0;
        wb_we_o  = 1'b0;

        case (state)
            BUS_REQUEST: begin
                wb_stb_o = 1'b1;
                wb_cyc_o = 1'b1;
                wb_we_o  = is_write_op;
            end
            // IDLE: mac dinh la 0
        endcase
    end

    // --- 4. Datapath Logic ---
    always @(posedge clk_i) begin
        if (rst_i) begin
            wb_addr_o <= 32'd0;
            wb_data_o <= 32'd0;
            wb_sel_o  <= 4'b0000;
        end else begin
            if (state == IDLE && core_req_i) begin
                wb_addr_o <= core_addr_i;
                wb_data_o <= core_wdata_i;
                wb_sel_o  <= core_be_i;
            end
        end
    end

endmodule