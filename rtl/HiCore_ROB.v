module HiCore_ROB(
// issue interface
    input  issue_wen,
    input  issue_rd_need,
    input  [`HiCore_RFIDX_WIDTH-1:0] issue_rd_idx,
    input  issue_csr_need,
    input  [`HiCore_CSRIDX_WIDTH-1:0] issue_csr_idx,
    input  [`HiCore_PC_SIZE-1:0] issue_next_pc,
    input  issue_fence_i_op,
    input  issue_mret_op,
    output [`HiCore_ROB_PTR_SIZE-1:0] issue_tail_ptr,
    output issue_full,
// bjp writeback interface
    input bjp_wb_wen,
    input [`HiCore_ROB_PTR_SIZE-1:0] bjp_wb_ptr,
    input [`HiCore_REG_SIZE-1:0] bjp_wb_rd_data,
    input [`HiCore_WB_SIZE-1:0] bjp_wb_info,
// alu writeback interface
    input alu_wb_wen,
    input [`HiCore_ROB_PTR_SIZE-1:0] alu_wb_ptr,
    input [`HiCore_REG_SIZE-1:0] alu_wb_rd_data,
    input [`HiCore_WB_SIZE-1:0] alu_wb_info,
// lsu writeback interface
    input lsu_wb_wen,
    input [`HiCore_ROB_PTR_SIZE-1:0] lsu_wb_ptr,
    input [`HiCore_REG_SIZE-1:0] lsu_wb_rd_data,
    input [`HiCore_WB_SIZE-1:0] lsu_wb_info,
// csr writeback interface
    input csr_wb_wen,
    input [`HiCore_ROB_PTR_SIZE-1:0] csr_wb_ptr,
    input [`HiCore_REG_SIZE-1:0] csr_wb_rd_data,
    input [`HiCore_REG_SIZE-1:0] csr_wb_csr_data,
    input [`HiCore_WB_SIZE-1:0] csr_wb_info,
// nop writeback interface
    input nop_wb_wen,
    input [`HiCore_ROB_PTR_SIZE-1:0] nop_wb_ptr,
    input [`HiCore_WB_SIZE-1:0] nop_wb_info,
// commit interface
    input  commit_valid,
    output commit_ready,
    output commit_rd_need,
    output [`HiCore_RFIDX_WIDTH-1:0] commit_rd_idx,
    output [`HiCore_REG_SIZE-1:0] commit_rd_data,
    output commit_csr_need,
    output [`HiCore_CSRIDX_WIDTH-1:0] commit_csr_idx,
    output [`HiCore_REG_SIZE-1:0] commit_csr_data,
    output commit_fence_i_op,
    output commit_mret_op,
    output [`HiCore_PC_SIZE-1:0] commit_next_pc,
    output [`HiCore_WB_SIZE-1:0] commit_info,
    input  flush,
// dependency interface TODO:
    input  de_rs1_need,
    input  de_rs2_need,
    input  [`HiCore_RFIDX_WIDTH-1:0] de_rs1_idx,
    input  [`HiCore_RFIDX_WIDTH-1:0] de_rs2_idx,
    input  de_csr_need,
    input  [`HiCore_CSRIDX_WIDTH-1:0] de_csr_idx,
    output de_depend,
    output de_empty,  
// store interface
    output [`HiCore_ROB_PTR_SIZE-1:0] lsu_head_ptr,
// system interface
    input clk,
    input rst_n
);

localparam EMPTY_S     = 3'b000;
localparam MAPPED_S    = 3'b010;
localparam WRITEBACK_S = 3'b100;
wire [`HiCore_ROB_SIZE-1:0]     rob_issue_wen; 
wire [`HiCore_ROB_SIZE-1:0]     rob_wb_wen;  
wire [`HiCore_ROB_SIZE-1:0]     rob_rd_need;
wire [`HiCore_RFIDX_WIDTH-1:0]  rob_rd_idx      [`HiCore_ROB_SIZE-1:0];
wire [`HiCore_REG_SIZE-1:0]     rob_rd_data     [`HiCore_ROB_SIZE-1:0];
wire [`HiCore_REG_SIZE-1:0]     rob_rd_data_nxt [`HiCore_ROB_SIZE-1:0];
wire [`HiCore_ROB_SIZE-1:0]     rob_csr_need;
wire [`HiCore_CSRIDX_WIDTH-1:0] rob_csr_idx     [`HiCore_ROB_SIZE-1:0];
wire [`HiCore_ROB_SIZE-1:0]     rob_csr_data_wen;
wire [`HiCore_REG_SIZE-1:0]     rob_csr_data    [`HiCore_ROB_SIZE-1:0];
wire [`HiCore_ROB_SIZE-1:0]     rob_fence_i_op;
wire [`HiCore_ROB_SIZE-1:0]     rob_mret_op;
wire [`HiCore_WB_SIZE-1:0]      rob_info_nxt    [`HiCore_ROB_SIZE-1:0];
wire [`HiCore_WB_SIZE-1:0]      rob_info        [`HiCore_ROB_SIZE-1:0];
wire [`HiCore_ROB_SIZE-1:0]     rob_state_en;
wire [2:0]                      rob_state_nxt   [`HiCore_ROB_SIZE-1:0];
wire [2:0]                      rob_state       [`HiCore_ROB_SIZE-1:0];
wire [`HiCore_PC_SIZE-1:0]      rob_next_pc     [`HiCore_ROB_SIZE-1:0];

wire rob_wen;
wire [`HiCore_ROB_PTR_SIZE:0] rob_tail_ptr_nxt;
wire [`HiCore_ROB_PTR_SIZE:0] rob_tail_ptr;
wire [`HiCore_ROB_PTR_SIZE:0] rob_head_ptr_nxt;
wire [`HiCore_ROB_PTR_SIZE:0] rob_head_ptr;
wire rob_ren;
wire rob_full;
wire rob_empty;

/////////////////////////////////////////////////////////
// write rob
/////////////////////////////////////////////////////////
genvar i;
generate 
    for (i=0;i<`HiCore_ROB_SIZE;i=i+1) 
    begin: gen_for_issue_wen
        assign rob_issue_wen[i] = issue_wen & (i==rob_tail_ptr[`HiCore_ROB_PTR_SIZE-1:0]);
        gnrl_dfflr #(1)                    rd_need_dfflr (rob_issue_wen[i],issue_rd_need   ,rob_rd_need[i]   ,clk,rst_n);
        gnrl_dfflr #(`HiCore_RFIDX_WIDTH)  rd_idx_dfflr  (rob_issue_wen[i],issue_rd_idx    ,rob_rd_idx[i]    ,clk,rst_n);
        gnrl_dfflr #(1)                    fence_i_dfflr (rob_issue_wen[i],issue_fence_i_op,rob_fence_i_op[i],clk,rst_n);
        gnrl_dfflr #(1)                    mret_dfflr    (rob_issue_wen[i],issue_mret_op   ,rob_mret_op[i]   ,clk,rst_n);
        gnrl_dfflr #(1)                    csr_need_dfflr(rob_issue_wen[i],issue_csr_need  ,rob_csr_need[i]  ,clk,rst_n);
        gnrl_dfflr #(`HiCore_CSRIDX_WIDTH) csr_idx_dfflr (rob_issue_wen[i],issue_csr_idx   ,rob_csr_idx[i]   ,clk,rst_n);
        gnrl_dfflr #(`HiCore_PC_SIZE)      next_pc_dfflr (rob_issue_wen[i],issue_next_pc   ,rob_next_pc[i]   ,clk,rst_n);
    end
endgenerate

generate
    for (i=0;i<`HiCore_ROB_SIZE;i=i+1) 
    begin: gen_for_wb_wen
        assign rob_wb_wen[i] = (bjp_wb_wen & (bjp_wb_ptr==i)) |
                               (alu_wb_wen & (alu_wb_ptr==i)) |
                               (lsu_wb_wen & (lsu_wb_ptr==i)) |
                               (csr_wb_wen & (csr_wb_ptr==i)) |
                               (nop_wb_wen & (nop_wb_ptr==i));
        assign rob_rd_data_nxt[i] = ({`HiCore_REG_SIZE{bjp_wb_wen & (bjp_wb_ptr==i)}} & bjp_wb_rd_data) |
                                    ({`HiCore_REG_SIZE{alu_wb_wen & (alu_wb_ptr==i)}} & alu_wb_rd_data) |
                                    ({`HiCore_REG_SIZE{lsu_wb_wen & (lsu_wb_ptr==i)}} & lsu_wb_rd_data) |
                                    ({`HiCore_REG_SIZE{csr_wb_wen & (csr_wb_ptr==i)}} & csr_wb_rd_data);

        assign rob_info_nxt[i] = ({`HiCore_WB_SIZE{bjp_wb_wen & (bjp_wb_ptr==i)}} & bjp_wb_info) |
                                 ({`HiCore_WB_SIZE{alu_wb_wen & (alu_wb_ptr==i)}} & alu_wb_info) |
                                 ({`HiCore_WB_SIZE{lsu_wb_wen & (lsu_wb_ptr==i)}} & lsu_wb_info) |
                                 ({`HiCore_WB_SIZE{csr_wb_wen & (csr_wb_ptr==i)}} & csr_wb_info) |
                                 ({`HiCore_WB_SIZE{nop_wb_wen & (nop_wb_ptr==i)}} & nop_wb_info);
        gnrl_dffl #(`HiCore_REG_SIZE) rd_data_dffl (rob_wb_wen[i],rob_rd_data_nxt[i],rob_rd_data[i],clk);
        gnrl_dfflr #(`HiCore_WB_SIZE)  rob_info_dfflr(rob_wb_wen[i],rob_info_nxt[i] ,rob_info[i]   ,clk,rst_n);
    end
endgenerate

generate
    for (i=0;i<`HiCore_ROB_SIZE;i=i+1)
    begin: gen_for_csr_data
        assign rob_csr_data_wen[i] = csr_wb_wen & (csr_wb_ptr==i);
        gnrl_dffl #(`HiCore_REG_SIZE) csr_data_dffl(rob_csr_data_wen[i],csr_wb_csr_data,rob_csr_data[i],clk);
    end
endgenerate

generate 
    for (i=0;i<`HiCore_ROB_SIZE;i=i+1)
    begin: gen_for_state
        assign rob_state_en[i] = rob_issue_wen[i] | rob_wb_wen[i] | 
                                (rob_ren & (i==rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0])) | flush;                   
        assign rob_state_nxt[i] = (flush)? EMPTY_S:
                                  (rob_issue_wen[i])? MAPPED_S:
                                  (rob_wb_wen[i])?     WRITEBACK_S:EMPTY_S;
        gnrl_dfflr #(3) state_dfflr(rob_state_en[i],rob_state_nxt[i],rob_state[i],clk,rst_n);
    end
endgenerate
////////////////////////////////////////////////////
// deal with fifo ptr
////////////////////////////////////////////////////
assign rob_wen = (issue_wen & (~rob_full)) | flush;
assign rob_tail_ptr_nxt = (flush)? rob_head_ptr+1'b1 : rob_tail_ptr+1'b1;
gnrl_dfflr #(`HiCore_ROB_PTR_SIZE+1) rob_tail_ptr_dfflr(rob_wen,rob_tail_ptr_nxt,rob_tail_ptr,clk,rst_n);
assign rob_ren = commit_valid & commit_ready;
assign rob_head_ptr_nxt = rob_head_ptr+1'b1;
gnrl_dfflr #(`HiCore_ROB_PTR_SIZE+1) rob_head_ptr_dfflr(rob_ren,rob_head_ptr_nxt,rob_head_ptr,clk,rst_n);
assign rob_full = (rob_tail_ptr[`HiCore_ROB_PTR_SIZE] ^ rob_head_ptr[`HiCore_ROB_PTR_SIZE]) & 
                  (rob_tail_ptr[`HiCore_ROB_PTR_SIZE-1:0] == rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]);
assign rob_empty = (rob_tail_ptr == rob_head_ptr);
// issue interface
assign issue_tail_ptr = rob_tail_ptr[`HiCore_ROB_PTR_SIZE-1:0];
assign issue_full = rob_full;
// store interface
assign lsu_head_ptr = rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0];
/////////////////////////////////////////////////////
// commit interface
/////////////////////////////////////////////////////
assign commit_ready = (rob_state[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]] == WRITEBACK_S);
assign commit_rd_need = rob_rd_need[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
assign commit_rd_idx = rob_rd_idx[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
assign commit_rd_data = rob_rd_data[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
assign commit_csr_need = rob_csr_need[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
assign commit_csr_idx = rob_csr_idx[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
assign commit_csr_data = rob_csr_data[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
assign commit_fence_i_op = rob_fence_i_op[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
assign commit_mret_op = rob_mret_op[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
assign commit_info = rob_info[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
assign commit_next_pc = rob_next_pc[rob_head_ptr[`HiCore_ROB_PTR_SIZE-1:0]];
/////////////////////////////////////////////////////
// dependency interface
/////////////////////////////////////////////////////
wire [`HiCore_ROB_SIZE-1:0] rs1_depend;
wire [`HiCore_ROB_SIZE-1:0] rs2_depend;
wire [`HiCore_ROB_SIZE-1:0] csr_depend;
generate
    for (i=0;i<`HiCore_ROB_SIZE;i=i+1) 
    begin: gen_for_depend
        assign rs1_depend[i] = ((rob_state[i]!=EMPTY_S) & (rob_rd_idx[i]==de_rs1_idx) & de_rs1_need & (de_rs1_idx!=0));// TODO: & rob_rd_need[i]
        assign rs2_depend[i] = ((rob_state[i]!=EMPTY_S) & (rob_rd_idx[i]==de_rs2_idx) & de_rs2_need & (de_rs2_idx!=0));
        assign csr_depend[i] = ((rob_state[i]!=EMPTY_S) & (rob_csr_idx[i]==de_csr_idx)& de_csr_need & rob_csr_need[i]);
    end
endgenerate
assign de_depend = (|rs1_depend) | (|rs2_depend) | (|csr_depend);
assign de_empty = rob_empty;
endmodule
