module HiCore_alu(
    // disp interface
    input  i_issue2alu_valid,
    output i_issue2alu_ready,
    input  i_issue2alu_cancel,
    input  [`HiCore_REG_SIZE-1:0] alu_src1,
    input  [`HiCore_REG_SIZE-1:0] alu_src2,
    input  [2:0] alu_msg,
    input  alu_dir,
    input  auipc_op,
    input  lui_op,
    input  alu_op,
    input  [`HiCore_ISSUE2ALU_SIZE-1:0] alu_info,
    // wb interface
    output rob_wb_wen,
    output [`HiCore_ROB_PTR_SIZE-1:0] rob_wb_ptr,
    output [`HiCore_REG_SIZE-1:0] rob_wb_rd_data,
    output [`HiCore_WB_SIZE-1:0] rob_wb_info,
    // commit interface
    input  flush,
    // system interface
    input clk,
    input rst_n
);
/////////////////////////////////////////////////////////////
// generate alu result
/////////////////////////////////////////////////////////////
wire add_op;
wire sll_op;
wire slt_op;
wire sltu_op;
wire xor_op;
wire srl_op;
wire or_op;
wire and_op;

assign add_op = (alu_msg == 3'b000) | lui_op | auipc_op;
assign sll_op = (alu_msg == 3'b001) & alu_op;
assign slt_op = (alu_msg == 3'b010) & alu_op;
assign sltu_op= (alu_msg == 3'b011) & alu_op;
assign xor_op = (alu_msg == 3'b100) & alu_op;
assign srl_op = (alu_msg == 3'b101) & alu_op;
assign or_op  = (alu_msg == 3'b110) & alu_op;
assign and_op = (alu_msg == 3'b111) & alu_op;

wire is_sub;
wire [`HiCore_REG_SIZE:0] add_src1;
wire [`HiCore_REG_SIZE:0] add_src2;
wire [`HiCore_REG_SIZE:0] add_op1;
wire [`HiCore_REG_SIZE:0] add_op2;
wire cin;

assign is_sub   = ((alu_msg == 3'b000) & alu_dir & alu_op) | slt_op | sltu_op;
assign add_src1 = {~sltu_op & alu_src1[`HiCore_REG_SIZE-1], alu_src1};
assign add_src2 = {~sltu_op & alu_src2[`HiCore_REG_SIZE-1], alu_src2};
assign add_op1  = add_src1;
assign add_op2  = (is_sub)? ~add_src2 : add_src2;
assign cin      = is_sub;

wire [`HiCore_REG_SIZE-1:0] shifter_in1;
wire [`HiCore_REG_SIZE-1:0] shifter_res;
wire [`HiCore_REG_SIZE-1:0] srl_res_pre;
wire [4:0] shifter_in2; 
wire [`HiCore_REG_SIZE-1:0] shifter_mask;
assign shifter_in1 = (srl_op)? {alu_src1[0],alu_src1[1],alu_src1[2],alu_src1[3],
                                alu_src1[4],alu_src1[5],alu_src1[6],alu_src1[7],
                                alu_src1[8],alu_src1[9],alu_src1[10],alu_src1[11],
                                alu_src1[12],alu_src1[13],alu_src1[14],alu_src1[15],
                                alu_src1[16],alu_src1[17],alu_src1[18],alu_src1[19],
                                alu_src1[20],alu_src1[21],alu_src1[22],alu_src1[23],
                                alu_src1[24],alu_src1[25],alu_src1[26],alu_src1[27],
                                alu_src1[28],alu_src1[29],alu_src1[30],alu_src1[31]} :
                                alu_src1;
assign shifter_in2 = alu_src2[4:0];
assign shifter_res = (shifter_in1 << shifter_in2);
assign srl_res_pre = {shifter_res[0],shifter_res[1],shifter_res[2],shifter_res[3],
                     shifter_res[4],shifter_res[5],shifter_res[6],shifter_res[7],
                     shifter_res[8],shifter_res[9],shifter_res[10],shifter_res[11],
                     shifter_res[12],shifter_res[13],shifter_res[14],shifter_res[15],
                     shifter_res[16],shifter_res[17],shifter_res[18],shifter_res[19],
                     shifter_res[20],shifter_res[21],shifter_res[22],shifter_res[23],
                     shifter_res[24],shifter_res[25],shifter_res[26],shifter_res[27],
                     shifter_res[28],shifter_res[29],shifter_res[30],shifter_res[31]};
assign shifter_mask= ({`HiCore_REG_SIZE{1'b1}}) >> shifter_in2;

wire [`HiCore_REG_SIZE:0]   add_res;
wire [`HiCore_REG_SIZE-1:0] sll_res;
wire [`HiCore_REG_SIZE-1:0] xor_res;
wire [`HiCore_REG_SIZE-1:0] slt_res;
wire [`HiCore_REG_SIZE-1:0] srl_res;
wire [`HiCore_REG_SIZE-1:0] or_res;
wire [`HiCore_REG_SIZE-1:0] and_res;

assign add_res = add_op1 + add_op2 + cin;
assign xor_res = alu_src1 ^ alu_src2;
assign slt_res = {31'd0, add_res[`HiCore_REG_SIZE]};
assign sll_res = shifter_res;
assign or_res  = alu_src1 | alu_src2;
assign and_res = alu_src1 & alu_src2;
assign srl_res = srl_res_pre | ({`HiCore_REG_SIZE{alu_dir & alu_src1[`HiCore_REG_SIZE-1]}} & (~shifter_mask));

wire [`HiCore_REG_SIZE-1:0] alu_res_pre;
assign alu_res_pre = ({`HiCore_REG_SIZE{add_op}} & add_res) |
                     ({`HiCore_REG_SIZE{sll_op}} & sll_res) |
                     ({`HiCore_REG_SIZE{xor_op}} & xor_res) |
                     ({`HiCore_REG_SIZE{slt_op | sltu_op}} & slt_res) |
                     ({`HiCore_REG_SIZE{srl_op}} & srl_res) |
                     ({`HiCore_REG_SIZE{or_op}}  & or_res)  |
                     ({`HiCore_REG_SIZE{and_op}} & and_res);
/////////////////////////////////////////////////////////////
// pipe interface
/////////////////////////////////////////////////////////////
wire [`HiCore_ALU2WB_SIZE-1:0] i_alu2wb_info;
wire o_alu2wb_valid;
wire o_alu2wb_ready = 1'b1;
wire [`HiCore_ALU2WB_SIZE-1:0] o_alu2wb_info;
wire o_alu2wb_cancel;
assign i_alu2wb_info = {alu_res_pre,alu_info};

HiCore_pipe # (
  .CUT_READY(0),
  .DW(`HiCore_ALU2WB_SIZE)
) alu2wb_pipe(
  .i_vld(i_issue2alu_valid), 
  .i_rdy(i_issue2alu_ready), 
  .i_dat(i_alu2wb_info),
  .i_cancel(i_issue2alu_cancel),
  .o_vld(o_alu2wb_valid), 
  .o_rdy(o_alu2wb_ready), 
  .o_dat(o_alu2wb_info),
  .o_cancel(o_alu2wb_cancel),

  .branch(flush),

  .clk(clk),
  .rst_n(rst_n)
);
////////////////////////////////////////////////////////
// write back interface
////////////////////////////////////////////////////////
assign rob_wb_wen = o_alu2wb_valid & o_alu2wb_ready & (~o_alu2wb_cancel) & (~flush);
assign {rob_wb_rd_data,rob_wb_ptr,rob_wb_info} = o_alu2wb_info;

endmodule
