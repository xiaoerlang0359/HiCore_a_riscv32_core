`include "config.v"
module HiCore_Decode(
    // if2de pipe interface
    input  i_if2de_valid,
    output i_if2de_ready,
    input  i_if2de_cancel,
    input  [`HiCore_IF2DE_SIZE-1:0] i_if2de_info,
    // de2issue pipe interface
    output o_de2issue_valid,
    input  o_de2issue_ready,
    output o_de2issue_cancel,
    output [`HiCore_DE2ISSUE_SIZE-1:0] o_de2issue_info,
    // commit interface
    input  flush,
    // branch interface
    output branch,
    output [`HiCore_PC_SIZE-1:0] branch_pc,
    // regfile interface
    output [`HiCore_RFIDX_WIDTH-1:0]rs1_idx,
    output [`HiCore_RFIDX_WIDTH-1:0]rs2_idx,
    input  [`HiCore_REG_SIZE-1:0]   read_src1_dat,
    input  [`HiCore_REG_SIZE-1:0]   read_src2_dat,
    // rob interface
    output rs1_need,
    output rs2_need,
    output [`HiCore_RFIDX_WIDTH-1:0] rob_rs1_idx,
    output [`HiCore_RFIDX_WIDTH-1:0] rob_rs2_idx,
    output csr_need,
    output [`HiCore_CSRIDX_WIDTH-1:0] csr_idx,
    input  depend,
    input  empty, // for fence instruction
    input  full,

    output rob_wen,
    output rob_rd_need,
    output [`HiCore_RFIDX_WIDTH-1:0] rob_rd_idx,
    output rob_csr_need,
    output [`HiCore_CSRIDX_WIDTH-1:0] rob_csr_idx,
    output [`HiCore_PC_SIZE-1:0] rob_next_pc,
    output rob_fence_i_op,
    output rob_mret_op,
    input  [`HiCore_ROB_PTR_SIZE-1:0] rob_tail_ptr,
    // irq interface
    input m_ext_irq,
    input m_time_irq,
    input m_soft_irq,
    // system interface
    input  clk,
    input  rst_n
);

wire [`HiCore_PC_SIZE-1:0] if_pc;
wire [`HiCore_INT_SIZE-1:0] if_intr;
wire [`HiCore_EXCP_SIZE-1:0] if_excp;

assign if_excp = i_if2de_info[`HiCore_EXCP_SIZE-1:0];
assign if_pc = i_if2de_info[`HiCore_EXCP_SIZE + `HiCore_PC_SIZE -1:`HiCore_EXCP_SIZE];
assign if_intr = i_if2de_info[`HiCore_IF2DE_SIZE-1:`HiCore_EXCP_SIZE + `HiCore_PC_SIZE];

wire [6:0] opcode;
wire [`HiCore_RFIDX_WIDTH-1:0] rd_idx;
wire [4:0] shamt;

assign rd_idx  = if_intr[11:7];
assign opcode  = if_intr[6:0];
assign shamt   =  if_intr[24:20];

///////////////////////////////////////////////////////////////
// imm interface
///////////////////////////////////////////////////////////////
wire [`HiCore_REG_SIZE-1:0] t_imm_lui;
wire [`HiCore_REG_SIZE-1:0] t_imm_branch;
wire [`HiCore_REG_SIZE-1:0] t_imm_jal;
wire [`HiCore_REG_SIZE-1:0] t_imm_jalr;
wire [`HiCore_REG_SIZE-1:0] t_imm_load;
wire [`HiCore_REG_SIZE-1:0] t_imm_store;

