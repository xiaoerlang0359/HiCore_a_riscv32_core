module HiCore_bjp(
// issue interface
    input  i_issue2bjp_valid,
    output i_issue2bjp_ready,
    input  i_issue2bjp_cancel,
    input  [`HiCore_REG_SIZE-1:0] bjp_rd_result,
    input  [`HiCore_ISSUE2ALU_SIZE-1:0] bjp_info,
// write back interface
    output bjp_wb_wen,
    output [`HiCore_ROB_PTR_SIZE-1:0] bjp_wb_ptr,
    output [`HiCore_REG_SIZE-1:0] bjp_wb_rd_data,
    output [`HiCore_WB_SIZE-1:0] bjp_wb_info, 
// flush interface
    input flush
);

assign i_issue2bjp_ready = 1'b1;
assign bjp_wb_wen = i_issue2bjp_valid & (~i_issue2bjp_cancel) & (~flush);
assign bjp_wb_rd_data = bjp_rd_result;
assign {bjp_wb_ptr,bjp_wb_info} = bjp_info;

endmodule
