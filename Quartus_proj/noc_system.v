`default_nettype none
`timescale 1ns / 1ps

module noc_system (
    input wire clk,
    input wire rst,
    output wire [8:0] error_leds,
	 output wire [31:0] fpga_led_matrix_out, 
    output wire [31:0] fpga_timer_debug,
	 inout  wire [31:0] fpga_gpio_pins, // [MỚI] Chân GPIO 32-bit
    output wire        uart_tx,        // [MỚI] Chân TX UART
    input  wire        uart_rx         // [MỚI] Chân RX UART
);

    // =========================================================================
    // 1. INCLUDE & PARAMETERS
    // =========================================================================
 `include "C:/Users/ASUS/Desktop/code_da1_comp/code_da1_comp/src_router/c_functions.v"
`include "C:/Users/ASUS/Desktop/code_da1_comp/code_da1_comp/src_router/c_constants.v"
`include "C:/Users/ASUS/Desktop/code_da1_comp/code_da1_comp/src_router/rtr_constants.v"
`include "C:/Users/ASUS/Desktop/code_da1_comp/code_da1_comp/src_router/vcr_constants.v"
`include "C:/Users/ASUS/Desktop/code_da1_comp/code_da1_comp/src_router/parameters.v"
    
    // --- Calculated Parameters ---
    localparam resource_class_idx_width = clogb(num_resource_classes);
    localparam num_packet_classes = num_message_classes * num_resource_classes;
    localparam num_vcs = num_packet_classes * num_vcs_per_class;
    localparam vc_idx_width = clogb(num_vcs);
    
    // Router Config
    localparam num_routers = (num_nodes + num_nodes_per_router - 1) / num_nodes_per_router;
    localparam num_routers_per_dim = croot(num_routers, num_dimensions);
    localparam dim_addr_width = clogb(num_routers_per_dim);
    localparam router_addr_width = num_dimensions * dim_addr_width;
    
    // Topology & Ports
    localparam connectivity = `CONNECTIVITY_LINE; 
    localparam num_neighbors_per_dim = 2;
    localparam num_ports = num_dimensions * num_neighbors_per_dim + num_nodes_per_router; 
    localparam port_idx_width = clogb(num_ports);
    localparam node_addr_width = clogb(num_nodes_per_router);
    localparam lar_info_width = port_idx_width + resource_class_idx_width;
    
    localparam dest_info_width = (routing_type == `ROUTING_TYPE_PHASED_DOR) ? 
        (num_resource_classes * router_addr_width + node_addr_width) : -1;
    
    localparam route_info_width = lar_info_width + dest_info_width;
    
    // Signal Widths
    localparam flow_ctrl_width = (flow_ctrl_type == `FLOW_CTRL_TYPE_CREDIT) ? (1 + vc_idx_width) : -1;
    localparam link_ctrl_width = enable_link_pm ? 1 : 0;
    
    // Channel Width Calculation
    localparam flit_ctrl_width_fixed = (1 + vc_idx_width + 1 + 1); 
    localparam channel_width = link_ctrl_width + flit_ctrl_width_fixed + flit_data_width;
    
    // Misc
    localparam atomic_vc_allocation = (elig_mask == `ELIG_MASK_USED);
    localparam channel_latency = 1;
    localparam num_channel_stages = channel_latency - 1;

    // =========================================================================
    // 2. INTERCONNECT WIRES
    // =========================================================================
    
    // Wires for Routers 0-8 (Input/Output/FlowCtrl)
    wire [0:channel_width-1]   channel_router_0_op_0, channel_router_0_op_1, channel_router_0_op_2, channel_router_0_op_3, channel_router_0_op_4;
    wire [0:channel_width-1]   channel_router_0_ip_0, channel_router_0_ip_1, channel_router_0_ip_2, channel_router_0_ip_3, channel_router_0_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_0_ip_0, flow_ctrl_router_0_ip_1, flow_ctrl_router_0_ip_2, flow_ctrl_router_0_ip_3, flow_ctrl_router_0_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_0_op_0, flow_ctrl_router_0_op_1, flow_ctrl_router_0_op_2, flow_ctrl_router_0_op_3, flow_ctrl_router_0_op_4;

    wire [0:channel_width-1]   channel_router_1_op_0, channel_router_1_op_1, channel_router_1_op_2, channel_router_1_op_3, channel_router_1_op_4;
    wire [0:channel_width-1]   channel_router_1_ip_0, channel_router_1_ip_1, channel_router_1_ip_2, channel_router_1_ip_3, channel_router_1_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_1_ip_0, flow_ctrl_router_1_ip_1, flow_ctrl_router_1_ip_2, flow_ctrl_router_1_ip_3, flow_ctrl_router_1_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_1_op_0, flow_ctrl_router_1_op_1, flow_ctrl_router_1_op_2, flow_ctrl_router_1_op_3, flow_ctrl_router_1_op_4;

    wire [0:channel_width-1]   channel_router_2_op_0, channel_router_2_op_1, channel_router_2_op_2, channel_router_2_op_3, channel_router_2_op_4;
    wire [0:channel_width-1]   channel_router_2_ip_0, channel_router_2_ip_1, channel_router_2_ip_2, channel_router_2_ip_3, channel_router_2_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_2_ip_0, flow_ctrl_router_2_ip_1, flow_ctrl_router_2_ip_2, flow_ctrl_router_2_ip_3, flow_ctrl_router_2_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_2_op_0, flow_ctrl_router_2_op_1, flow_ctrl_router_2_op_2, flow_ctrl_router_2_op_3, flow_ctrl_router_2_op_4;

    wire [0:channel_width-1]   channel_router_3_op_0, channel_router_3_op_1, channel_router_3_op_2, channel_router_3_op_3, channel_router_3_op_4;
    wire [0:channel_width-1]   channel_router_3_ip_0, channel_router_3_ip_1, channel_router_3_ip_2, channel_router_3_ip_3, channel_router_3_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_3_ip_0, flow_ctrl_router_3_ip_1, flow_ctrl_router_3_ip_2, flow_ctrl_router_3_ip_3, flow_ctrl_router_3_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_3_op_0, flow_ctrl_router_3_op_1, flow_ctrl_router_3_op_2, flow_ctrl_router_3_op_3, flow_ctrl_router_3_op_4;

    wire [0:channel_width-1]   channel_router_4_op_0, channel_router_4_op_1, channel_router_4_op_2, channel_router_4_op_3, channel_router_4_op_4;
    wire [0:channel_width-1]   channel_router_4_ip_0, channel_router_4_ip_1, channel_router_4_ip_2, channel_router_4_ip_3, channel_router_4_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_4_ip_0, flow_ctrl_router_4_ip_1, flow_ctrl_router_4_ip_2, flow_ctrl_router_4_ip_3, flow_ctrl_router_4_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_4_op_0, flow_ctrl_router_4_op_1, flow_ctrl_router_4_op_2, flow_ctrl_router_4_op_3, flow_ctrl_router_4_op_4;

    wire [0:channel_width-1]   channel_router_5_op_0, channel_router_5_op_1, channel_router_5_op_2, channel_router_5_op_3, channel_router_5_op_4;
    wire [0:channel_width-1]   channel_router_5_ip_0, channel_router_5_ip_1, channel_router_5_ip_2, channel_router_5_ip_3, channel_router_5_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_5_ip_0, flow_ctrl_router_5_ip_1, flow_ctrl_router_5_ip_2, flow_ctrl_router_5_ip_3, flow_ctrl_router_5_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_5_op_0, flow_ctrl_router_5_op_1, flow_ctrl_router_5_op_2, flow_ctrl_router_5_op_3, flow_ctrl_router_5_op_4;

    wire [0:channel_width-1]   channel_router_6_op_0, channel_router_6_op_1, channel_router_6_op_2, channel_router_6_op_3, channel_router_6_op_4;
    wire [0:channel_width-1]   channel_router_6_ip_0, channel_router_6_ip_1, channel_router_6_ip_2, channel_router_6_ip_3, channel_router_6_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_6_ip_0, flow_ctrl_router_6_ip_1, flow_ctrl_router_6_ip_2, flow_ctrl_router_6_ip_3, flow_ctrl_router_6_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_6_op_0, flow_ctrl_router_6_op_1, flow_ctrl_router_6_op_2, flow_ctrl_router_6_op_3, flow_ctrl_router_6_op_4;

    wire [0:channel_width-1]   channel_router_7_op_0, channel_router_7_op_1, channel_router_7_op_2, channel_router_7_op_3, channel_router_7_op_4;
    wire [0:channel_width-1]   channel_router_7_ip_0, channel_router_7_ip_1, channel_router_7_ip_2, channel_router_7_ip_3, channel_router_7_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_7_ip_0, flow_ctrl_router_7_ip_1, flow_ctrl_router_7_ip_2, flow_ctrl_router_7_ip_3, flow_ctrl_router_7_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_7_op_0, flow_ctrl_router_7_op_1, flow_ctrl_router_7_op_2, flow_ctrl_router_7_op_3, flow_ctrl_router_7_op_4;

    wire [0:channel_width-1]   channel_router_8_op_0, channel_router_8_op_1, channel_router_8_op_2, channel_router_8_op_3, channel_router_8_op_4;
    wire [0:channel_width-1]   channel_router_8_ip_0, channel_router_8_ip_1, channel_router_8_ip_2, channel_router_8_ip_3, channel_router_8_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_8_ip_0, flow_ctrl_router_8_ip_1, flow_ctrl_router_8_ip_2, flow_ctrl_router_8_ip_3, flow_ctrl_router_8_ip_4;
    wire [0:flow_ctrl_width-1] flow_ctrl_router_8_op_0, flow_ctrl_router_8_op_1, flow_ctrl_router_8_op_2, flow_ctrl_router_8_op_3, flow_ctrl_router_8_op_4;

    // Error Signals
    wire [0:num_routers-1] rtr_error;

    // Injection/Ejection Arrays
    wire [0:(num_routers*channel_width)-1]   injection_channels;
    wire [0:(num_routers*flow_ctrl_width)-1] injection_flow_ctrl;
    wire [0:(num_routers*channel_width)-1]   ejection_channels;
    wire [0:(num_routers*flow_ctrl_width)-1] ejection_flow_ctrl;
    

    // ==========================================================================
    // 3. MESH TOPOLOGY CONNECTION (3x3 Fixed - STANFORD STANDARD)
    // ==========================================================================
    // PORT 0: WEST (TRÁI)
    // PORT 1: EAST (PHẢI)
    // PORT 2: SOUTH (XUỐNG)
    // PORT 3: NORTH (LÊN)
    // ==========================================================================
    
    // --- ROUTER 0 (0,0) [Góc Dưới Trái] ---
    // North (Port 3) -> Connect to Router 3 (0,1) South (Port 2)
    // East (Port 1) -> Connect to Router 1 (1,0) West (Port 0)
    assign channel_router_0_ip_0 = {channel_width{1'b0}};           // West: Null
    assign channel_router_0_ip_1 = channel_router_1_op_0;           // East: Nhận từ R1 (Port 0-West)
    assign channel_router_0_ip_2 = {channel_width{1'b0}};           // South: Null
    assign channel_router_0_ip_3 = channel_router_3_op_2;           // North: Nhận từ R3 (Port 2-South)
    assign channel_router_0_ip_4 = injection_channels[0*channel_width +: channel_width];

    assign flow_ctrl_router_0_op_0 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_0_op_1 = flow_ctrl_router_1_ip_0;
    assign flow_ctrl_router_0_op_2 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_0_op_3 = flow_ctrl_router_3_ip_2;
    assign flow_ctrl_router_0_op_4 = ejection_flow_ctrl[0*flow_ctrl_width +: flow_ctrl_width];

    // --- ROUTER 1 (1,0) [Dưới Giữa] ---
    // West (Port 0) -> R0 Port 1 | East (Port 1) -> R2 Port 0 | North (Port 3) -> R4 Port 2
    assign channel_router_1_ip_0 = channel_router_0_op_1;           // West: Nhận từ R0 (Port 1-East)
    assign channel_router_1_ip_1 = channel_router_2_op_0;           // East: Nhận từ R2 (Port 0-West)
    assign channel_router_1_ip_2 = {channel_width{1'b0}};           // South: Null
    assign channel_router_1_ip_3 = channel_router_4_op_2;           // North: Nhận từ R4 (Port 2-South)
    assign channel_router_1_ip_4 = injection_channels[1*channel_width +: channel_width];

    assign flow_ctrl_router_1_op_0 = flow_ctrl_router_0_ip_1;
    assign flow_ctrl_router_1_op_1 = flow_ctrl_router_2_ip_0;
    assign flow_ctrl_router_1_op_2 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_1_op_3 = flow_ctrl_router_4_ip_2;
    assign flow_ctrl_router_1_op_4 = ejection_flow_ctrl[1*flow_ctrl_width +: flow_ctrl_width];

    // --- ROUTER 2 (2,0) [Góc Dưới Phải] ---
    // West (Port 0) -> R1 Port 1 | North (Port 3) -> R5 Port 2
    assign channel_router_2_ip_0 = channel_router_1_op_1;           // West: Nhận từ R1 (Port 1-East)
    assign channel_router_2_ip_1 = {channel_width{1'b0}};           // East: Null
    assign channel_router_2_ip_2 = {channel_width{1'b0}};           // South: Null
    assign channel_router_2_ip_3 = channel_router_5_op_2;           // North: Nhận từ R5 (Port 2-South)
    assign channel_router_2_ip_4 = injection_channels[2*channel_width +: channel_width];

    assign flow_ctrl_router_2_op_0 = flow_ctrl_router_1_ip_1;
    assign flow_ctrl_router_2_op_1 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_2_op_2 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_2_op_3 = flow_ctrl_router_5_ip_2;
    assign flow_ctrl_router_2_op_4 = ejection_flow_ctrl[2*flow_ctrl_width +: flow_ctrl_width];

    // --- ROUTER 3 (0,1) [Giữa Trái] ---
    // East (Port 1) -> R4 Port 0 | South (Port 2) -> R0 Port 3 | North (Port 3) -> R6 Port 2
    assign channel_router_3_ip_0 = {channel_width{1'b0}};           // West: Null
    assign channel_router_3_ip_1 = channel_router_4_op_0;           // East: Nhận từ R4 (Port 0-West)
    assign channel_router_3_ip_2 = channel_router_0_op_3;           // South: Nhận từ R0 (Port 3-North)
    assign channel_router_3_ip_3 = channel_router_6_op_2;           // North: Nhận từ R6 (Port 2-South)
    assign channel_router_3_ip_4 = injection_channels[3*channel_width +: channel_width];

    assign flow_ctrl_router_3_op_0 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_3_op_1 = flow_ctrl_router_4_ip_0;
    assign flow_ctrl_router_3_op_2 = flow_ctrl_router_0_ip_3;
    assign flow_ctrl_router_3_op_3 = flow_ctrl_router_6_ip_2;
    assign flow_ctrl_router_3_op_4 = ejection_flow_ctrl[3*flow_ctrl_width +: flow_ctrl_width];

    // --- ROUTER 4 (1,1) [Trung Tâm] ---
    // West (Port 0) -> R3 Port 1 | East (Port 1) -> R5 Port 0
    // South (Port 2) -> R1 Port 3 | North (Port 3) -> R7 Port 2
    assign channel_router_4_ip_0 = channel_router_3_op_1;           // West: Nhận từ R3 (Port 1-East)
    assign channel_router_4_ip_1 = channel_router_5_op_0;           // East: Nhận từ R5 (Port 0-West)
    assign channel_router_4_ip_2 = channel_router_1_op_3;           // South: Nhận từ R1 (Port 3-North)
    assign channel_router_4_ip_3 = channel_router_7_op_2;           // North: Nhận từ R7 (Port 2-South)
    assign channel_router_4_ip_4 = injection_channels[4*channel_width +: channel_width];

    assign flow_ctrl_router_4_op_0 = flow_ctrl_router_3_ip_1;
    assign flow_ctrl_router_4_op_1 = flow_ctrl_router_5_ip_0;
    assign flow_ctrl_router_4_op_2 = flow_ctrl_router_1_ip_3;
    assign flow_ctrl_router_4_op_3 = flow_ctrl_router_7_ip_2;
    assign flow_ctrl_router_4_op_4 = ejection_flow_ctrl[4*flow_ctrl_width +: flow_ctrl_width];

    // --- ROUTER 5 (2,1) [Giữa Phải] ---
    // West (Port 0) -> R4 Port 1 | South (Port 2) -> R2 Port 3 | North (Port 3) -> R8 Port 2
    assign channel_router_5_ip_0 = channel_router_4_op_1;           // West: Nhận từ R4 (Port 1-East)
    assign channel_router_5_ip_1 = {channel_width{1'b0}};           // East: Null
    assign channel_router_5_ip_2 = channel_router_2_op_3;           // South: Nhận từ R2 (Port 3-North)
    assign channel_router_5_ip_3 = channel_router_8_op_2;           // North: Nhận từ R8 (Port 2-South)
    assign channel_router_5_ip_4 = injection_channels[5*channel_width +: channel_width];

    assign flow_ctrl_router_5_op_0 = flow_ctrl_router_4_ip_1;
    assign flow_ctrl_router_5_op_1 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_5_op_2 = flow_ctrl_router_2_ip_3;
    assign flow_ctrl_router_5_op_3 = flow_ctrl_router_8_ip_2;
    assign flow_ctrl_router_5_op_4 = ejection_flow_ctrl[5*flow_ctrl_width +: flow_ctrl_width];

    // --- ROUTER 6 (0,2) [Góc Trên Trái] ---
    // East (Port 1) -> R7 Port 0 | South (Port 2) -> R3 Port 3
    assign channel_router_6_ip_0 = {channel_width{1'b0}};           // West: Null
    assign channel_router_6_ip_1 = channel_router_7_op_0;           // East: Nhận từ R7 (Port 0-West)
    assign channel_router_6_ip_2 = channel_router_3_op_3;           // South: Nhận từ R3 (Port 3-North)
    assign channel_router_6_ip_3 = {channel_width{1'b0}};           // North: Null
    assign channel_router_6_ip_4 = injection_channels[6*channel_width +: channel_width];

    assign flow_ctrl_router_6_op_0 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_6_op_1 = flow_ctrl_router_7_ip_0;
    assign flow_ctrl_router_6_op_2 = flow_ctrl_router_3_ip_3;
    assign flow_ctrl_router_6_op_3 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_6_op_4 = ejection_flow_ctrl[6*flow_ctrl_width +: flow_ctrl_width];

    // --- ROUTER 7 (1,2) [Trên Giữa] ---
    // West (Port 0) -> R6 Port 1 | East (Port 1) -> R8 Port 0 | South (Port 2) -> R4 Port 3
    assign channel_router_7_ip_0 = channel_router_6_op_1;           // West: Nhận từ R6 (Port 1-East)
    assign channel_router_7_ip_1 = channel_router_8_op_0;           // East: Nhận từ R8 (Port 0-West)
    assign channel_router_7_ip_2 = channel_router_4_op_3;           // South: Nhận từ R4 (Port 3-North)
    assign channel_router_7_ip_3 = {channel_width{1'b0}};           // North: Null
    assign channel_router_7_ip_4 = injection_channels[7*channel_width +: channel_width];

    assign flow_ctrl_router_7_op_0 = flow_ctrl_router_6_ip_1;
    assign flow_ctrl_router_7_op_1 = flow_ctrl_router_8_ip_0;
    assign flow_ctrl_router_7_op_2 = flow_ctrl_router_4_ip_3;
    assign flow_ctrl_router_7_op_3 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_7_op_4 = ejection_flow_ctrl[7*flow_ctrl_width +: flow_ctrl_width];

    // --- ROUTER 8 (2,2) [Góc Trên Phải] ---
    // West (Port 0) -> R7 Port 1 | South (Port 2) -> R5 Port 3
    assign channel_router_8_ip_0 = channel_router_7_op_1;           // West: Nhận từ R7 (Port 1-East)
    assign channel_router_8_ip_1 = {channel_width{1'b0}};           // East: Null
    assign channel_router_8_ip_2 = channel_router_5_op_3;           // South: Nhận từ R5 (Port 3-North)
    assign channel_router_8_ip_3 = {channel_width{1'b0}};           // North: Null
    assign channel_router_8_ip_4 = injection_channels[8*channel_width +: channel_width];

    assign flow_ctrl_router_8_op_0 = flow_ctrl_router_7_ip_1;
    assign flow_ctrl_router_8_op_1 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_8_op_2 = flow_ctrl_router_5_ip_3;
    assign flow_ctrl_router_8_op_3 = {flow_ctrl_width{1'b0}};
    assign flow_ctrl_router_8_op_4 = ejection_flow_ctrl[8*flow_ctrl_width +: flow_ctrl_width];
    
    // Connect Local Ports to Arrays
    assign ejection_channels[0*channel_width:(1*channel_width)-1]   = channel_router_0_op_4;
    assign injection_flow_ctrl[0*flow_ctrl_width:(1*flow_ctrl_width)-1] = flow_ctrl_router_0_ip_4;
    assign ejection_channels[1*channel_width:(2*channel_width)-1]   = channel_router_1_op_4;
    assign injection_flow_ctrl[1*flow_ctrl_width:(2*flow_ctrl_width)-1] = flow_ctrl_router_1_ip_4;
    assign ejection_channels[2*channel_width:(3*channel_width)-1]   = channel_router_2_op_4;
    assign injection_flow_ctrl[2*flow_ctrl_width:(3*flow_ctrl_width)-1] = flow_ctrl_router_2_ip_4;
    assign ejection_channels[3*channel_width:(4*channel_width)-1]   = channel_router_3_op_4;
    assign injection_flow_ctrl[3*flow_ctrl_width:(4*flow_ctrl_width)-1] = flow_ctrl_router_3_ip_4;
    assign ejection_channels[4*channel_width:(5*channel_width)-1]   = channel_router_4_op_4;
    assign injection_flow_ctrl[4*flow_ctrl_width:(5*flow_ctrl_width)-1] = flow_ctrl_router_4_ip_4;
    assign ejection_channels[5*channel_width:(6*channel_width)-1]   = channel_router_5_op_4;
    assign injection_flow_ctrl[5*flow_ctrl_width:(6*flow_ctrl_width)-1] = flow_ctrl_router_5_ip_4;
    assign ejection_channels[6*channel_width:(7*channel_width)-1]   = channel_router_6_op_4;
    assign injection_flow_ctrl[6*flow_ctrl_width:(7*flow_ctrl_width)-1] = flow_ctrl_router_6_ip_4;
    assign ejection_channels[7*channel_width:(8*channel_width)-1]   = channel_router_7_op_4;
    assign injection_flow_ctrl[7*flow_ctrl_width:(8*flow_ctrl_width)-1] = flow_ctrl_router_7_ip_4;
    assign ejection_channels[8*channel_width:(9*channel_width)-1]   = channel_router_8_op_4;
    assign injection_flow_ctrl[8*flow_ctrl_width:(9*flow_ctrl_width)-1] = flow_ctrl_router_8_ip_4;

    // ==========================================================================
    // INSTANTIATION ROUTERS
    // ==========================================================================
    router_wrap #( .packet_format(0), .topology(topology), .buffer_size(buffer_size), .num_message_classes(num_message_classes), .num_resource_classes(num_resource_classes), .num_vcs_per_class(num_vcs_per_class), .num_nodes(num_nodes), .num_dimensions(num_dimensions), .num_nodes_per_router(num_nodes_per_router), .flow_ctrl_type(flow_ctrl_type), .flow_ctrl_bypass(flow_ctrl_bypass), .max_payload_length(max_payload_length), .min_payload_length(min_payload_length), .router_type(router_type), .enable_link_pm(enable_link_pm), .flit_data_width(flit_data_width), .error_capture_mode(error_capture_mode), .restrict_turns(restrict_turns), .predecode_lar_info(predecode_lar_info), .routing_type(routing_type), .dim_order(dim_order), .input_stage_can_hold(input_stage_can_hold), .fb_regfile_type(fb_regfile_type), .fb_mgmt_type(fb_mgmt_type), .explicit_pipeline_register(explicit_pipeline_register), .dual_path_alloc(dual_path_alloc), .dual_path_allow_conflicts(dual_path_allow_conflicts), .dual_path_mask_on_ready(dual_path_mask_on_ready), .precomp_ivc_sel(precomp_ivc_sel), .precomp_ip_sel(precomp_ip_sel), .elig_mask(elig_mask), .vc_alloc_type(vc_alloc_type), .vc_alloc_arbiter_type(vc_alloc_arbiter_type), .vc_alloc_prefer_empty(vc_alloc_prefer_empty), .sw_alloc_type(sw_alloc_type), .sw_alloc_arbiter_type(sw_alloc_arbiter_type), .sw_alloc_spec_type(sw_alloc_spec_type), .crossbar_type(crossbar_type), .reset_type(reset_type) )
    rtr_0 (.clk(clk), .reset(rst), .router_address(4'b0000), .channel_in_ip({channel_router_0_ip_0, channel_router_0_ip_1, channel_router_0_ip_2, channel_router_0_ip_3, channel_router_0_ip_4}), .flow_ctrl_out_ip({ flow_ctrl_router_0_ip_0, flow_ctrl_router_0_ip_1, flow_ctrl_router_0_ip_2, flow_ctrl_router_0_ip_3, flow_ctrl_router_0_ip_4 }), .channel_out_op({ channel_router_0_op_0, channel_router_0_op_1, channel_router_0_op_2, channel_router_0_op_3, channel_router_0_op_4 }), .flow_ctrl_in_op({ flow_ctrl_router_0_op_0, flow_ctrl_router_0_op_1, flow_ctrl_router_0_op_2, flow_ctrl_router_0_op_3, flow_ctrl_router_0_op_4 }), .error(rtr_error[0]));

    router_wrap #( .packet_format(0), .topology(topology), .buffer_size(buffer_size), .num_message_classes(num_message_classes), .num_resource_classes(num_resource_classes), .num_vcs_per_class(num_vcs_per_class), .num_nodes(num_nodes), .num_dimensions(num_dimensions), .num_nodes_per_router(num_nodes_per_router), .flow_ctrl_type(flow_ctrl_type), .flow_ctrl_bypass(flow_ctrl_bypass), .max_payload_length(max_payload_length), .min_payload_length(min_payload_length), .router_type(router_type), .enable_link_pm(enable_link_pm), .flit_data_width(flit_data_width), .error_capture_mode(error_capture_mode), .restrict_turns(restrict_turns), .predecode_lar_info(predecode_lar_info), .routing_type(routing_type), .dim_order(dim_order), .input_stage_can_hold(input_stage_can_hold), .fb_regfile_type(fb_regfile_type), .fb_mgmt_type(fb_mgmt_type), .explicit_pipeline_register(explicit_pipeline_register), .dual_path_alloc(dual_path_alloc), .dual_path_allow_conflicts(dual_path_allow_conflicts), .dual_path_mask_on_ready(dual_path_mask_on_ready), .precomp_ivc_sel(precomp_ivc_sel), .precomp_ip_sel(precomp_ip_sel), .elig_mask(elig_mask), .vc_alloc_type(vc_alloc_type), .vc_alloc_arbiter_type(vc_alloc_arbiter_type), .vc_alloc_prefer_empty(vc_alloc_prefer_empty), .sw_alloc_type(sw_alloc_type), .sw_alloc_arbiter_type(sw_alloc_arbiter_type), .sw_alloc_spec_type(sw_alloc_spec_type), .crossbar_type(crossbar_type), .reset_type(reset_type) )
    rtr_1 (.clk(clk), .reset(rst), .router_address(4'b0100), .channel_in_ip({channel_router_1_ip_0, channel_router_1_ip_1, channel_router_1_ip_2, channel_router_1_ip_3, channel_router_1_ip_4}), .flow_ctrl_out_ip({ flow_ctrl_router_1_ip_0, flow_ctrl_router_1_ip_1, flow_ctrl_router_1_ip_2, flow_ctrl_router_1_ip_3, flow_ctrl_router_1_ip_4 }), .channel_out_op({ channel_router_1_op_0, channel_router_1_op_1, channel_router_1_op_2, channel_router_1_op_3, channel_router_1_op_4 }), .flow_ctrl_in_op({ flow_ctrl_router_1_op_0, flow_ctrl_router_1_op_1, flow_ctrl_router_1_op_2, flow_ctrl_router_1_op_3, flow_ctrl_router_1_op_4 }), .error(rtr_error[1]));

    router_wrap #( .packet_format(0), .topology(topology), .buffer_size(buffer_size), .num_message_classes(num_message_classes), .num_resource_classes(num_resource_classes), .num_vcs_per_class(num_vcs_per_class), .num_nodes(num_nodes), .num_dimensions(num_dimensions), .num_nodes_per_router(num_nodes_per_router), .flow_ctrl_type(flow_ctrl_type), .flow_ctrl_bypass(flow_ctrl_bypass), .max_payload_length(max_payload_length), .min_payload_length(min_payload_length), .router_type(router_type), .enable_link_pm(enable_link_pm), .flit_data_width(flit_data_width), .error_capture_mode(error_capture_mode), .restrict_turns(restrict_turns), .predecode_lar_info(predecode_lar_info), .routing_type(routing_type), .dim_order(dim_order), .input_stage_can_hold(input_stage_can_hold), .fb_regfile_type(fb_regfile_type), .fb_mgmt_type(fb_mgmt_type), .explicit_pipeline_register(explicit_pipeline_register), .dual_path_alloc(dual_path_alloc), .dual_path_allow_conflicts(dual_path_allow_conflicts), .dual_path_mask_on_ready(dual_path_mask_on_ready), .precomp_ivc_sel(precomp_ivc_sel), .precomp_ip_sel(precomp_ip_sel), .elig_mask(elig_mask), .vc_alloc_type(vc_alloc_type), .vc_alloc_arbiter_type(vc_alloc_arbiter_type), .vc_alloc_prefer_empty(vc_alloc_prefer_empty), .sw_alloc_type(sw_alloc_type), .sw_alloc_arbiter_type(sw_alloc_arbiter_type), .sw_alloc_spec_type(sw_alloc_spec_type), .crossbar_type(crossbar_type), .reset_type(reset_type) )
    rtr_2 (.clk(clk), .reset(rst), .router_address(4'b1000), .channel_in_ip({channel_router_2_ip_0, channel_router_2_ip_1, channel_router_2_ip_2, channel_router_2_ip_3, channel_router_2_ip_4}), .flow_ctrl_out_ip({ flow_ctrl_router_2_ip_0, flow_ctrl_router_2_ip_1, flow_ctrl_router_2_ip_2, flow_ctrl_router_2_ip_3, flow_ctrl_router_2_ip_4 }), .channel_out_op({ channel_router_2_op_0, channel_router_2_op_1, channel_router_2_op_2, channel_router_2_op_3, channel_router_2_op_4 }), .flow_ctrl_in_op({ flow_ctrl_router_2_op_0, flow_ctrl_router_2_op_1, flow_ctrl_router_2_op_2, flow_ctrl_router_2_op_3, flow_ctrl_router_2_op_4 }), .error(rtr_error[2]));

    router_wrap #( .packet_format(0), .topology(topology), .buffer_size(buffer_size), .num_message_classes(num_message_classes), .num_resource_classes(num_resource_classes), .num_vcs_per_class(num_vcs_per_class), .num_nodes(num_nodes), .num_dimensions(num_dimensions), .num_nodes_per_router(num_nodes_per_router), .flow_ctrl_type(flow_ctrl_type), .flow_ctrl_bypass(flow_ctrl_bypass), .max_payload_length(max_payload_length), .min_payload_length(min_payload_length), .router_type(router_type), .enable_link_pm(enable_link_pm), .flit_data_width(flit_data_width), .error_capture_mode(error_capture_mode), .restrict_turns(restrict_turns), .predecode_lar_info(predecode_lar_info), .routing_type(routing_type), .dim_order(dim_order), .input_stage_can_hold(input_stage_can_hold), .fb_regfile_type(fb_regfile_type), .fb_mgmt_type(fb_mgmt_type), .explicit_pipeline_register(explicit_pipeline_register), .dual_path_alloc(dual_path_alloc), .dual_path_allow_conflicts(dual_path_allow_conflicts), .dual_path_mask_on_ready(dual_path_mask_on_ready), .precomp_ivc_sel(precomp_ivc_sel), .precomp_ip_sel(precomp_ip_sel), .elig_mask(elig_mask), .vc_alloc_type(vc_alloc_type), .vc_alloc_arbiter_type(vc_alloc_arbiter_type), .vc_alloc_prefer_empty(vc_alloc_prefer_empty), .sw_alloc_type(sw_alloc_type), .sw_alloc_arbiter_type(sw_alloc_arbiter_type), .sw_alloc_spec_type(sw_alloc_spec_type), .crossbar_type(crossbar_type), .reset_type(reset_type) )
    rtr_3 (.clk(clk), .reset(rst), .router_address(4'b0001), .channel_in_ip({channel_router_3_ip_0, channel_router_3_ip_1, channel_router_3_ip_2, channel_router_3_ip_3, channel_router_3_ip_4}), .flow_ctrl_out_ip({ flow_ctrl_router_3_ip_0, flow_ctrl_router_3_ip_1, flow_ctrl_router_3_ip_2, flow_ctrl_router_3_ip_3, flow_ctrl_router_3_ip_4 }), .channel_out_op({ channel_router_3_op_0, channel_router_3_op_1, channel_router_3_op_2, channel_router_3_op_3, channel_router_3_op_4 }), .flow_ctrl_in_op({ flow_ctrl_router_3_op_0, flow_ctrl_router_3_op_1, flow_ctrl_router_3_op_2, flow_ctrl_router_3_op_3, flow_ctrl_router_3_op_4 }), .error(rtr_error[3]));

    router_wrap #( .packet_format(0), .topology(topology), .buffer_size(buffer_size), .num_message_classes(num_message_classes), .num_resource_classes(num_resource_classes), .num_vcs_per_class(num_vcs_per_class), .num_nodes(num_nodes), .num_dimensions(num_dimensions), .num_nodes_per_router(num_nodes_per_router), .flow_ctrl_type(flow_ctrl_type), .flow_ctrl_bypass(flow_ctrl_bypass), .max_payload_length(max_payload_length), .min_payload_length(min_payload_length), .router_type(router_type), .enable_link_pm(enable_link_pm), .flit_data_width(flit_data_width), .error_capture_mode(error_capture_mode), .restrict_turns(restrict_turns), .predecode_lar_info(predecode_lar_info), .routing_type(routing_type), .dim_order(dim_order), .input_stage_can_hold(input_stage_can_hold), .fb_regfile_type(fb_regfile_type), .fb_mgmt_type(fb_mgmt_type), .explicit_pipeline_register(explicit_pipeline_register), .dual_path_alloc(dual_path_alloc), .dual_path_allow_conflicts(dual_path_allow_conflicts), .dual_path_mask_on_ready(dual_path_mask_on_ready), .precomp_ivc_sel(precomp_ivc_sel), .precomp_ip_sel(precomp_ip_sel), .elig_mask(elig_mask), .vc_alloc_type(vc_alloc_type), .vc_alloc_arbiter_type(vc_alloc_arbiter_type), .vc_alloc_prefer_empty(vc_alloc_prefer_empty), .sw_alloc_type(sw_alloc_type), .sw_alloc_arbiter_type(sw_alloc_arbiter_type), .sw_alloc_spec_type(sw_alloc_spec_type), .crossbar_type(crossbar_type), .reset_type(reset_type) )
    rtr_4 (.clk(clk), .reset(rst), .router_address(4'b0101), .channel_in_ip({channel_router_4_ip_0, channel_router_4_ip_1, channel_router_4_ip_2, channel_router_4_ip_3, channel_router_4_ip_4}), .flow_ctrl_out_ip({ flow_ctrl_router_4_ip_0, flow_ctrl_router_4_ip_1, flow_ctrl_router_4_ip_2, flow_ctrl_router_4_ip_3, flow_ctrl_router_4_ip_4 }), .channel_out_op({ channel_router_4_op_0, channel_router_4_op_1, channel_router_4_op_2, channel_router_4_op_3, channel_router_4_op_4 }), .flow_ctrl_in_op({ flow_ctrl_router_4_op_0, flow_ctrl_router_4_op_1, flow_ctrl_router_4_op_2, flow_ctrl_router_4_op_3, flow_ctrl_router_4_op_4 }), .error(rtr_error[4]));

    router_wrap #( .packet_format(0), .topology(topology), .buffer_size(buffer_size), .num_message_classes(num_message_classes), .num_resource_classes(num_resource_classes), .num_vcs_per_class(num_vcs_per_class), .num_nodes(num_nodes), .num_dimensions(num_dimensions), .num_nodes_per_router(num_nodes_per_router), .flow_ctrl_type(flow_ctrl_type), .flow_ctrl_bypass(flow_ctrl_bypass), .max_payload_length(max_payload_length), .min_payload_length(min_payload_length), .router_type(router_type), .enable_link_pm(enable_link_pm), .flit_data_width(flit_data_width), .error_capture_mode(error_capture_mode), .restrict_turns(restrict_turns), .predecode_lar_info(predecode_lar_info), .routing_type(routing_type), .dim_order(dim_order), .input_stage_can_hold(input_stage_can_hold), .fb_regfile_type(fb_regfile_type), .fb_mgmt_type(fb_mgmt_type), .explicit_pipeline_register(explicit_pipeline_register), .dual_path_alloc(dual_path_alloc), .dual_path_allow_conflicts(dual_path_allow_conflicts), .dual_path_mask_on_ready(dual_path_mask_on_ready), .precomp_ivc_sel(precomp_ivc_sel), .precomp_ip_sel(precomp_ip_sel), .elig_mask(elig_mask), .vc_alloc_type(vc_alloc_type), .vc_alloc_arbiter_type(vc_alloc_arbiter_type), .vc_alloc_prefer_empty(vc_alloc_prefer_empty), .sw_alloc_type(sw_alloc_type), .sw_alloc_arbiter_type(sw_alloc_arbiter_type), .sw_alloc_spec_type(sw_alloc_spec_type), .crossbar_type(crossbar_type), .reset_type(reset_type) )
    rtr_5 (.clk(clk), .reset(rst), .router_address(4'b1001), .channel_in_ip({channel_router_5_ip_0, channel_router_5_ip_1, channel_router_5_ip_2, channel_router_5_ip_3, channel_router_5_ip_4}), .flow_ctrl_out_ip({ flow_ctrl_router_5_ip_0, flow_ctrl_router_5_ip_1, flow_ctrl_router_5_ip_2, flow_ctrl_router_5_ip_3, flow_ctrl_router_5_ip_4 }), .channel_out_op({ channel_router_5_op_0, channel_router_5_op_1, channel_router_5_op_2, channel_router_5_op_3, channel_router_5_op_4 }), .flow_ctrl_in_op({ flow_ctrl_router_5_op_0, flow_ctrl_router_5_op_1, flow_ctrl_router_5_op_2, flow_ctrl_router_5_op_3, flow_ctrl_router_5_op_4 }), .error(rtr_error[5]));

    router_wrap #( .packet_format(0), .topology(topology), .buffer_size(buffer_size), .num_message_classes(num_message_classes), .num_resource_classes(num_resource_classes), .num_vcs_per_class(num_vcs_per_class), .num_nodes(num_nodes), .num_dimensions(num_dimensions), .num_nodes_per_router(num_nodes_per_router), .flow_ctrl_type(flow_ctrl_type), .flow_ctrl_bypass(flow_ctrl_bypass), .max_payload_length(max_payload_length), .min_payload_length(min_payload_length), .router_type(router_type), .enable_link_pm(enable_link_pm), .flit_data_width(flit_data_width), .error_capture_mode(error_capture_mode), .restrict_turns(restrict_turns), .predecode_lar_info(predecode_lar_info), .routing_type(routing_type), .dim_order(dim_order), .input_stage_can_hold(input_stage_can_hold), .fb_regfile_type(fb_regfile_type), .fb_mgmt_type(fb_mgmt_type), .explicit_pipeline_register(explicit_pipeline_register), .dual_path_alloc(dual_path_alloc), .dual_path_allow_conflicts(dual_path_allow_conflicts), .dual_path_mask_on_ready(dual_path_mask_on_ready), .precomp_ivc_sel(precomp_ivc_sel), .precomp_ip_sel(precomp_ip_sel), .elig_mask(elig_mask), .vc_alloc_type(vc_alloc_type), .vc_alloc_arbiter_type(vc_alloc_arbiter_type), .vc_alloc_prefer_empty(vc_alloc_prefer_empty), .sw_alloc_type(sw_alloc_type), .sw_alloc_arbiter_type(sw_alloc_arbiter_type), .sw_alloc_spec_type(sw_alloc_spec_type), .crossbar_type(crossbar_type), .reset_type(reset_type) )
    rtr_6 (.clk(clk), .reset(rst), .router_address(4'b0010), .channel_in_ip({channel_router_6_ip_0, channel_router_6_ip_1, channel_router_6_ip_2, channel_router_6_ip_3, channel_router_6_ip_4}), .flow_ctrl_out_ip({ flow_ctrl_router_6_ip_0, flow_ctrl_router_6_ip_1, flow_ctrl_router_6_ip_2, flow_ctrl_router_6_ip_3, flow_ctrl_router_6_ip_4 }), .channel_out_op({ channel_router_6_op_0, channel_router_6_op_1, channel_router_6_op_2, channel_router_6_op_3, channel_router_6_op_4 }), .flow_ctrl_in_op({ flow_ctrl_router_6_op_0, flow_ctrl_router_6_op_1, flow_ctrl_router_6_op_2, flow_ctrl_router_6_op_3, flow_ctrl_router_6_op_4 }), .error(rtr_error[6]));

    router_wrap #( .packet_format(0), .topology(topology), .buffer_size(buffer_size), .num_message_classes(num_message_classes), .num_resource_classes(num_resource_classes), .num_vcs_per_class(num_vcs_per_class), .num_nodes(num_nodes), .num_dimensions(num_dimensions), .num_nodes_per_router(num_nodes_per_router), .flow_ctrl_type(flow_ctrl_type), .flow_ctrl_bypass(flow_ctrl_bypass), .max_payload_length(max_payload_length), .min_payload_length(min_payload_length), .router_type(router_type), .enable_link_pm(enable_link_pm), .flit_data_width(flit_data_width), .error_capture_mode(error_capture_mode), .restrict_turns(restrict_turns), .predecode_lar_info(predecode_lar_info), .routing_type(routing_type), .dim_order(dim_order), .input_stage_can_hold(input_stage_can_hold), .fb_regfile_type(fb_regfile_type), .fb_mgmt_type(fb_mgmt_type), .explicit_pipeline_register(explicit_pipeline_register), .dual_path_alloc(dual_path_alloc), .dual_path_allow_conflicts(dual_path_allow_conflicts), .dual_path_mask_on_ready(dual_path_mask_on_ready), .precomp_ivc_sel(precomp_ivc_sel), .precomp_ip_sel(precomp_ip_sel), .elig_mask(elig_mask), .vc_alloc_type(vc_alloc_type), .vc_alloc_arbiter_type(vc_alloc_arbiter_type), .vc_alloc_prefer_empty(vc_alloc_prefer_empty), .sw_alloc_type(sw_alloc_type), .sw_alloc_arbiter_type(sw_alloc_arbiter_type), .sw_alloc_spec_type(sw_alloc_spec_type), .crossbar_type(crossbar_type), .reset_type(reset_type) )
    rtr_7 (.clk(clk), .reset(rst), .router_address(4'b0110), .channel_in_ip({channel_router_7_ip_0, channel_router_7_ip_1, channel_router_7_ip_2, channel_router_7_ip_3, channel_router_7_ip_4}), .flow_ctrl_out_ip({ flow_ctrl_router_7_ip_0, flow_ctrl_router_7_ip_1, flow_ctrl_router_7_ip_2, flow_ctrl_router_7_ip_3, flow_ctrl_router_7_ip_4 }), .channel_out_op({ channel_router_7_op_0, channel_router_7_op_1, channel_router_7_op_2, channel_router_7_op_3, channel_router_7_op_4 }), .flow_ctrl_in_op({ flow_ctrl_router_7_op_0, flow_ctrl_router_7_op_1, flow_ctrl_router_7_op_2, flow_ctrl_router_7_op_3, flow_ctrl_router_7_op_4 }), .error(rtr_error[7]));

    router_wrap #( .packet_format(0), .topology(topology), .buffer_size(buffer_size), .num_message_classes(num_message_classes), .num_resource_classes(num_resource_classes), .num_vcs_per_class(num_vcs_per_class), .num_nodes(num_nodes), .num_dimensions(num_dimensions), .num_nodes_per_router(num_nodes_per_router), .flow_ctrl_type(flow_ctrl_type), .flow_ctrl_bypass(flow_ctrl_bypass), .max_payload_length(max_payload_length), .min_payload_length(min_payload_length), .router_type(router_type), .enable_link_pm(enable_link_pm), .flit_data_width(flit_data_width), .error_capture_mode(error_capture_mode), .restrict_turns(restrict_turns), .predecode_lar_info(predecode_lar_info), .routing_type(routing_type), .dim_order(dim_order), .input_stage_can_hold(input_stage_can_hold), .fb_regfile_type(fb_regfile_type), .fb_mgmt_type(fb_mgmt_type), .explicit_pipeline_register(explicit_pipeline_register), .dual_path_alloc(dual_path_alloc), .dual_path_allow_conflicts(dual_path_allow_conflicts), .dual_path_mask_on_ready(dual_path_mask_on_ready), .precomp_ivc_sel(precomp_ivc_sel), .precomp_ip_sel(precomp_ip_sel), .elig_mask(elig_mask), .vc_alloc_type(vc_alloc_type), .vc_alloc_arbiter_type(vc_alloc_arbiter_type), .vc_alloc_prefer_empty(vc_alloc_prefer_empty), .sw_alloc_type(sw_alloc_type), .sw_alloc_arbiter_type(sw_alloc_arbiter_type), .sw_alloc_spec_type(sw_alloc_spec_type), .crossbar_type(crossbar_type), .reset_type(reset_type) )
    rtr_8 (.clk(clk), .reset(rst), .router_address(4'b1010), .channel_in_ip({channel_router_8_ip_0, channel_router_8_ip_1, channel_router_8_ip_2, channel_router_8_ip_3, channel_router_8_ip_4}), .flow_ctrl_out_ip({ flow_ctrl_router_8_ip_0, flow_ctrl_router_8_ip_1, flow_ctrl_router_8_ip_2, flow_ctrl_router_8_ip_3, flow_ctrl_router_8_ip_4 }), .channel_out_op({ channel_router_8_op_0, channel_router_8_op_1, channel_router_8_op_2, channel_router_8_op_3, channel_router_8_op_4 }), .flow_ctrl_in_op({ flow_ctrl_router_8_op_0, flow_ctrl_router_8_op_1, flow_ctrl_router_8_op_2, flow_ctrl_router_8_op_3, flow_ctrl_router_8_op_4 }), .error(rtr_error[8]));


    // ==========================================================================
    // 5. NODE INSTANTIATION (Core/RAM/Dummy)
    // ==========================================================================
    genvar i;
    generate
    for(i = 0; i < num_nodes; i = i + 1) begin: nodes
        
        localparam CURRENT_X = i % 3;
        localparam CURRENT_Y = i / 3;

        // Tách dây cho tung Node
        wire [0:channel_width - 1]                node_flit_out;
        wire [0:flow_ctrl_width-1] node_flow_in;  
        wire [0:channel_width - 1]                node_flit_in;
        wire [0:flow_ctrl_width-1] node_flow_out; 
        
        assign injection_channels[i*channel_width +: channel_width] = node_flit_out;
        assign node_flow_in = injection_flow_ctrl[i*flow_ctrl_width +: flow_ctrl_width];
        assign node_flit_in = ejection_channels[i*channel_width +: channel_width];
        assign ejection_flow_ctrl[i*flow_ctrl_width +: flow_ctrl_width] = node_flow_out;

// -----------------------------------------------------------------
        // KHỐI LỆNH IF-ELSE ĐỊNH NGHĨA TỪNG NODE
        // -----------------------------------------------------------------

        // --- HÀNG 0 (Y=0) ---
        if (i == 0) begin
            // Node 0 (0,0): CORE 0
            tile_core_wrapper #(
                .MY_X(CURRENT_X), .MY_Y(CURRENT_Y),
                .PROG_FILE("C:/Users/ASUS/Desktop/code_da1_comp/code_da1_comp/Quartus_proj/prog_core0.txt")
            ) core0_inst (
                .clk(clk), .rst(rst),
                .ni_ch_out(node_flit_out), .ni_flow_in(node_flow_in),
                .ni_ch_in(node_flit_in),   .ni_flow_out(node_flow_out)
            );

        end else if (i == 1) begin
            // Node 1 (1,0): GPIO 
            tile_gpio_wrapper #(
                .X_COORD(CURRENT_X), .Y_COORD(CURRENT_Y), .BUFFER_DEPTH(3)
            ) gpio_inst (
                .clk(clk), .rst(rst),
                .ni_ch_out(node_flit_out), .ni_flow_in(node_flow_in),
                .ni_ch_in(node_flit_in),   .ni_flow_out(node_flow_out),
                .gpio_pins(fpga_gpio_pins) // [MỚI] Nối ra chân ngoài
            );

        end else if (i == 2) begin
            // Node 2 (2,0): CORE 3
            tile_core_wrapper #(
                .MY_X(CURRENT_X), .MY_Y(CURRENT_Y),
                .PROG_FILE("C:/Users/ASUS/Desktop/code_da1_comp/code_da1_comp/Quartus_proj/prog_core3.txt")
            ) core3_inst (
                .clk(clk), .rst(rst),
                .ni_ch_out(node_flit_out), .ni_flow_in(node_flow_in),
                .ni_ch_in(node_flit_in),   .ni_flow_out(node_flow_out)
            );

        // --- HÀNG 1 (Y=1) ---
        end else if (i == 3) begin
            // Node 3 (0,1): TIMER
            tile_timer_wrapper #(
                .X_COORD(CURRENT_X), .Y_COORD(CURRENT_Y), .BUFFER_DEPTH(3)
            ) timer_inst (
                .clk(clk), .rst(rst),
                .ni_ch_out(node_flit_out), .ni_flow_in(node_flow_in),
                .ni_ch_in(node_flit_in),   .ni_flow_out(node_flow_out),
                .timer_debug_leds(fpga_timer_debug) 
            );

        end else if (i == 4) begin
            // Node 4 (1,1): RAM CHÍNH (SHARED RAM 4KB)
            tile_ram_wrapper #(
                .MY_X(CURRENT_X), .MY_Y(CURRENT_Y), .MEM_SIZE(4096)
            ) main_ram_inst (
                .clk(clk), .rst(rst),
                .ni_ch_out(node_flit_out), .ni_flow_in(node_flow_in),
                .ni_ch_in(node_flit_in),   .ni_flow_out(node_flow_out)
            );

        end else if (i == 5) begin
            // Node 5 (2,1): LED MATRIX
            tile_led_matrix_wrapper #(
                .X_COORD(CURRENT_X), .Y_COORD(CURRENT_Y), .BUFFER_DEPTH(3)
            ) led_matrix_inst (
                .clk(clk), .rst(rst),
                .ni_ch_out(node_flit_out), .ni_flow_in(node_flow_in),
                .ni_ch_in(node_flit_in),   .ni_flow_out(node_flow_out),
                .led_pins_out(fpga_led_matrix_out) 
            );

        // --- HÀNG 2 (Y=2) ---
        end else if (i == 6) begin
            // Node 6 (0,2): CORE 1
            tile_core_wrapper #(
                .MY_X(CURRENT_X), .MY_Y(CURRENT_Y),
                .PROG_FILE("C:/Users/ASUS/Desktop/code_da1_comp/code_da1_comp/Quartus_proj/prog_core1.txt")
            ) core1_inst (
                .clk(clk), .rst(rst),
                .ni_ch_out(node_flit_out), .ni_flow_in(node_flow_in),
                .ni_ch_in(node_flit_in),   .ni_flow_out(node_flow_out)
            );

        end else if (i == 7) begin
            // Node 7 (1,2): UART
            tile_uart_wrapper #(
                .X_COORD(CURRENT_X), .Y_COORD(CURRENT_Y), .BUFFER_DEPTH(3)
            ) uart_inst (
                .clk(clk), .rst(rst),
                .ni_ch_out(node_flit_out), .ni_flow_in(node_flow_in),
                .ni_ch_in(node_flit_in),   .ni_flow_out(node_flow_out),
                .uart_tx(uart_tx), // [MỚI] Nối ra chân TX
                .uart_rx(uart_rx)  // [MỚI] Nối ra chân RX
            );

        end else if (i == 8) begin
            // Node 8 (2,2): CORE 2
            tile_core_wrapper #(
                .MY_X(CURRENT_X), .MY_Y(CURRENT_Y),
               .PROG_FILE("C:/Users/ASUS/Desktop/code_da1_comp/code_da1_comp/Quartus_proj/prog_core2.txt")
            ) core2_inst (
                .clk(clk), .rst(rst),
                .ni_ch_out(node_flit_out), .ni_flow_in(node_flow_in),
                .ni_ch_in(node_flit_in),   .ni_flow_out(node_flow_out)
            );

        end
    end
    endgenerate
     
    assign error_leds = rtr_error;

endmodule
