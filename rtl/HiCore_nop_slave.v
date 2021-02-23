module HiCore_nop_slave #(
    parameter AW=32,
    parameter DW=32
)(
    input               icb_cmd_valid,
    output              icb_cmd_ready,
    input  [AW-1:0]     icb_cmd_addr,
    input               icb_cmd_read,
    input  [DW-1:0]     icb_cmd_wdata,
    input  [DW/8-1:0]   icb_cmd_wmask,

    input               icb_rsp_ready,
    output              icb_rsp_valid,
    output              icb_rsp_err,
    output [DW-1:0]     icb_rsp_rdata,

    input               clk,
    input               rst_n
);

HiCore_pipe # (
  .CUT_READY(0),
  .DW(DW)
) slave_pipe(
  .i_vld(icb_cmd_valid), 
  .i_rdy(icb_cmd_ready), 
  .i_dat(0),
  .i_cancel(1'b0),
  .o_vld(icb_rsp_valid), 
  .o_rdy(icb_rsp_ready), 
  .o_dat(icb_rsp_rdata),
  .o_cancel(),
  .branch(1'b0),
  .clk(clk),
  .rst_n(rst_n)
);

assign icb_rsp_err = 1'b1;

endmodule
