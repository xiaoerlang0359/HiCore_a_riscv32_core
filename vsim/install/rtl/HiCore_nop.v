`include "config.v"
module HiCore_nop(
// issue interface
    input  i_issue2nop_valid,
    output i_issue2nop_ready,
    input  i_issue2nop_cancel,
    input  mret_op,
    input  fence_i_op,
    input  [`HiCore_ISSUE2ALU_SIZE-1:0] nop_info,
// write back interface
    output nop_wb_wen,
    output [`HiCore_ROB_PTR_SIZE-1:0] nop_wb_ptr,
    output [`HiCore_WB_SIZE-1:0] nop_wb_info,
// flush
    input  flush
);
assign i_issue2nop_ready = 1'b1;
assign nop_wb_wen = i_issue2nop_valid & (~i_issue2nop_cancel) & (~flush);
assign {nop_wb_ptr,nop_wb_info} = nop_info;

endmodule
