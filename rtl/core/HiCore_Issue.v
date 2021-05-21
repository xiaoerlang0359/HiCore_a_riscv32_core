`include "config.v"
module HiCore_Issue(
    // de2issue pipe interface
    input  i_de2issue_valid,
    output i_de2issue_ready,
    input  i_de2issue_cancel,
    input  [`HiCore_DE2ISSUE_SIZE-1:0] i_de2issue_info,
    // issue2bjp interface
    output bjp_valid,
    input  bjp_ready,
    output bjp_cancel,
    output [`HiCore_REG_SIZE-1:0] bjp_rd_result,
    output bjp_rd_need,
    output [`HiCore_RFIDX_WIDTH-1:0] bjp_rd_idx,
    output [`HiCore_ISSUE2ALU_SIZE-1:0] bjp_info,
    // issue2alu interface
    output alu_valid,
    input  alu_ready,
    output alu_cancel,
    output [`HiCore_REG_SIZE-1:0] alu_src1,
    output [`HiCore_REG_SIZE-1:0] alu_src2,
    output alu_rd_need,
    output [`HiCore_RFIDX_WIDTH-1:0] alu_rd_idx,
    output [2:0] alu_msg,
    output alu_dir,
    output auipc_op,
    output lui_op,
    output alu_op,
    output [`HiCore_ISSUE2ALU_SIZE-1:0] alu_info,
    // issue2agu interface
    output agu_valid,
    input  agu_ready,
    output agu_cancel,
    output [`HiCore_REG_SIZE-1:0] agu_src1,
    output [`HiCore_REG_SIZE-1:0] agu_src2,
    output [`HiCore_REG_SIZE-1:0] agu_src3,
    output agu_rd_need,
    output [`HiCore_RFIDX_WIDTH-1:0] agu_rd_idx,
    output [2:0] agu_msg,
    output load_op,
    output store_op,
    output [`HiCore_ISSUE2ALU_SIZE-1:0] agu_info,
    // issue2csr interface
    output csr_valid,
    input  csr_ready,
    output csr_cancel,
    output [`HiCore_REG_SIZE-1:0] csr_reg_src,
    output csr_rd_need,
    output [`HiCore_RFIDX_WIDTH-1:0] csr_rd_idx,
    output [`HiCore_CSRIDX_WIDTH-1:0] csr_idx,
    output [2:0] csr_msg,
    output [`HiCore_ISSUE2ALU_SIZE-1:0] csr_info,
    // issue2nop interface
    output nop_valid,
    input  nop_ready,
    output nop_cancel,
    output mret_op,
    output fence_i_op,
    output [`HiCore_ISSUE2ALU_SIZE-1:0] nop_info
    // rob interface
//    output rob_wen,
//    output rob_rd_need,
//    output [`HiCore_RFIDX_WIDTH-1:0] rob_rd_idx,
//    output rob_csr_need,
//    output [`HiCore_CSRIDX_WIDTH-1:0] rob_csr_idx,
//    output rob_fence_i_op,
//    output rob_mret_op,
//    input  [`HiCore_ROB_PTR_SIZE-1:0] rob_ptr
);

wire branch_sel = i_de2issue_info[`HiCore_DE2ISSUE_SIZE-1];
wire alu_sel = i_de2issue_info[`HiCore_DE2ISSUE_SIZE-2];
wire agu_sel = i_de2issue_info[`HiCore_DE2ISSUE_SIZE-3];
wire csr_sel = i_de2issue_info[`HiCore_DE2ISSUE_SIZE-4];
wire nop_sel = i_de2issue_info[`HiCore_DE2ISSUE_SIZE-5];
wire [`HiCore_ISSUE2ALU_SIZE-1:0] issue_info;
wire [`HiCore_ROB_PTR_SIZE-1:0] rob_ptr = i_de2issue_info[`HiCore_DE2ISSUE_SIZE-6:`HiCore_DE2ISSUE_PRE_SIZE];
/////////////////////////////////////////////////////
// issue2bjp interface
/////////////////////////////////////////////////////
assign bjp_valid = branch_sel & i_de2issue_valid;
assign bjp_cancel = i_de2issue_cancel;
assign bjp_rd_result = (bjp_valid)? 
                       i_de2issue_info[`HiCore_DE2BJ_SIZE-2-`HiCore_RFIDX_WIDTH:`HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE]
                       : 0;
