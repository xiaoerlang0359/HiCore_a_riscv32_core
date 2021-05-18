`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/23 09:29:39
// Design Name: 
// Module Name: HiCore_SoC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HiCore_SoC(
    input clk_in,
    input rst_n_in,
    output flush,
    output branch
    );

wire clk;
wire rst_n;
wire locked;
clk_gen u_clk_gen(
    .clk_in1(clk_in),
    .clk_out1(clk),
    .resetn(rst_n_in),
    .locked(locked)
);  
sys_resetn u_sys_resetn(
    .slowest_sync_clk(clk),
    .ext_reset_in(rst_n_in), // Active-low
    //.ext_reset_in(ck_rst), // Active-low
    .aux_reset_in(1'b1),
    .mb_debug_sys_rst(1'b0),
    .dcm_locked(locked),
    .mb_reset(),
    .bus_struct_reset(),
    .peripheral_reset(),
    .interconnect_aresetn(),
    .peripheral_aresetn(rst_n)    
);
HiCore_cpu u_HiCore_cpu( 
    .uart_irq(1'b0),
    .ext_irq0(1'b0),
    .ext_irq1(1'b0),
    .async_clk(1'b0),
    .clk(clk),
    .rst_n(rst_n),
    .flush(flush),
    .branch(branch)
);
endmodule
