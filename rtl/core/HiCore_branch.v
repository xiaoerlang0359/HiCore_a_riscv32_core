`include "config.v"

module HiCore_branch(
    // disp interface
    input  [`HiCore_PC_SIZE-1:0]   if_pc,
    input  [`HiCore_REG_SIZE-1:0]  imm_bjp,
    input  [`HiCore_REG_SIZE-1:0]  read_src1_dat,
    input  [`HiCore_REG_SIZE-1:0]  read_src2_dat,
    input  [2:0]                   branch_msg,
    input                          jalr_op,
    input                          jal_op,
    input                          branch_op,
    input                          branch_en,
    
    output                         branch,
    output [`HiCore_PC_SIZE-1:0]   branch_pc,
    output [`HiCore_PC_SIZE-1:0]   next_pc,
    output [`HiCore_REG_SIZE-1:0]  rd_result
);
//////////////////////////////////////////////////
// generate branch pc
//////////////////////////////////////////////////
wire [`HiCore_REG_SIZE-1:0] branch_src1;
wire [`HiCore_REG_SIZE-1:0] branch_src2;
assign branch_src1 = imm_bjp;
assign branch_src2 = (~jalr_op)? if_pc:read_src1_dat;
assign branch_pc = branch_src1 + branch_src2;

wire [`HiCore_REG_SIZE-1:0] data_src1_pre;
wire [`HiCore_REG_SIZE-1:0] data_src2_pre;
assign data_src1_pre = (branch_op)? read_src1_dat:if_pc;
assign data_src2_pre = (branch_op)? read_src2_dat:4;
wire [`HiCore_REG_SIZE:0] data_src1;
wire [`HiCore_REG_SIZE:0] data_src2;
wire unsigned_op;
assign unsigned_op =(~branch_op) | (branch_op & branch_msg[1]);
assign data_src1 = {~unsigned_op & data_src1_pre[`HiCore_REG_SIZE-1],data_src1_pre};
assign data_src2 = {~unsigned_op & data_src2_pre[`HiCore_REG_SIZE-1],data_src2_pre};
wire [`HiCore_REG_SIZE:0] data_op1;
wire [`HiCore_REG_SIZE:0] data_op2;
wire cin;
assign data_op1 = data_src1;
assign data_op2 = (branch_op)? ~data_src2:data_src2; 
assign cin = branch_op;

wire beq_op;
wire bne_op;
wire blt_op;
wire bge_op;
wire bltu_op;
wire bgeu_op;

assign beq_op = branch_op & (branch_msg==3'b000);
assign bne_op = branch_op & (branch_msg==3'b001);
assign blt_op = branch_op & (branch_msg==3'b100);
assign bge_op = branch_op & (branch_msg==3'b101);
assign bltu_op= branch_op & (branch_msg==3'b110);
assign bgeu_op= branch_op & (branch_msg==3'b111);

wire [`HiCore_REG_SIZE:0] add_res;
assign add_res = data_op1+data_op2+cin;
assign rd_result = add_res[`HiCore_REG_SIZE-1:0];

wire beq_res;
wire bne_res;
wire blt_res;
wire bge_res;
wire bltu_res;
wire bgeu_res;
wire branch_res;

assign beq_res = beq_op  & (add_res == {(`HiCore_REG_SIZE+1){1'b0}});
assign bne_res = bne_op  & (~(add_res == {(`HiCore_REG_SIZE+1){1'b0}}));
assign blt_res = blt_op  & add_res[`HiCore_REG_SIZE];
assign bge_res = bge_op  & (~add_res[`HiCore_REG_SIZE]);
assign bltu_res= bltu_op & add_res[`HiCore_REG_SIZE];
assign bgeu_res= bgeu_op & (~add_res[`HiCore_REG_SIZE]);
assign branch_res = beq_res | bne_res  | blt_res | 
                    bge_res | bltu_res | bgeu_res;

assign branch = branch_en & (jalr_op | jal_op | (branch_op & branch_res));
assign next_pc = (branch)? branch_pc:(if_pc + 32'd4);

endmodule
