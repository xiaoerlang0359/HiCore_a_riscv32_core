`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/02 13:14:14
// Design Name: 
// Module Name: HiCore_Clint
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
`include "config.v"
module HiCore_Clint(
    input  clint_icb_cmd_valid,
    output clint_icb_cmd_ready,
    input  clint_icb_cmd_read,
    input  [`HiCore_ADDR_SIZE-1:0]  clint_icb_cmd_addr,
    input  [`HiCore_REG_SIZE-1:0]   clint_icb_cmd_wdata,
    input  [`HiCore_REG_SIZE/8-1:0] clint_icb_cmd_wmask,
    
    output clint_icb_rsp_valid,
    input  clint_icb_rsp_ready,
    output clint_icb_rsp_err,
    output [`HiCore_REG_SIZE-1:0] clint_icb_rsp_rdata,
    
    input  async_clk,
    output m_time_irq,
    output m_soft_irq,
    
    input  clk,
    input  rst_n
);

wire sync_clk;
HiCore_sync#(
    .DP(2),
    .DW(1)
)(
    .dina(async_clk),
    .dout(sync_clk),
    .rst_n(rst_n),
    .clk(clk)
);

wire sync_clk_edge;
wire sync_clk_r;
gnrl_dffr #(1) sync_clk_dffr(sync_clk,sync_clk_r,clk,rst_n);
assign sync_clk_edge = (sync_clk ^ sync_clk_r) & sync_clk;

wire [31:0] mtime_L_r;
wire [31:0] mtime_H_r;
wire [63:0] mtime_plus_one;
assign mtime_plus_one = (sync_clk_edge)? {mtime_H_r,mtime_L_r}+1:
                                         {mtime_H_r,mtime_L_r};
wire sel_mtime_L;
wire rd_mtime_L;
wire wr_mtime_L;
wire mtime_L_ena;
wire [`HiCore_REG_SIZE-1:0] mtime_L_nxt;
assign sel_mtime_L = clint_icb_cmd_valid & clint_icb_cmd_ready & (clint_icb_cmd_addr[15:0]==16'hBFF8);
assign rd_mtime_L = sel_mtime_L & clint_icb_cmd_read;
assign wr_mtime_L = sel_mtime_L & (~clint_icb_cmd_read);
assign mtime_L_ena = wr_mtime_L | sync_clk_edge;
assign mtime_L_nxt = (wr_mtime_L)? clint_icb_cmd_wdata:
                                   mtime_plus_one[31:0];
gnrl_dfflr #(`HiCore_REG_SIZE) mtime_L_dfflr(mtime_L_ena,mtime_L_nxt,mtime_L_r,clk,rst_n);

wire sel_mtime_H;
wire rd_mtime_H;
wire wr_mtime_H;
wire mtime_H_ena;
wire [`HiCore_REG_SIZE-1:0] mtime_H_nxt;
assign sel_mtime_H = clint_icb_cmd_valid & clint_icb_cmd_ready & (clint_icb_cmd_addr[15:0]==16'hBFFC);
assign rd_mtime_H = sel_mtime_H & clint_icb_cmd_read;
assign wr_mtime_H = sel_mtime_H & (~clint_icb_cmd_read);
assign mtime_H_ena = wr_mtime_H | sync_clk_edge;
assign mtime_H_nxt = (wr_mtime_H)? clint_icb_cmd_wdata:
                                   mtime_plus_one[63:32];
gnrl_dfflr #(`HiCore_REG_SIZE) mtime_H_dfflr(mtime_H_ena,mtime_H_nxt,mtime_H_r,clk,rst_n);

wire sel_mtimecmp_L;
wire rd_mtimecmp_L;
wire wr_mtimecmp_L;
wire [`HiCore_REG_SIZE-1:0] mtimecmp_L_r;
assign sel_mtimecmp_L = clint_icb_cmd_valid & clint_icb_cmd_ready & (clint_icb_cmd_addr[15:0]==16'h4000);
assign rd_mtimecmp_L = sel_mtimecmp_L & clint_icb_cmd_read;
assign wr_mtimecmp_L = sel_mtimecmp_L & (~clint_icb_cmd_read);
gnrl_dfflr #(`HiCore_REG_SIZE) mtimecmpL_dfflr(wr_mtimecmp_L,clint_icb_cmd_wdata,mtimecmp_L_r,clk,rst_n);

wire sel_mtimecmp_H;
wire rd_mtimecmp_H;
wire wr_mtimecmp_H;
wire [`HiCore_REG_SIZE-1:0] mtimecmp_H_r;
assign sel_mtimecmp_H = clint_icb_cmd_valid & clint_icb_cmd_ready & (clint_icb_cmd_addr[15:0]==16'h4004);
assign rd_mtimecmp_H = sel_mtimecmp_H & clint_icb_cmd_read;
assign wr_mtimecmp_H = sel_mtimecmp_H & (~clint_icb_cmd_read);
gnrl_dfflr #(`HiCore_REG_SIZE) mtimecmpH_dfflr(wr_mtimecmp_H,clint_icb_cmd_wdata,mtimecmp_H_r,clk,rst_n);

wire sel_msip;
wire rd_msip;
wire wr_msip;
wire [`HiCore_REG_SIZE-1:0] msip_r;
assign sel_msip = clint_icb_cmd_valid & clint_icb_cmd_ready & (clint_icb_cmd_addr[15:0]==16'h0000);
assign rd_msip = sel_msip & clint_icb_cmd_read;
assign wr_msip = sel_msip & (~clint_icb_cmd_read);
gnrl_dfflr #(1) msip_dfflr(wr_msip,clint_icb_cmd_wdata[0],msip_r[0],clk,rst_n);
assign msip_r[`HiCore_REG_SIZE-1:1] = 0;
// 如果出现溢出的话，是硬件处理还是软件处理
assign m_time_irq = {mtime_H_r,mtime_L_r}>{mtimecmp_H_r,mtimecmp_L_r};
assign m_soft_irq = msip_r[0];

wire [`HiCore_REG_SIZE-1:0] pipe_idat;
assign pipe_idat = ({`HiCore_REG_SIZE{rd_mtime_L}} & mtime_L_r) |
                   ({`HiCore_REG_SIZE{rd_mtime_H}} & mtime_H_r) |
                   ({`HiCore_REG_SIZE{rd_mtimecmp_L}} & mtimecmp_L_r) |
                   ({`HiCore_REG_SIZE{rd_mtimecmp_H}} & mtimecmp_H_r) |
                   ({`HiCore_REG_SIZE{rd_msip}} & msip_r);
HiCore_pipe #(
    .CUT_READY(0),
    .DW(`HiCore_REG_SIZE)
)(
    .i_vld(clint_icb_cmd_valid),
    .i_rdy(clint_icb_cmd_ready),
    .i_dat(pipe_idat),
    .i_cancel(1'b0),
    .o_vld(clint_icb_rsp_valid),
    .o_rdy(clint_icb_rsp_ready),
    .o_dat(clint_icb_rsp_rdata),
    .o_cancel(),
    .branch(1'b0),
    .clk(clk),
    .rst_n(rst_n)
);
assign clint_icb_rsp_err = 1'b0;

endmodule
