`include "config.v"
module HiCore_ifetch(
    // interface of icache icb
    output icache_icb_cmd_valid,
    input  icache_icb_cmd_ready,
    output icache_icb_cmd_read,
    output [`HiCore_ADDR_SIZE-1:0] icache_icb_cmd_addr,
    output [`HiCore_REG_SIZE-1:0]   icache_icb_cmd_wdata,
    output [`HiCore_REG_SIZE/8-1:0] icache_icb_cmd_wmask,

    output icache_icb_rsp_ready,
    input  icache_icb_rsp_valid,
    input  [`HiCore_REG_SIZE-1:0]  icache_icb_rsp_rdata,
    input  icache_icb_rsp_err,
    // interface of pipe to decoder
    output o_if2de_valid,
    input  o_if2de_ready,
    output [`HiCore_IF2DE_SIZE-1:0] o_if2de_info,
    output o_if2de_cancel,
    // interface of commit
    input  [`HiCore_PC_SIZE-1:0] branch_pc,
    input  branch,
    input  flush,
    input [`HiCore_PC_SIZE-1:0] flush_pc,
    // interface of system
    input  clk,
    input  rst_n
);
// deal with pc
wire [`HiCore_PC_SIZE-1:0] pc;
wire [`HiCore_PC_SIZE-1:0] pc_next;
wire pc_ena;
wire i_excp_queue_valid;
wire i_excp_queue_ready;

assign pc_ena = ((icache_icb_cmd_valid & icache_icb_cmd_ready) | 
                 (i_excp_queue_valid & i_excp_queue_ready)) | branch | flush;
assign pc_next = (flush)? flush_pc:
                 (branch)? branch_pc:(pc+4);

gnrl_dfflr #(`HiCore_PC_SIZE) pc_dfflr(.lden(pc_ena),.dnxt(pc_next),.qout(pc),.clk(clk),.rst_n(rst_n));
//////////////////////////////////////////////
// excp interface
//////////////////////////////////////////////
wire [15:0] excp_code;
assign excp_code[0] = (|pc[1:0]);
assign excp_code[1] = (pc[`HiCore_IADDR_REGION]!=`HiCore_IADDR_COMP);
assign excp_code[15:2] = 14'd0;

wire i_excp_queue_cancel;
wire [`HiCore_ADDR_SIZE+15:0] i_excp_queue_info;
wire o_excp_queue_valid;
wire o_excp_queue_ready;
wire o_excp_queue_cancel;
wire [`HiCore_ADDR_SIZE+15:0] o_excp_queue_info;
assign i_excp_queue_valid = (~branch) & (~flush) & ((excp_code[0]) | (excp_code[1]));
assign i_excp_queue_cancel = 1'b0;
assign i_excp_queue_info = {pc,excp_code};

HiCore_pipe #(
  .CUT_READY(0),
  .DW(`HiCore_ADDR_SIZE+16)
) icache_excp_pipe(
  .i_vld(i_excp_queue_valid),
  .i_rdy(i_excp_queue_ready),
  .i_dat(i_excp_queue_info),
  .i_cancel(i_excp_queue_cancel),
  .o_vld(o_excp_queue_valid),
  .o_rdy(o_excp_queue_ready),
  .o_dat(o_excp_queue_info),
  .o_cancel(o_excp_queue_cancel),

  .branch(flush|branch),

  .clk(clk),
  .rst_n(rst_n)
);
//////////////////////////////////////////////
// itcm interface
//////////////////////////////////////////////
wire fifo_half_full;
wire i_mem_queue_ready;
assign icache_icb_cmd_valid = (~branch) & (~flush) & (~excp_code[0]) & (~excp_code[1]) & i_mem_queue_ready & (~fifo_half_full);
assign icache_icb_cmd_read = 1'b1;
assign icache_icb_cmd_addr = pc;
assign icache_icb_cmd_wdata = 0;
assign icache_icb_cmd_wmask = 0;
//////////////////////////////////////////////
// icache queue interface
//////////////////////////////////////////////
wire i_mem_queue_valid;
wire i_mem_queue_cancel;
wire [`HiCore_ADDR_SIZE+15:0] i_mem_queue_info;
wire o_mem_queue_valid;
wire o_mem_queue_ready;
wire o_mem_queue_cancel;
wire [`HiCore_ADDR_SIZE+15:0] o_mem_queue_info;
assign i_mem_queue_valid = (~branch) & (~flush) & (~excp_code[0]) & (~excp_code[1]) & icache_icb_cmd_ready & (~fifo_half_full);
assign i_mem_queue_cancel = 1'b0;
assign i_mem_queue_info = {pc,excp_code};

HiCore_queue#(
  .DW(`HiCore_ADDR_SIZE+16),
  .DP(4),
  .LOGDP(2)
)icache_HiCore_queue(
  .i_valid(i_mem_queue_valid),
  .i_ready(i_mem_queue_ready),
  .i_cancel(i_mem_queue_cancel),
  .i_info(i_mem_queue_info),
  .o_valid(o_mem_queue_valid),
  .o_ready(o_mem_queue_ready),
  .o_cancel(o_mem_queue_cancel),
  .o_info(o_mem_queue_info),

  .flush(flush|branch),
  .clk(clk),
  .rst_n(rst_n)
);
wire arbt_src = icache_icb_rsp_valid;
wire i_if2de_ready;
assign o_mem_queue_ready = icache_icb_rsp_valid & i_if2de_ready;
assign o_excp_queue_ready = (~icache_icb_rsp_valid) & i_if2de_ready;
assign icache_icb_rsp_ready = o_mem_queue_valid & i_if2de_ready;
////////////////////////////////////////////////////
// decode interface
////////////////////////////////////////////////////
wire i_if2de_valid;
wire [`HiCore_IF2DE_SIZE-1:0] i_if2de_info;
wire i_if2de_cancel;
assign i_if2de_valid = (icache_icb_rsp_valid & o_mem_queue_valid) | o_excp_queue_valid;
assign i_if2de_info = (arbt_src)? {icache_icb_rsp_rdata,o_mem_queue_info} | {64'd0,14'd0,icache_icb_rsp_err,1'b0}:
                                  {32'd0,o_excp_queue_info};
assign i_if2de_cancel = (arbt_src)? o_mem_queue_cancel:
                                    o_excp_queue_cancel;

sirv_bypbuf #(
.DP(8),
.DW(`HiCore_IF2DE_SIZE)
)mem_bypbuf(
.i_vld(i_if2de_valid),
.i_rdy(i_if2de_ready),
.i_dat(i_if2de_info),
.i_cancel(i_if2de_cancel),

.o_vld(o_if2de_valid),
.o_rdy(o_if2de_ready),
.o_dat(o_if2de_info),
.o_cancel(o_if2de_cancel),
.fifo_half_full(fifo_half_full),

.flush(flush|branch),
.clk(clk),
.rst_n(rst_n)
);

endmodule