assign bjp_rd_need = i_de2issue_info[`HiCore_DE2BJ_SIZE-1];
assign bjp_rd_idx = i_de2issue_info[`HiCore_DE2BJ_SIZE-2:`HiCore_DE2BJ_SIZE-1-`HiCore_RFIDX_WIDTH];
assign bjp_info = issue_info;
/////////////////////////////////////////////////////
// issue2alu interface
/////////////////////////////////////////////////////
assign alu_valid = alu_sel & i_de2issue_valid;
assign alu_cancel = i_de2issue_cancel;
assign {alu_op,lui_op,auipc_op,alu_dir,alu_msg,
        alu_rd_need,alu_rd_idx,alu_src2,alu_src1} = 
        i_de2issue_info[`HiCore_DE2ALU_SIZE-1:`HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE];
assign alu_info = issue_info;
/////////////////////////////////////////////////////
// issue2agu interface
/////////////////////////////////////////////////////
assign agu_valid = agu_sel & i_de2issue_valid;
assign agu_cancel = i_de2issue_cancel;
assign {store_op,load_op,agu_msg,agu_rd_need,
        agu_rd_idx,agu_src3,agu_src2,agu_src1} = 
        i_de2issue_info[`HiCore_DE2AGU_SIZE-1:`HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE];
assign agu_info = issue_info;
/////////////////////////////////////////////////////
// issue2csr interface
/////////////////////////////////////////////////////
assign csr_valid = csr_sel & i_de2issue_valid;
assign csr_cancel = i_de2issue_cancel;
assign {csr_msg,csr_idx,csr_rd_need,csr_rd_idx,csr_reg_src} = 
        i_de2issue_info[`HiCore_DE2CSR_SIZE-1:`HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE];
assign csr_info = issue_info;
/////////////////////////////////////////////////////
// nop interface
/////////////////////////////////////////////////////
wire nop_rd_need = 1'b0;
wire [`HiCore_RFIDX_WIDTH-1:0] nop_rd_idx = 0;
assign nop_valid = nop_sel & i_de2issue_valid;
assign nop_cancel = i_de2issue_cancel;
assign fence_i_op = i_de2issue_info[`HiCore_DE2NOP_SIZE-1];
assign mret_op = i_de2issue_info[`HiCore_DE2NOP_SIZE-2];
assign nop_info = issue_info;
/////////////////////////////////////////////////////
// rob interface
/////////////////////////////////////////////////////
//assign rob_wen = i_de2issue_valid & i_de2issue_ready;
//assign rob_rd_need = (bjp_valid & bjp_rd_need) |
//                     (alu_valid & alu_rd_need) |
//                     (agu_valid & agu_rd_need) |
//                     (csr_valid & csr_rd_need) |
//                     (nop_valid & nop_rd_need);
//assign rob_rd_idx = ({`HiCore_RFIDX_WIDTH{bjp_valid}} & bjp_rd_idx) |
//                    ({`HiCore_RFIDX_WIDTH{alu_valid}} & alu_rd_idx) |
//                    ({`HiCore_RFIDX_WIDTH{agu_valid}} & agu_rd_idx) |
//                    ({`HiCore_RFIDX_WIDTH{csr_valid}} & csr_rd_idx) |
//                    ({`HiCore_RFIDX_WIDTH{nop_valid}} & nop_rd_idx);
assign issue_info = {rob_ptr,
                    i_de2issue_info[`HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE-1:0]};
//assign rob_csr_need = csr_valid;
//assign rob_csr_idx = {`HiCore_CSRIDX_WIDTH{csr_valid}} & csr_idx;
//assign rob_fence_i_op = fence_i_op & nop_valid;
//assign rob_mret_op = mret_op & nop_valid;
/////////////////////////////////////////////////////
// de2issue pipe interface
/////////////////////////////////////////////////////
assign i_de2issue_ready = ((bjp_valid & bjp_ready) |
                          (alu_valid & alu_ready) |
                          (agu_valid & agu_ready) |
                          (csr_valid & csr_ready) |
                          (nop_valid & nop_ready));

endmodule