assign t_imm_lui    = {if_intr[31:12],12'd0};
assign t_imm_branch = {{20{if_intr[31]}},if_intr[7],if_intr[30:25],if_intr[11:8],1'b0};
assign t_imm_jal    = {{12{if_intr[31]}},if_intr[19:12],if_intr[20],if_intr[30:21],1'b0};
assign t_imm_load   = {{21{if_intr[31]}},if_intr[30:20]};
assign t_imm_store  = {{21{if_intr[31]}},if_intr[30:25],if_intr[11:7]};
assign t_imm_jalr   = t_imm_load;

///////////////////////////////////////////////////////////////
// opcode decode
///////////////////////////////////////////////////////////////
wire load_op;
wire store_op;
wire fence_op;
wire jal_op;
wire jalr_op;
wire branch_op;
wire alu_op;
wire csr_op;
wire lui_op;
wire auipc_op;
wire ecall_op;
wire ebreak_op;
wire mret_op;
wire wfi_op;
wire rv32;

assign rv32 = (opcode[1:0]==2'b11);

assign load_op  = (opcode[6:2]==5'b00000) & rv32; // LB LH LW LBU LHU
assign store_op = (opcode[6:2]==5'b01000) & rv32; // SB SH SW
assign fence_op = (opcode[6:2]==5'b00011) & rv32; // fence fence.i
assign jal_op   = (opcode[6:2]==5'b11011) & rv32; // jal
assign jalr_op  = (opcode[6:2]==5'b11001) & rv32; // jalr
assign branch_op= (opcode[6:2]==5'b11000) & rv32; // beq bne blt bge bltu bgeu
assign alu_op   = (opcode[6:2]==5'b00100 | opcode[6:2]==5'b01100) & rv32; // addi slti sltiu xori ori andi slli srli srai add sub sll slt sltu xor srl sra or and
assign csr_op   = (opcode[6:2]==5'b11100) & rv32; // csr ecall ebreak uret sret mret
assign lui_op   = (opcode[6:2]==5'b01101) & rv32; // lui
assign auipc_op = (opcode[6:2]==5'b00101) & rv32; // auipc

wire rd_need;
wire illegal_intr;
wire [`HiCore_EXCP_SIZE-1:0] de_excp;
wire [`HiCore_IRQ_SIZE-1:0] de_irq;
assign rd_need = (~(branch_op | store_op | fence_op | ecall_op | ebreak_op | mret_op | wfi_op)) & (~i_if2de_cancel) & (~(|de_excp));
assign illegal_intr = ~(load_op | store_op | fence_op | jal_op | jalr_op | branch_op | alu_op | csr_op | lui_op | auipc_op);

///////////////////////////////////////////////////////////////
// dependency interface
///////////////////////////////////////////////////////////////

assign rs1_need= (~(lui_op | auipc_op | jal_op | fence_op | ecall_op | ebreak_op | (csr_op & if_intr[14]) | mret_op | wfi_op)) & (~i_if2de_cancel) & (~(|de_excp));
assign rs2_need= (branch_op | store_op | (alu_op & if_intr[5])) & (~i_if2de_cancel) & (~(|de_excp));
assign rs1_idx = if_intr[19:15];
assign rs2_idx = if_intr[24:20];
assign csr_need = csr_op & (|if_intr[14:12]) & (~i_if2de_cancel) & (~(|de_excp));
assign csr_idx = if_intr[`HiCore_INT_SIZE-1:`HiCore_INT_SIZE - `HiCore_CSRIDX_WIDTH];


assign de_excp = if_excp | {4'd0,ecall_op,7'd0,ebreak_op,illegal_intr,2'd0};
assign de_irq = {m_ext_irq,3'd0,m_time_irq,3'd0,m_soft_irq,3'd0};
///////////////////////////////////////////////////////////////
// branch info
///////////////////////////////////////////////////////////////
wire [2:0] branch_msg;
wire [`HiCore_DE2BJ_SIZE-1:0] branch_info;
wire [`HiCore_REG_SIZE-1:0] imm_bjp;
wire [`HiCore_REG_SIZE-1:0] rd_result;
wire branch_sel;
wire alu_sel;
wire agu_sel;
wire csr_sel;
wire nop_sel;
assign branch_sel = branch_op | jal_op | jalr_op;
assign branch_msg = if_intr[14:12];
assign imm_bjp = (branch_op)? t_imm_branch:
                 (jal_op)?    t_imm_jal: t_imm_jalr;
assign branch_info = {rd_need,rd_idx,rd_result,if_pc,de_irq,de_excp};
///////////////////////////////////////////////////////////////
// alu info
///////////////////////////////////////////////////////////////
wire [2:0] alu_msg;
wire [`HiCore_DE2ALU_SIZE-1:0] alu_info;
wire [`HiCore_REG_SIZE-1:0] imm_alu; 
wire [`HiCore_REG_SIZE-1:0] alu_src1;
wire [`HiCore_REG_SIZE-1:0] alu_src2;
wire alu_dir;
assign alu_src1 = (alu_op)? read_src1_dat:
                  (lui_op)? `HiCore_REG_SIZE'b0:if_pc;
assign alu_src2 = (alu_op & if_intr[5])? read_src2_dat:imm_alu;
assign imm_alu  = (~alu_op)? t_imm_lui:
                  (~if_intr[5] & (alu_msg==3'b001 | alu_msg==3'b101))? {27'd0,shamt}:t_imm_load;
assign alu_msg  = if_intr[14:12];
assign alu_dir  = (alu_op & (~if_intr[5]) & (alu_msg==3'b000))? 1'b0:if_intr[30];
assign alu_info = {alu_op,lui_op,auipc_op,alu_dir,alu_msg,rd_need,rd_idx,alu_src2,alu_src1,if_pc,de_irq,de_excp};
assign alu_sel = alu_op | lui_op | auipc_op;
///////////////////////////////////////////////////////////////
// agu info
///////////////////////////////////////////////////////////////
wire [2:0] agu_msg;
wire [`HiCore_DE2AGU_SIZE-1:0] agu_info;
wire [`HiCore_REG_SIZE-1:0] imm_agu;

assign agu_msg  = if_intr[14:12];
assign imm_agu  = (load_op)? t_imm_load:t_imm_store;
assign agu_info = {store_op,load_op,agu_msg,rd_need,rd_idx,read_src2_dat,read_src1_dat,imm_agu,if_pc,de_irq,de_excp};
assign agu_sel  = load_op | store_op;
///////////////////////////////////////////////////////////////
// csr info
///////////////////////////////////////////////////////////////
wire [2:0] csr_msg;
wire [`HiCore_REG_SIZE-1:0] imm_csr;
wire [`HiCore_DE2CSR_SIZE-1:0] csr_info;
wire [`HiCore_REG_SIZE-1:0] csr_reg_src;

assign csr_msg  = if_intr[14:12];
assign ecall_op = (csr_msg==3'b000) & (if_intr[31:20]==12'h000) & csr_op;
assign ebreak_op= (csr_msg==3'b000) & (if_intr[31:20]==12'h001) & csr_op;
assign mret_op  = (csr_msg==3'b000) & (if_intr[31:20]==12'h302) & csr_op;
assign wfi_op   = (csr_msg==3'b000) & (if_intr[31:20]==12'h105) & csr_op;
assign imm_csr = {27'd0,if_intr[19:15]};
assign csr_reg_src = (rs1_need)? read_src1_dat:imm_csr;
assign csr_info= {csr_msg,csr_idx,rd_need,rd_idx,csr_reg_src,if_pc,de_irq,de_excp};
assign csr_sel = csr_op & (~ecall_op) & (~ebreak_op) & (~mret_op) & (~wfi_op);
///////////////////////////////////////////////////////////////
// nop info
///////////////////////////////////////////////////////////////
wire fence_i_op;
wire [`HiCore_DE2NOP_SIZE-1:0] nop_info;
assign fence_i_op = fence_op & if_intr[12];
assign nop_sel = fence_op | ecall_op | ebreak_op | mret_op | wfi_op | illegal_intr;
assign nop_info = {fence_i_op,mret_op,rd_need,if_pc,de_irq,de_excp};  
///////////////////////////////////////////////////////////////
// de2issue interface
///////////////////////////////////////////////////////////////
wire [`HiCore_DE2ISSUE_PRE_SIZE-1:0] i_de2issue_info_pre;
wire [`HiCore_DE2ISSUE_SIZE-1:0] i_de2issue_info;
wire i_de2issue_valid;
wire i_de2issue_ready;
wire dep;
assign dep = depend | ((fence_op & (~fence_i_op)) & (~empty)) | full;

assign i_de2issue_info_pre = ({`HiCore_DE2ISSUE_PRE_SIZE{branch_sel}} & {{(`HiCore_DE2ISSUE_PRE_SIZE-`HiCore_DE2BJ_SIZE){1'b0}} ,branch_info}) |
                            ({`HiCore_DE2ISSUE_PRE_SIZE{alu_sel}}     & {{(`HiCore_DE2ISSUE_PRE_SIZE-`HiCore_DE2ALU_SIZE){1'b0}},alu_info})    |
                            ({`HiCore_DE2ISSUE_PRE_SIZE{agu_sel}}     & {{(`HiCore_DE2ISSUE_PRE_SIZE-`HiCore_DE2AGU_SIZE){1'b0}},agu_info})    |
                            ({`HiCore_DE2ISSUE_PRE_SIZE{csr_sel}}     & {{(`HiCore_DE2ISSUE_PRE_SIZE-`HiCore_DE2CSR_SIZE){1'b0}},csr_info})    |
                            ({`HiCore_DE2ISSUE_PRE_SIZE{nop_sel}}     & {{(`HiCore_DE2ISSUE_PRE_SIZE-`HiCore_DE2NOP_SIZE){1'b0}},nop_info});
assign i_de2issue_info = {branch_sel,alu_sel,agu_sel,csr_sel,nop_sel,rob_tail_ptr,i_de2issue_info_pre};
assign i_de2issue_valid= i_if2de_valid & (~dep);
assign i_if2de_ready= i_de2issue_ready & i_de2issue_valid;

HiCore_pipe # (
  .CUT_READY(0),
  .DW(`HiCore_DE2ISSUE_SIZE)
) de2ex_pipe(
  .i_vld(i_de2issue_valid), 
  .i_rdy(i_de2issue_ready), 
  .i_dat(i_de2issue_info),
  .i_cancel(i_if2de_cancel),
  .o_vld(o_de2issue_valid), 
  .o_rdy(o_de2issue_ready), 
  .o_dat(o_de2issue_info),
  .o_cancel(o_de2issue_cancel),

  .branch(flush),

  .clk(clk),
  .rst_n(rst_n)
);
///////////////////////////////////////////////////////////////
// rob interface
///////////////////////////////////////////////////////////////
assign rob_wen = i_de2issue_valid & i_de2issue_ready & (~i_if2de_cancel) & (~flush);
assign rob_rd_need = rd_need;
assign rob_rd_idx = rd_idx;
assign rob_csr_need =  csr_sel;
assign rob_csr_idx = csr_idx;
assign rob_fence_i_op = nop_sel & fence_i_op;
assign rob_mret_op = nop_sel & mret_op;
assign rob_rs1_idx = rs1_idx;
assign rob_rs2_idx = rs2_idx;
////////////////////////////////////////////////
// branch module
///////////////////////////////////////////////
wire branch_en = i_de2issue_valid & i_de2issue_ready & 
                 (~i_if2de_cancel) & (~(|de_excp)) & branch_sel;
HiCore_branch u_HiCore_branch(
.if_pc(if_pc),
.imm_bjp(imm_bjp),
.read_src1_dat(read_src1_dat),
.read_src2_dat(read_src2_dat),
.branch_msg(branch_msg),
.jalr_op(jalr_op),
.jal_op(jal_op),
.branch_op(branch_op),
.branch_en(branch_en),

.branch(branch),
.branch_pc(branch_pc),
.next_pc(rob_next_pc),
.rd_result(rd_result)
);

endmodule
