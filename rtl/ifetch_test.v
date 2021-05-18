`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/27 13:29:47
// Design Name: 
// Module Name: ifetch_test
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


module ifetch_test(
    input branch,
    input [31:0] branch_pc,
    input flush,
    input [31:0] flush_pc,
    input clk,
    input rst_n
);

wire icache_icb_cmd_valid;
wire icache_icb_cmd_ready;
wire [`HiCore_ADDR_SIZE-1:0] icache_icb_cmd_addr;
wire icache_icb_rsp_ready;
wire icache_icb_rsp_valid;
wire icache_icb_rsp_cancel;
wire [`HiCore_IF2DE_SIZE-1:0] icache_icb_rsp_rdata;

HiCore_ifetch u_HiCore_ifetch(
    // interface of icache icb
.icache_icb_cmd_valid(icache_icb_cmd_valid),
.icache_icb_cmd_ready(icache_icb_cmd_ready),
.icache_icb_cmd_read(),
.icache_icb_cmd_addr(icache_icb_cmd_addr),
.icache_icb_cmd_wdata(),
.icache_icb_cmd_wmask(),

.icache_icb_rsp_ready(icache_icb_rsp_ready),
.icache_icb_rsp_valid(icache_icb_rsp_valid),
.icache_icb_rsp_rdata(icache_icb_rsp_rdata),
.icache_icb_rsp_cancel(icache_icb_rsp_cancel),
    // interface of pipe to decoder
.o_if2de_valid(),
.o_if2de_ready(1'b1),
.o_if2de_info(),
.o_if2de_cancel(),
    // interface of commit
.branch_pc(branch_pc),
.branch(branch),
.flush(flush),
.flush_pc(flush_pc),
    // interface of system
.clk(clk),
.rst_n(rst_n)
);

ifetch_sram_ctrl #(
    .DW(32),
    .RAM_DEPTH(14)
)u_ifetch_sram_ctrl(
// itcm interface
.icache_icb_cmd_valid(icache_icb_cmd_valid),
.icache_icb_cmd_ready(icache_icb_cmd_ready),
.icache_icb_cmd_read(1'b1),
.icache_icb_cmd_addr(icache_icb_cmd_addr),
.icache_icb_cmd_wdata(0),
.icache_icb_cmd_wmask(0),

.icache_icb_rsp_ready(icache_icb_rsp_ready),
.icache_icb_rsp_valid(icache_icb_rsp_valid),
.icache_icb_rsp_rdata(icache_icb_rsp_rdata),
.icache_icb_rsp_cancel(icache_icb_rsp_cancel),
// flush interface
.flush(flush),
.branch(branch),
// system interface
.clk(clk),
.rst_n(rst_n)
);
endmodule
