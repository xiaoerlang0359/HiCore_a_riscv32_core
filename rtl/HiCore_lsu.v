module HiCore_lsu(
// agu interface
    input  i_agu2lsu_valid,
    output i_agu2lsu_ready,
    input  i_agu2lsu_cancel,
    input  i_agu2lsu_read,
    input  i_agu2lsu_unsigned,
    input  i_agu2lsu_word_access,
    input  i_agu2lsu_short_access,
    input  i_agu2lsu_byte_access,
    input  [`HiCore_ADDR_SIZE-1:0]  i_agu2lsu_addr,
    input  [`HiCore_REG_SIZE-1:0]   i_agu2lsu_wdata,
    input  [`HiCore_REG_SIZE/8-1:0] i_agu2lsu_wmask,
    input  [`HiCore_ISSUE2ALU_SIZE-1:0] i_agu2lsu_info,
// icb interface
    output mem_icb_cmd_valid,
    input  mem_icb_cmd_ready,
    output mem_icb_cmd_read,
    output [`HiCore_ADDR_SIZE-1:0] mem_icb_cmd_addr,
    output [`HiCore_REG_SIZE-1:0] mem_icb_cmd_wdata,
    output [`HiCore_REG_SIZE/8-1:0] mem_icb_cmd_wmask,
    
    input  mem_icb_rsp_valid,
    output mem_icb_rsp_ready,
    input  mem_icb_rsp_err,
    input  [`HiCore_REG_SIZE-1:0] mem_icb_rsp_rdata,
// wb interface
    output lsu_wb_wen,
    output [`HiCore_ROB_PTR_SIZE-1:0] lsu_wb_ptr,
    output [`HiCore_REG_SIZE-1:0] lsu_wb_rd_data,
    output [`HiCore_WB_SIZE-1:0] lsu_wb_info,    
// commit interface
    input  flush,
// system interface
    input  clk,
    input  rst_n
);
////////////////////////////////////////////////////////
// decode i_agu2lsu_info
////////////////////////////////////////////////////////
wire [`HiCore_ROB_PTR_SIZE-1:0] agu2lsu_rob_ptr;
wire [`HiCore_PC_SIZE-1:0] agu2lsu_pc;
wire [`HiCore_IRQ_SIZE-1:0] agu2lsu_irq;
wire [`HiCore_EXCP_SIZE-1:0] agu2lsu_excp;
assign {agu2lsu_rob_ptr,agu2lsu_pc,
        agu2lsu_irq,agu2lsu_excp} = i_agu2lsu_info;
////////////////////////////////////////////////////////
// excp queue
////////////////////////////////////////////////////////
wire i_excp_queue_valid;
wire i_excp_queue_ready;
wire i_excp_queue_cancel;
wire [`HiCore_ISSUE2ALU_SIZE-1:0] i_excp_queue_info;
wire o_excp_queue_valid;
wire o_excp_queue_ready; // TODO: need to assign value
wire o_excp_queue_cancel;
wire [`HiCore_ISSUE2ALU_SIZE-1:0] o_excp_queue_info;
assign i_excp_queue_valid = i_agu2lsu_valid & (|agu2lsu_excp) & (~i_agu2lsu_cancel);
assign i_excp_queue_cancel = 1'b0;
assign i_excp_queue_info = i_agu2lsu_info;

HiCore_pipe # (
  .CUT_READY(0),
  .DW(`HiCore_ISSUE2ALU_SIZE)
) excp_queue_pipe(
  .i_vld(i_excp_queue_valid), 
  .i_rdy(i_excp_queue_ready), 
  .i_dat(i_excp_queue_info),
  .i_cancel(i_excp_queue_cancel),
  .o_vld(o_excp_queue_valid), 
  .o_rdy(o_excp_queue_ready), 
  .o_dat(o_excp_queue_info),
  .o_cancel(o_excp_queue_cancel),

  .branch(flush),

  .clk(clk),
  .rst_n(rst_n)
);
////////////////////////////////////////////////////
// mem queue 
////////////////////////////////////////////////////
// TODO: need to add a bypass function
wire i_mem_queue_valid;
wire i_mem_queue_ready;
wire i_mem_fifo_rdy;
wire i_mem_queue_cancel;
wire [`HiCore_LSU_SIZE-1:0] i_mem_queue_info;
wire o_mem_queue_valid;
wire o_mem_queue_ready; // TODO: need to assign value
wire o_mem_queue_cancel;
wire [`HiCore_LSU_SIZE-1:0] o_mem_queue_info;
assign i_mem_queue_valid = i_agu2lsu_valid & (~(|agu2lsu_excp)) & (~i_agu2lsu_cancel) & i_mem_fifo_rdy;
assign i_mem_queue_cancel = 1'b0;
assign i_mem_queue_info = {i_agu2lsu_word_access,i_agu2lsu_short_access,i_agu2lsu_byte_access,
                           i_agu2lsu_addr[1:0],i_agu2lsu_read,i_agu2lsu_unsigned,i_agu2lsu_info};
