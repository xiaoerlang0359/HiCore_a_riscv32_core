`include "config.v"
module HiCore_commit(
// rob interface
    output rob_valid,
    input  rob_ready,
    input  rob_rd_need,
    input  [`HiCore_RFIDX_WIDTH-1:0] rob_rd_idx,
    input  [`HiCore_REG_SIZE-1:0] rob_rd_data,
    input  rob_csr_need,
    input  [`HiCore_CSRIDX_WIDTH-1:0] rob_csr_idx,
    input  [`HiCore_REG_SIZE-1:0] rob_csr_data,
    input  rob_fence_i_op,
    input  rob_mret_op,
    input  [`HiCore_PC_SIZE-1:0] rob_next_pc, 
    input  [`HiCore_WB_SIZE-1:0] rob_info,
// csr interface
    output csr_valid,
    output [`HiCore_EXCP_SIZE-1:0] csr_excp,
    output [`HiCore_IRQ_SIZE-1:0] csr_irq,
    output [`HiCore_PC_SIZE-1:0] csr_pc,
    output [`HiCore_PC_SIZE-1:0] csr_next_pc,
    output csr_csr_need,
    output [`HiCore_CSRIDX_WIDTH-1:0] csr_csr_idx,
    output [`HiCore_REG_SIZE-1:0] csr_csr_data,
    output csr_mret_op,
    input  [`HiCore_IRQ_SIZE-1:0] csr_irq_msk,
    input  [`HiCore_REG_SIZE-1:0] csr_mepc,
    input  [`HiCore_REG_SIZE-1:0] csr_mtvec,
// register file interface
    output reg_wen,
    output [`HiCore_RFIDX_WIDTH-1:0] reg_rd_idx,
    output [`HiCore_REG_SIZE-1:0] reg_rd_data,
// flush
    output flush,
    output [`HiCore_PC_SIZE-1:0] flush_pc
);
////////////////////////////////////////////////////
// rob interface
////////////////////////////////////////////////////
wire [`HiCore_EXCP_SIZE-1:0] commit_excp;
wire [`HiCore_IRQ_SIZE-1:0] commit_irq;
wire [`HiCore_PC_SIZE-1:0] commit_pc;
assign {commit_pc,commit_irq,commit_excp} = rob_info;
assign rob_valid = 1'b1;
////////////////////////////////////////////////////
// csr interface
////////////////////////////////////////////////////
assign csr_excp = commit_excp;
assign csr_irq = commit_irq & csr_irq_msk;
assign csr_pc = commit_pc;
assign csr_valid = rob_valid & rob_ready;
assign csr_csr_need = rob_csr_need;
assign csr_csr_idx = rob_csr_idx;
assign csr_csr_data = rob_csr_data;
assign csr_mret_op = rob_mret_op;
assign csr_next_pc = rob_next_pc;
////////////////////////////////////////////////////
// register file interface
////////////////////////////////////////////////////
wire excp_en = rob_valid & rob_ready & (|csr_excp);
wire irq_en = rob_valid & rob_ready & (|csr_irq);
assign reg_wen = rob_valid & rob_ready & (~excp_en) & rob_rd_need;
assign reg_rd_idx = rob_rd_idx;
assign reg_rd_data = rob_rd_data;
///////////////////////////////////////////////////
// flush interface
///////////////////////////////////////////////////
assign flush = rob_valid & rob_ready & (excp_en | irq_en | rob_fence_i_op | rob_mret_op);
assign flush_pc = (excp_en | irq_en)? csr_mtvec:
                  (rob_fence_i_op)?   csr_next_pc: // TODO: need to change next_pc
                  (rob_mret_op)?      csr_mepc : csr_mtvec;

endmodule
