module sirv_bypbuf #(
    parameter DP = 4,
    parameter DW = 32
)(
    input           i_vld,
    output          i_rdy,
    input  [DW-1:0] i_dat,
    input           i_cancel,

    output          o_vld,
    input           o_rdy,
    output [DW-1:0] o_dat,
    output          o_cancel,
    output          fifo_half_full,

    input flush,
    input clk,
    input rst_n
);

parameter LOGDP = $clog2(DP+1)-1;

wire            fifo_i_vld;
wire            fifo_i_rdy;
wire [DW-1:0]   fifo_i_dat;
wire            fifo_i_cancel;

wire            fifo_o_vld;
wire            fifo_o_rdy;
wire [DW-1:0]   fifo_o_dat;
wire            fifo_o_cancel;

HiCore_queue#(
.DW(DW),
.DP(DP),
.LOGDP(LOGDP)
)bypbuf_fifo(
.i_valid(fifo_i_vld),
.i_ready(fifo_i_rdy),
.i_cancel(fifo_i_cancel),
.i_info(fifo_i_dat),
.o_valid(fifo_o_vld),
.o_ready(fifo_o_rdy),
.o_cancel(fifo_o_cancel),
.o_info(fifo_o_dat),

.flush(flush),

.clk(clk),
.rst_n(rst_n)
);

wire fifo_wen = fifo_i_vld & fifo_i_rdy;
wire fifo_ren = fifo_o_vld & fifo_o_rdy;
wire [LOGDP-1:0] fifo_cnt_r;
wire [LOGDP-1:0] fifo_cnt_nxt;
wire fifo_cnt_ena = fifo_wen ^ fifo_ren;
assign fifo_cnt_nxt = (fifo_wen)? fifo_cnt_r+1'b1:fifo_cnt_r-1'b1;
gnrl_dfflr #(LOGDP) fifo_cnd_dfflr(fifo_cnt_ena,fifo_cnt_nxt,fifo_cnt_r,clk,rst_n);
assign fifo_half_full = (fifo_cnt_r>=(DP/2));

assign i_rdy = fifo_i_rdy;

wire byp = i_vld & o_rdy & (~fifo_o_vld);

assign fifo_o_rdy = o_rdy;

assign o_vld = fifo_o_vld | i_vld;

assign o_dat = fifo_o_vld? fifo_o_dat : i_dat;
assign o_cancel = fifo_o_vld? fifo_o_cancel : i_cancel;

assign fifo_i_dat = i_dat;
assign fifo_i_cancel = i_cancel;

assign fifo_i_vld = i_vld & (~byp);

endmodule