HiCore_queue#(
    .DW(`HiCore_LSU_SIZE),
    .DP(4),
    .LOGDP(2)
)uHiCore_queue(
    .i_valid(i_mem_queue_valid),
    .i_ready(i_mem_queue_ready),
    .i_cancel(i_mem_queue_cancel),
    .i_info(i_mem_queue_info),
    .o_valid(o_mem_queue_valid),
    .o_ready(o_mem_queue_ready),
    .o_cancel(o_mem_queue_cancel),
    .o_info(o_mem_queue_info),

    .flush(flush),

    .clk(clk),
    .rst_n(rst_n)
);
//////////////////////////////////////////////////////
// icb interface
//////////////////////////////////////////////////////
wire i_mem_fifo_vld;
wire [`HiCore_ICB_CMD_SIZE-1:0] i_mem_fifo_wdat;
wire o_mem_fifo_vld;
wire o_mem_fifo_rdy;
wire [`HiCore_ICB_CMD_SIZE-1:0] o_mem_fifo_rdat;
assign i_mem_fifo_vld = i_agu2lsu_valid & (~(|agu2lsu_excp)) & (~i_agu2lsu_cancel) & i_mem_queue_ready;
assign o_mem_fifo_rdy = mem_icb_cmd_ready;
assign i_mem_fifo_wdat = {i_agu2lsu_read,i_agu2lsu_wmask,i_agu2lsu_wdata,i_agu2lsu_addr};
sirv_bypbuf #(
.DP(4),
.DW(`HiCore_ICB_CMD_SIZE)
)mem_bypbuf(
.i_vld(i_mem_fifo_vld),
.i_rdy(i_mem_fifo_rdy),
.i_dat(i_mem_fifo_wdat),
.i_cancel(1'b0),

.o_vld(o_mem_fifo_vld),
.o_rdy(o_mem_fifo_rdy),
.o_dat(o_mem_fifo_rdat),
.o_cancel(),

.flush(1'b0),
.clk(clk),
.rst_n(rst_n)
);
assign mem_icb_cmd_valid = o_mem_fifo_vld;
assign {mem_icb_cmd_read,mem_icb_cmd_wmask,mem_icb_cmd_wdata,mem_icb_cmd_addr} = o_mem_fifo_rdat;
assign mem_icb_rsp_ready = o_mem_queue_valid;
//////////////////////////////////////////////////////
// agu interface
//////////////////////////////////////////////////////
assign i_agu2lsu_ready =(i_agu2lsu_cancel)? 1'b1: 
                        (|agu2lsu_excp)? i_excp_queue_ready: (i_mem_queue_ready & i_mem_fifo_rdy);
//////////////////////////////////////////////////////
// write back arbiter
// NOTE: dead lock
//////////////////////////////////////////////////////
wire arbt_src = mem_icb_rsp_valid;
assign o_mem_queue_ready = mem_icb_rsp_valid;
assign o_excp_queue_ready = ~mem_icb_rsp_valid;
//////////////////////////////////////////////////////
// write back interface
//////////////////////////////////////////////////////
wire lsu_unsigned;
wire lsu_load_op;
wire lsu_word_access;
wire lsu_short_access;
wire lsu_byte_access;
wire lsu_lbu;
wire lsu_lb;
wire lsu_lhu;
wire lsu_lh;
wire lsu_lw;
wire [1:0] lsu_addr;
wire [`HiCore_REG_SIZE-1:0] lsu_rsp_rdata_algn;
assign lsu_wb_wen = (mem_icb_rsp_valid & mem_icb_rsp_ready & (~o_mem_queue_cancel)) |
                    (o_excp_queue_valid & o_excp_queue_ready & (~o_excp_queue_cancel));
assign lsu_wb_ptr = (arbt_src)? o_mem_queue_info[`HiCore_ISSUE2ALU_SIZE-1:`HiCore_ISSUE2ALU_SIZE-`HiCore_ROB_PTR_SIZE]:
                                o_excp_queue_info[`HiCore_ISSUE2ALU_SIZE-1:`HiCore_ISSUE2ALU_SIZE-`HiCore_ROB_PTR_SIZE];
assign lsu_wb_info = (arbt_src)? (o_mem_queue_info[`HiCore_WB_SIZE-1:0] | {{`HiCore_WB_SIZE-8{1'b0}},(mem_icb_rsp_err & (~lsu_load_op)),1'b0,(mem_icb_rsp_err & lsu_load_op),5'd0}):
                                 o_excp_queue_info[`HiCore_WB_SIZE-1:0];
assign {lsu_word_access,lsu_short_access,lsu_byte_access,
        lsu_addr,lsu_load_op,lsu_unsigned} = o_mem_queue_info[`HiCore_LSU_SIZE-1:`HiCore_ISSUE2ALU_SIZE];
assign lsu_lbu = lsu_byte_access & lsu_unsigned;
assign lsu_lb = lsu_byte_access & (~lsu_unsigned);
assign lsu_lhu = lsu_short_access & lsu_unsigned;
assign lsu_lh = lsu_short_access & (~lsu_unsigned);
assign lsu_lw = lsu_word_access;
assign lsu_rsp_rdata_algn = mem_icb_rsp_rdata >> {lsu_addr,3'd0};
assign lsu_wb_rd_data = ({`HiCore_REG_SIZE{lsu_lbu}} & {{24{1'b0}},lsu_rsp_rdata_algn[7:0]}) |
                        ({`HiCore_REG_SIZE{lsu_lb}}  & {{24{lsu_rsp_rdata_algn[7]}},lsu_rsp_rdata_algn[7:0]}) |
                        ({`HiCore_REG_SIZE{lsu_lhu}} & {{16{1'b0}},lsu_rsp_rdata_algn[15:0]}) |
                        ({`HiCore_REG_SIZE{lsu_lh}} & {{16{lsu_rsp_rdata_algn[15]}},lsu_rsp_rdata_algn[15:0]}) |
                        ({`HiCore_REG_SIZE{lsu_lw}}) & lsu_rsp_rdata_algn;

endmodule
