module HiCore_agu(
    // disp interface
    input  i_issue2agu_valid,
    output i_issue2agu_ready,
    input  i_issue2agu_cancel,
    input  [`HiCore_REG_SIZE-1:0] agu_src1,
    input  [`HiCore_REG_SIZE-1:0] agu_src2,
    input  [`HiCore_REG_SIZE-1:0] agu_src3,
    input  [2:0] agu_msg,
    input  load_op,
    input  store_op,
    input  [`HiCore_ISSUE2ALU_SIZE-1:0] i_issue2agu_info,
    // lsu interface
    output o_agu2lsu_valid,
    input  o_agu2lsu_ready,
    output o_agu2lsu_cancel,
    output o_agu2lsu_read,
    output o_agu2lsu_unsigned,
    output o_agu2lsu_word_access,
    output o_agu2lsu_short_access,
    output o_agu2lsu_byte_access,
    output [`HiCore_ADDR_SIZE-1:0]  o_agu2lsu_addr,
    output [`HiCore_REG_SIZE-1:0]   o_agu2lsu_wdata,
    output [`HiCore_REG_SIZE/8-1:0] o_agu2lsu_wmask,
    output [`HiCore_ISSUE2ALU_SIZE-1:0] o_agu2lsu_info,
    // rob interface
    input  [`HiCore_ROB_PTR_SIZE-1:0] lsu_head_ptr,
    // commit interface
    input  flush,
    // system interface
    input clk,
    input rst_n
);

wire [`HiCore_EXCP_SIZE-1:0] agu_excp;
wire [`HiCore_IRQ_SIZE-1:0] agu_irq;
wire [`HiCore_PC_SIZE-1:0] agu_pc;
wire [`HiCore_ROB_PTR_SIZE-1:0] agu_rob_ptr;
assign {agu_rob_ptr,agu_pc,agu_irq,agu_excp} = i_issue2agu_info;

wire word_access;
wire short_access;
wire byte_access;
wire word_err;
wire short_err;
wire mem_addr_err; 
assign word_access  = (agu_msg[1:0] == 2'b10);
assign short_access = (agu_msg[1:0] == 2'b01);
assign byte_access  = (agu_msg[1:0] == 2'b00);
assign word_err     = word_access  & (|o_agu2lsu_addr[1:0]);
assign short_err    = short_access & (o_agu2lsu_addr[0]);
assign mem_addr_err     = word_err | short_err;

//////////////////////////////////////////////////////
// agu2lsu pipe
//////////////////////////////////////////////////////
wire i_agu2lsu_valid;
wire i_agu2lsu_ready;
wire i_agu2lsu_read;
wire i_agu2lsu_unsigned;
wire [`HiCore_ADDR_SIZE-1:0] i_agu2lsu_addr;
wire [`HiCore_REG_SIZE/8-1:0] i_agu2lsu_wmask;
wire [`HiCore_REG_SIZE-1:0] i_agu2lsu_wdata;
wire [`HiCore_EXCP_SIZE-1:0] i_agu2lsu_excp;
wire [`HiCore_AGUINFO_SIZE-1:0] i_agu2lsu_info;
wire [`HiCore_AGUINFO_SIZE-1:0] agu2lsu_info;

assign i_agu2lsu_valid = i_issue2agu_valid & (load_op | (store_op & (lsu_head_ptr==agu_rob_ptr)));
assign i_agu2lsu_read = load_op;
assign i_agu2lsu_addr = agu_src1 + agu_src2;
assign i_agu2lsu_wdata = 
        ({`HiCore_REG_SIZE{byte_access}}   & {4{agu_src3[7:0]}})  |
        ({`HiCore_REG_SIZE{short_access}} & {2{agu_src3[15:0]}}) |
        ({`HiCore_REG_SIZE{word_access}}   & agu_src3);
assign i_agu2lsu_wmask = 
        ({`HiCore_REG_SIZE/8{byte_access}}  & (4'b0001 << i_agu2lsu_addr[1:0])) |
        ({`HiCore_REG_SIZE/8{short_access}} & (4'b0011 << {i_agu2lsu_addr[1],1'b0})) |
        ({`HiCore_REG_SIZE/8{word_access}}  & (4'b1111));
assign i_agu2lsu_unsigned = load_op & agu_msg[2];
assign i_agu2lsu_excp = agu_excp | {9'd0,(mem_addr_err & store_op),1'b0,(mem_addr_err & load_op),4'd0};
assign i_agu2lsu_info = {word_access,short_access,byte_access,
                         i_agu2lsu_read,i_agu2lsu_unsigned,
                         i_agu2lsu_addr,i_agu2lsu_wmask,i_agu2lsu_wdata,
                         agu_rob_ptr,agu_pc,agu_irq,i_agu2lsu_excp};
HiCore_pipe # (
  .CUT_READY(0),
  .DW(`HiCore_AGUINFO_SIZE)
) agu2lsu_pipe(
  .i_vld(i_agu2lsu_valid), 
  .i_rdy(i_agu2lsu_ready), 
  .i_dat(i_agu2lsu_info),
  .i_cancel(i_issue2agu_cancel),
  .o_vld(o_agu2lsu_valid), 
  .o_rdy(o_agu2lsu_ready), 
  .o_dat(agu2lsu_info),
  .o_cancel(o_agu2lsu_cancel),

  .branch(flush),

  .clk(clk),
  .rst_n(rst_n)
);
assign {o_agu2lsu_word_access,
        o_agu2lsu_short_access,
        o_agu2lsu_byte_access,
        o_agu2lsu_read,o_agu2lsu_unsigned,
        o_agu2lsu_addr,o_agu2lsu_wmask,
        o_agu2lsu_wdata,o_agu2lsu_info} = agu2lsu_info;

// issue2agu interface
assign i_issue2agu_ready = i_agu2lsu_valid & i_agu2lsu_ready;

endmodule