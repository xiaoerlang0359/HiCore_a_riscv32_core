`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/11 15:47:34
// Design Name: 
// Module Name: alu_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module HiCore_cpu( 
    input m_ext_irq,
    input m_time_irq,
    input m_soft_irq,
    input clk,
    input rst_n,
    output flush,
    output branch
    );
wire if2icache_icb_cmd_valid;
wire if2icache_icb_cmd_ready;
wire if2icache_icb_cmd_read;
wire [`HiCore_ADDR_SIZE-1:0] if2icache_icb_cmd_addr;
wire [`HiCore_REG_SIZE-1:0]  if2icache_icb_cmd_wdata;
wire [`HiCore_REG_SIZE/8-1:0]if2icache_icb_cmd_wmask;

wire if2icache_icb_rsp_ready;
wire if2icache_icb_rsp_valid;
wire [`HiCore_REG_SIZE-1:0] if2icache_icb_rsp_rdata;
wire if2icache_icb_rsp_err;
wire if2de_valid;
wire if2de_ready;
wire [`HiCore_IF2DE_SIZE-1:0] if2de_info;
wire if2de_cancel;
wire [`HiCore_PC_SIZE-1:0] branch_pc;
wire [`HiCore_PC_SIZE-1:0] flush_pc;

HiCore_ifetch u_HiCore_ifetch(
    // interface of icache icb
.icache_icb_cmd_valid(if2icache_icb_cmd_valid),
.icache_icb_cmd_ready(if2icache_icb_cmd_ready),
.icache_icb_cmd_read(if2icache_icb_cmd_read),
.icache_icb_cmd_addr(if2icache_icb_cmd_addr),
.icache_icb_cmd_wdata(if2icache_icb_cmd_wdata),
.icache_icb_cmd_wmask(if2icache_icb_cmd_wmask),

.icache_icb_rsp_ready(if2icache_icb_rsp_ready),
.icache_icb_rsp_valid(if2icache_icb_rsp_valid),
.icache_icb_rsp_rdata(if2icache_icb_rsp_rdata),
.icache_icb_rsp_err(if2icache_icb_rsp_err),
    // interface of pipe to decoder
.o_if2de_valid(if2de_valid),
.o_if2de_ready(if2de_ready),
.o_if2de_info(if2de_info),
.o_if2de_cancel(if2de_cancel),
    // interface of commit
.branch_pc(branch_pc),
.branch(branch),
.flush(flush),
.flush_pc(flush_pc),
    // interface of system
.clk(clk),
.rst_n(rst_n)
);

wire icache_icb_cmd_valid;
wire icache_icb_cmd_ready;
wire icache_icb_cmd_read;
wire [`HiCore_ADDR_SIZE-1:0] icache_icb_cmd_addr;
wire [`HiCore_REG_SIZE-1:0] icache_icb_cmd_wdata;
wire [`HiCore_REG_SIZE/8-1:0] icache_icb_cmd_wmask;

wire icache_icb_rsp_valid;
wire icache_icb_rsp_ready;
wire icache_icb_rsp_err;
wire [`HiCore_REG_SIZE-1:0] icache_icb_rsp_rdata;
HiCore_dtcm_ctrl #(
    .DW(32),
    .RAM_DEPTH(12)
)u_ifetch_sram_ctrl(
// itcm interface
.mem_icb_cmd_valid(icache_icb_cmd_valid),
.mem_icb_cmd_ready(icache_icb_cmd_ready),
.mem_icb_cmd_read(icache_icb_cmd_read),
.mem_icb_cmd_addr(icache_icb_cmd_addr),
.mem_icb_cmd_wdata(icache_icb_cmd_wdata),
.mem_icb_cmd_wmask(icache_icb_cmd_wmask),

.mem_icb_rsp_ready(icache_icb_rsp_ready),
.mem_icb_rsp_valid(icache_icb_rsp_valid),
.mem_icb_rsp_rdata(icache_icb_rsp_rdata),
.mem_icb_rsp_err(icache_icb_rsp_err),
// system interface
.clk(clk),
.rst_n(rst_n)
);

wire de2issue_valid;
wire de2issue_ready;
wire de2issue_cancel;
wire [`HiCore_DE2ISSUE_SIZE-1:0] de2issue_info;
wire [`HiCore_RFIDX_WIDTH-1:0] rs1_idx;
wire [`HiCore_RFIDX_WIDTH-1:0] rs2_idx;
wire [`HiCore_REG_SIZE-1:0] read_src1_dat;
wire [`HiCore_REG_SIZE-1:0] read_src2_dat;
wire rs1_need;
wire rs2_need;
wire [`HiCore_RFIDX_WIDTH-1:0] rob_rs1_idx;
wire [`HiCore_RFIDX_WIDTH-1:0] rob_rs2_idx;
wire csr_need;
wire [`HiCore_CSRIDX_WIDTH-1:0] csr_idx;
wire depend;
wire empty;
wire full;
wire de2rob_wen;
wire de2rob_rd_need;
wire [`HiCore_RFIDX_WIDTH-1:0] de2rob_rd_idx;
wire de2rob_csr_need;
wire [`HiCore_CSRIDX_WIDTH-1:0] de2rob_csr_idx;
wire de2rob_fence_i_op;
wire de2rob_mret_op;
wire [`HiCore_ROB_PTR_SIZE-1:0] de2rob_tail_ptr;
wire [`HiCore_PC_SIZE-1:0] de2rob_next_pc;

HiCore_Decode u_HiCore_Decode(
    // if2de pipe interface
.i_if2de_valid(if2de_valid),
.i_if2de_ready(if2de_ready),
.i_if2de_cancel(if2de_cancel),
.i_if2de_info(if2de_info),
    // de2issue pipe interface
.o_de2issue_valid(de2issue_valid),
.o_de2issue_ready(de2issue_ready),
.o_de2issue_cancel(de2issue_cancel),
.o_de2issue_info(de2issue_info),
    // commit interface
.flush(flush),
    // branch interface
.branch(branch),
.branch_pc(branch_pc),
    // regfile interface
.rs1_idx(rs1_idx),
.rs2_idx(rs2_idx),
.read_src1_dat(read_src1_dat),
.read_src2_dat(read_src2_dat),
    // rob interface
.rs1_need(rs1_need),
.rs2_need(rs2_need),
.rob_rs1_idx(rob_rs1_idx),
.rob_rs2_idx(rob_rs2_idx),
.csr_need(csr_need),
.csr_idx(csr_idx),
.depend(depend),
.empty(empty), // for fence instruction
.full(full),

.rob_wen(de2rob_wen),
.rob_rd_need(de2rob_rd_need),
.rob_rd_idx(de2rob_rd_idx),
.rob_csr_need(de2rob_csr_need),
.rob_csr_idx(de2rob_csr_idx),
.rob_fence_i_op(de2rob_fence_i_op),
.rob_mret_op(de2rob_mret_op),
.rob_next_pc(de2rob_next_pc),
.rob_tail_ptr(de2rob_tail_ptr),
    // irq interface
.m_ext_irq(m_ext_irq),
.m_time_irq(m_time_irq),
.m_soft_irq(m_soft_irq),
    // system interface
.clk(clk),
.rst_n(rst_n)
);

wire wbck_dest_wen;
wire [`HiCore_RFIDX_WIDTH-1:0] wbck_dest_idx;
wire [`HiCore_REG_SIZE-1:0] wbck_dest_dat;

Hicore_regfile u_HiCore_regfile( 
.read_src1_idx(rs1_idx),
.read_src2_idx(rs2_idx),
.read_src1_dat(read_src1_dat),
.read_src2_dat(read_src2_dat),

.wbck_dest_wen(wbck_dest_wen),
.wbck_dest_idx(wbck_dest_idx),
.wbck_dest_dat(wbck_dest_dat),

.clk(clk),
.rst_n(rst_n)
);

wire bjp_valid;
wire bjp_ready;
wire bjp_cancel;
wire [`HiCore_REG_SIZE-1:0] bjp_rd_result;
wire [`HiCore_ISSUE2ALU_SIZE-1:0] bjp_info;
wire alu_valid;
wire alu_ready;
wire alu_cancel;
wire [`HiCore_REG_SIZE-1:0] alu_src1;
wire [`HiCore_REG_SIZE-1:0] alu_src2;
wire [2:0] alu_msg;
wire alu_dir;
wire auipc_op;
wire lui_op;
wire alu_op;
wire [`HiCore_ISSUE2ALU_SIZE-1:0] alu_info;
wire nop_valid;
wire nop_ready;
wire nop_cancel;
wire mret_op;
wire fence_i_op;
wire [`HiCore_ISSUE2ALU_SIZE-1:0] nop_info;
wire csr_valid;
wire csr_ready;
wire csr_cancel;
wire [`HiCore_REG_SIZE-1:0] csr_reg_src;
wire [`HiCore_CSRIDX_WIDTH-1:0] issue2csr_csr_idx;
wire [2:0] csr_msg;
wire [`HiCore_ISSUE2ALU_SIZE-1:0] csr_info;
wire agu_valid;
wire agu_ready;
wire agu_cancel;
wire [`HiCore_REG_SIZE-1:0] agu_src1;
wire [`HiCore_REG_SIZE-1:0] agu_src2;
wire [`HiCore_REG_SIZE-1:0] agu_src3;
wire [2:0] agu_msg;
wire load_op;
wire store_op;
wire [`HiCore_ISSUE2ALU_SIZE-1:0] agu_info;

HiCore_Issue u_HiCore_Issue(
    // de2issue pipe interface
.i_de2issue_valid(de2issue_valid),
.i_de2issue_ready(de2issue_ready),
.i_de2issue_cancel(de2issue_cancel),
.i_de2issue_info(de2issue_info),
    // issue2bjp interface
.bjp_valid(bjp_valid),
.bjp_ready(bjp_ready),
.bjp_cancel(bjp_cancel),
.bjp_rd_result(bjp_rd_result),
.bjp_rd_need(),
.bjp_rd_idx(),
.bjp_info(bjp_info),
    // issue2alu interface
.alu_valid(alu_valid),
.alu_ready(alu_ready),
.alu_cancel(alu_cancel),
.alu_src1(alu_src1),
.alu_src2(alu_src2),
.alu_rd_need(),
.alu_rd_idx(),
.alu_msg(alu_msg),
.alu_dir(alu_dir),
.auipc_op(auipc_op),
.lui_op(lui_op),
.alu_op(alu_op),
.alu_info(alu_info),
    // issue2agu interface
.agu_valid(agu_valid),
.agu_ready(agu_ready),
.agu_cancel(agu_cancel),
.agu_src1(agu_src1),
.agu_src2(agu_src2),
.agu_src3(agu_src3),
.agu_rd_need(),
.agu_rd_idx(),
.agu_msg(agu_msg),
.load_op(load_op),
.store_op(store_op),
.agu_info(agu_info),
    // issue2csr interface
.csr_valid(csr_valid),
.csr_ready(csr_ready),
.csr_cancel(csr_cancel),
.csr_reg_src(csr_reg_src),
.csr_rd_need(),
.csr_rd_idx(),
.csr_idx(issue2csr_csr_idx),
.csr_msg(csr_msg),
.csr_info(csr_info),
    // issue2nop interface
.nop_valid(nop_valid),
.nop_ready(nop_ready),
.nop_cancel(nop_cancel),
.mret_op(mret_op),
.fence_i_op(fence_i_op),
.nop_info(nop_info)
);

wire bjp2rob_wb_wen;
wire [`HiCore_ROB_PTR_SIZE-1:0] bjp2rob_wb_ptr;
wire [`HiCore_REG_SIZE-1:0] bjp2rob_wb_rd_data;
wire [`HiCore_WB_SIZE-1:0] bjp2rob_wb_info;
HiCore_bjp u_HiCore_bjp(
// issue interface
.i_issue2bjp_valid(bjp_valid),
.i_issue2bjp_ready(bjp_ready),
.i_issue2bjp_cancel(bjp_cancel),
.bjp_rd_result(bjp_rd_result),
.bjp_info(bjp_info),
// write back interface
.bjp_wb_wen(bjp2rob_wb_wen),
.bjp_wb_ptr(bjp2rob_wb_ptr),
.bjp_wb_rd_data(bjp2rob_wb_rd_data),
.bjp_wb_info(bjp2rob_wb_info), 
// flush interface
.flush(flush)
);

wire nop2rob_wb_wen;
wire [`HiCore_ROB_PTR_SIZE-1:0] nop2rob_wb_ptr;
wire [`HiCore_WB_SIZE-1:0] nop2rob_wb_info;
HiCore_nop u_HiCore_nop(
// issue interface
.i_issue2nop_valid(nop_valid),
.i_issue2nop_ready(nop_ready),
.i_issue2nop_cancel(nop_cancel),
.mret_op(mret_op),
.fence_i_op(fence_i_op),
.nop_info(nop_info),
// write back interface
.nop_wb_wen(nop2rob_wb_wen),
.nop_wb_ptr(nop2rob_wb_ptr),
.nop_wb_info(nop2rob_wb_info),
// flush
.flush(flush)
);

wire alu2rob_wb_wen;
wire [`HiCore_ROB_PTR_SIZE-1:0] alu2rob_wb_ptr;
wire [`HiCore_REG_SIZE-1:0] alu2rob_wb_rd_data;
wire [`HiCore_WB_SIZE-1:0] alu2rob_wb_info;
HiCore_alu u_HiCore_alu(
    // disp interface
.i_issue2alu_valid(alu_valid),
.i_issue2alu_ready(alu_ready),
.i_issue2alu_cancel(alu_cancel),
.alu_src1(alu_src1),
.alu_src2(alu_src2),
.alu_msg(alu_msg),
.alu_dir(alu_dir),
.auipc_op(auipc_op),
.lui_op(lui_op),
.alu_op(alu_op),
.alu_info(alu_info),
    // wb interface
.rob_wb_wen(alu2rob_wb_wen),
.rob_wb_ptr(alu2rob_wb_ptr),
.rob_wb_rd_data(alu2rob_wb_rd_data),
.rob_wb_info(alu2rob_wb_info),
    // commit interface
.flush(flush),
    // system interface
.clk(clk),
.rst_n(rst_n)
);

wire agu2lsu_valid;
wire agu2lsu_ready;
wire agu2lsu_cancel;
wire agu2lsu_read;
wire agu2lsu_unsigned;
wire agu2lsu_word_access;
wire agu2lsu_short_access;
wire agu2lsu_byte_access;
wire [`HiCore_ADDR_SIZE-1:0] agu2lsu_addr;
wire [`HiCore_REG_SIZE-1:0] agu2lsu_wdata;
wire [`HiCore_REG_SIZE/8-1:0] agu2lsu_wmask;
wire [`HiCore_ISSUE2ALU_SIZE-1:0] agu2lsu_info;
wire [`HiCore_ROB_PTR_SIZE-1:0] lsu_head_ptr;
HiCore_agu u_HiCore_agu(
    // disp interface
.i_issue2agu_valid(agu_valid),
.i_issue2agu_ready(agu_ready),
.i_issue2agu_cancel(agu_cancel),
.agu_src1(agu_src1),
.agu_src2(agu_src2),
.agu_src3(agu_src3),
.agu_msg(agu_msg),
.load_op(load_op),
.store_op(store_op),
.i_issue2agu_info(agu_info),
    // lsu interface
.o_agu2lsu_valid(agu2lsu_valid),
.o_agu2lsu_ready(agu2lsu_ready),
.o_agu2lsu_cancel(agu2lsu_cancel),
.o_agu2lsu_read(agu2lsu_read),
.o_agu2lsu_unsigned(agu2lsu_unsigned),
.o_agu2lsu_word_access(agu2lsu_word_access),
.o_agu2lsu_short_access(agu2lsu_short_access),
.o_agu2lsu_byte_access(agu2lsu_byte_access),
.o_agu2lsu_addr(agu2lsu_addr),
.o_agu2lsu_wdata(agu2lsu_wdata),
.o_agu2lsu_wmask(agu2lsu_wmask),
.o_agu2lsu_info(agu2lsu_info),
    // rob interface
.lsu_head_ptr(lsu_head_ptr),
    // commit interface
.flush(flush),
    // system interface
.clk(clk),
.rst_n(rst_n)
);

wire lsu_icb_cmd_valid;
wire lsu_icb_cmd_ready;
wire lsu_icb_cmd_read;
wire [`HiCore_ADDR_SIZE-1:0] lsu_icb_cmd_addr;
wire [`HiCore_REG_SIZE-1:0] lsu_icb_cmd_wdata;
wire [`HiCore_REG_SIZE/8-1:0] lsu_icb_cmd_wmask;
wire lsu_icb_rsp_valid;
wire lsu_icb_rsp_ready;
wire lsu_icb_rsp_err;
wire [`HiCore_REG_SIZE-1:0] lsu_icb_rsp_rdata;
wire lsu2rob_wb_wen;
wire [`HiCore_ROB_PTR_SIZE-1:0] lsu2rob_wb_ptr;
wire [`HiCore_REG_SIZE-1:0] lsu2rob_wb_rd_data;
wire [`HiCore_WB_SIZE-1:0] lsu2rob_wb_info;
HiCore_lsu uHiCore_lsu(
// agu interface
.i_agu2lsu_valid(agu2lsu_valid),
.i_agu2lsu_ready(agu2lsu_ready),
.i_agu2lsu_cancel(agu2lsu_cancel),
.i_agu2lsu_read(agu2lsu_read),
.i_agu2lsu_unsigned(agu2lsu_unsigned),
.i_agu2lsu_word_access(agu2lsu_word_access),
.i_agu2lsu_short_access(agu2lsu_short_access),
.i_agu2lsu_byte_access(agu2lsu_byte_access),
.i_agu2lsu_addr(agu2lsu_addr),
.i_agu2lsu_wdata(agu2lsu_wdata),
.i_agu2lsu_wmask(agu2lsu_wmask),
.i_agu2lsu_info(agu2lsu_info),
// icb interface
.mem_icb_cmd_valid(lsu_icb_cmd_valid),
.mem_icb_cmd_ready(lsu_icb_cmd_ready),
.mem_icb_cmd_read(lsu_icb_cmd_read),
.mem_icb_cmd_addr(lsu_icb_cmd_addr),
.mem_icb_cmd_wdata(lsu_icb_cmd_wdata),
.mem_icb_cmd_wmask(lsu_icb_cmd_wmask),

.mem_icb_rsp_valid(lsu_icb_rsp_valid),
.mem_icb_rsp_ready(lsu_icb_rsp_ready),
.mem_icb_rsp_err(lsu_icb_rsp_err),
.mem_icb_rsp_rdata(lsu_icb_rsp_rdata),
// wb interface
.lsu_wb_wen(lsu2rob_wb_wen),
.lsu_wb_ptr(lsu2rob_wb_ptr),
.lsu_wb_rd_data(lsu2rob_wb_rd_data),
.lsu_wb_info(lsu2rob_wb_info),    
// commit interface
.flush(flush),
// system interface
.clk(clk),
.rst_n(rst_n)
);

wire lsu2dcache_icb_cmd_ready;
wire lsu2dcache_icb_cmd_valid;
wire lsu2dcache_icb_cmd_read;
wire [`HiCore_ADDR_SIZE-1:0] lsu2dcache_icb_cmd_addr;
wire [`HiCore_REG_SIZE-1:0] lsu2dcache_icb_cmd_wdata;
wire [`HiCore_REG_SIZE/8-1:0] lsu2dcache_icb_cmd_wmask;
wire lsu2dcache_icb_rsp_valid;
wire lsu2dcache_icb_rsp_ready;
wire lsu2dcache_icb_rsp_err;
wire [`HiCore_REG_SIZE-1:0] lsu2dcache_icb_rsp_rdata;

wire lsu2icache_icb_cmd_ready;
wire lsu2icache_icb_cmd_valid;
wire lsu2icache_icb_cmd_read;
wire [`HiCore_ADDR_SIZE-1:0] lsu2icache_icb_cmd_addr;
wire [`HiCore_REG_SIZE-1:0] lsu2icache_icb_cmd_wdata;
wire [`HiCore_REG_SIZE/8-1:0] lsu2icache_icb_cmd_wmask;
wire lsu2icache_icb_rsp_valid;
wire lsu2icache_icb_rsp_ready;
wire lsu2icache_icb_rsp_err;
wire [`HiCore_REG_SIZE-1:0] lsu2icache_icb_rsp_rdata;

wire plic_icb_cmd_valid;
wire plic_icb_cmd_ready;
wire plic_icb_cmd_read;
wire [`HiCore_ADDR_SIZE-1:0] plic_icb_cmd_addr;
wire [`HiCore_REG_SIZE-1:0] plic_icb_cmd_wdata;
wire [`HiCore_REG_SIZE/8-1:0] plic_icb_cmd_wmask;
wire plic_icb_rsp_valid;
wire plic_icb_rsp_ready;
wire plic_icb_rsp_err;
wire [`HiCore_REG_SIZE-1:0] plic_icb_rsp_rdata;

wire pd_icb_cmd_valid;
wire pd_icb_cmd_ready;
wire pd_icb_cmd_read;
wire [`HiCore_ADDR_SIZE-1:0] pd_icb_cmd_addr;
wire [`HiCore_REG_SIZE-1:0] pd_icb_cmd_wdata;
wire [`HiCore_REG_SIZE/8-1:0] pd_icb_cmd_wmask;
wire pd_icb_rsp_valid;
wire pd_icb_rsp_ready;
wire pd_icb_rsp_err;
wire [`HiCore_REG_SIZE-1:0] pd_icb_rsp_rdata;
HiCore_biu u_HiCore_biu(
.i_icb_cmd_valid(lsu_icb_cmd_valid),
.i_icb_cmd_ready(lsu_icb_cmd_ready),
.i_icb_cmd_read(lsu_icb_cmd_read),
.i_icb_cmd_addr(lsu_icb_cmd_addr),
.i_icb_cmd_wdata(lsu_icb_cmd_wdata),
.i_icb_cmd_wmask(lsu_icb_cmd_wmask),
.i_icb_rsp_valid(lsu_icb_rsp_valid),
.i_icb_rsp_ready(lsu_icb_rsp_ready),
.i_icb_rsp_err(lsu_icb_rsp_err),
.i_icb_rsp_rdata(lsu_icb_rsp_rdata),

.dcache_icb_cmd_ready(lsu2dcache_icb_cmd_ready),
.dcache_icb_cmd_valid(lsu2dcache_icb_cmd_valid),
.dcache_icb_cmd_read(lsu2dcache_icb_cmd_read),
.dcache_icb_cmd_addr(lsu2dcache_icb_cmd_addr),
.dcache_icb_cmd_wdata(lsu2dcache_icb_cmd_wdata),
.dcache_icb_cmd_wmask(lsu2dcache_icb_cmd_wmask),
.dcache_icb_rsp_valid(lsu2dcache_icb_rsp_valid),
.dcache_icb_rsp_ready(lsu2dcache_icb_rsp_ready),
.dcache_icb_rsp_err(lsu2dcache_icb_rsp_err),
.dcache_icb_rsp_rdata(lsu2dcache_icb_rsp_rdata),

.icache_icb_cmd_ready(lsu2icache_icb_cmd_ready),
.icache_icb_cmd_valid(lsu2icache_icb_cmd_valid),
.icache_icb_cmd_read(lsu2icache_icb_cmd_read),
.icache_icb_cmd_addr(lsu2icache_icb_cmd_addr),
.icache_icb_cmd_wdata(lsu2icache_icb_cmd_wdata),
.icache_icb_cmd_wmask(lsu2icache_icb_cmd_wmask),
.icache_icb_rsp_valid(lsu2icache_icb_rsp_valid),
.icache_icb_rsp_ready(lsu2icache_icb_rsp_ready),
.icache_icb_rsp_err(lsu2icache_icb_rsp_err),
.icache_icb_rsp_rdata(lsu2icache_icb_rsp_rdata),  

.plic_icb_cmd_ready(plic_icb_cmd_ready),
.plic_icb_cmd_valid(plic_icb_cmd_valid),
.plic_icb_cmd_read(plic_icb_cmd_read),
.plic_icb_cmd_addr(plic_icb_cmd_addr),
.plic_icb_cmd_wdata(plic_icb_cmd_wdata),
.plic_icb_cmd_wmask(plic_icb_cmd_wmask),
.plic_icb_rsp_valid(plic_icb_cmd_valid),
.plic_icb_rsp_ready(plic_icb_rsp_ready),
.plic_icb_rsp_err(plic_icb_rsp_err),
.plic_icb_rsp_rdata(plic_icb_rsp_rdata), 

.nop_icb_cmd_ready(pd_icb_cmd_ready),
.nop_icb_cmd_valid(pd_icb_cmd_valid),
.nop_icb_cmd_read(pd_icb_cmd_read),
.nop_icb_cmd_addr(pd_icb_cmd_addr),
.nop_icb_cmd_wdata(pd_icb_cmd_wdata),
.nop_icb_cmd_wmask(pd_icb_cmd_wmask),
.nop_icb_rsp_valid(pd_icb_rsp_valid),
.nop_icb_rsp_ready(pd_icb_rsp_ready),
.nop_icb_rsp_err(pd_icb_rsp_err),
.nop_icb_rsp_rdata(pd_icb_rsp_rdata), 

.clk(clk),
.rst_n(rst_n)
);

HiCore_dtcm_ctrl#(
.DW(`HiCore_REG_SIZE),
.RAM_DEPTH(12)
)uHiCore_dtcm_ctrl(
// dtcm icb interface
.mem_icb_cmd_valid(lsu2dcache_icb_cmd_valid),
.mem_icb_cmd_ready(lsu2dcache_icb_cmd_ready),
.mem_icb_cmd_read(lsu2dcache_icb_cmd_read),
.mem_icb_cmd_addr(lsu2dcache_icb_cmd_addr),
.mem_icb_cmd_wdata(lsu2dcache_icb_cmd_wdata),
.mem_icb_cmd_wmask(lsu2dcache_icb_cmd_wmask),

.mem_icb_rsp_valid(lsu2dcache_icb_rsp_valid),
.mem_icb_rsp_ready(lsu2dcache_icb_rsp_ready),
.mem_icb_rsp_err(lsu2dcache_icb_rsp_err),
.mem_icb_rsp_rdata(lsu2dcache_icb_rsp_rdata),
// system interface
.clk(clk),
.rst_n(rst_n)
);

sirv_icb_arbt #(
.AW(`HiCore_ADDR_SIZE),
.DW(`HiCore_REG_SIZE),
.FIFO_OUTS_NUM(4),
    
.ARBT_NUM(2),
.ARBT_PTR_W(1)
)u_icache_arbt(
.o_icb_cmd_valid(icache_icb_cmd_valid),
.o_icb_cmd_ready(icache_icb_cmd_ready),
.o_icb_cmd_read(icache_icb_cmd_read),
.o_icb_cmd_addr(icache_icb_cmd_addr),
.o_icb_cmd_wdata(icache_icb_cmd_wdata),
.o_icb_cmd_wmask(icache_icb_cmd_wmask),

.o_icb_rsp_valid(icache_icb_rsp_valid),
.o_icb_rsp_ready(icache_icb_rsp_ready),
.o_icb_rsp_err(icache_icb_rsp_err),
.o_icb_rsp_rdata(icache_icb_rsp_rdata),

.i_bus_icb_cmd_ready({if2icache_icb_cmd_ready,lsu2icache_icb_cmd_ready}),
.i_bus_icb_cmd_valid({if2icache_icb_cmd_valid,lsu2icache_icb_cmd_valid}),
.i_bus_icb_cmd_read({if2icache_icb_cmd_read,lsu2icache_icb_cmd_read}),
.i_bus_icb_cmd_addr({if2icache_icb_cmd_addr,lsu2icache_icb_cmd_addr}),
.i_bus_icb_cmd_wdata({if2icache_icb_cmd_wdata,lsu2icache_icb_cmd_wdata}),
.i_bus_icb_cmd_wmask({if2icache_icb_cmd_wmask,lsu2icache_icb_cmd_wmask}),

.i_bus_icb_rsp_valid({if2icache_icb_rsp_valid,lsu2icache_icb_rsp_valid}),
.i_bus_icb_rsp_ready({if2icache_icb_rsp_ready,lsu2icache_icb_rsp_ready}),
.i_bus_icb_rsp_err({if2icache_icb_rsp_err,lsu2icache_icb_rsp_err}),
.i_bus_icb_rsp_rdata({if2icache_icb_rsp_rdata,lsu2icache_icb_rsp_rdata}),

.clk(clk),
.rst_n(rst_n) 
);

HiCore_nop_slave #(
.AW(`HiCore_ADDR_SIZE),
.DW(`HiCore_REG_SIZE)
)plic_slave(
.icb_cmd_valid(plic_icb_cmd_valid),
.icb_cmd_ready(plic_icb_cmd_ready),
.icb_cmd_addr(plic_icb_cmd_addr),
.icb_cmd_read(plic_icb_cmd_read),
.icb_cmd_wdata(plic_icb_cmd_wdata),
.icb_cmd_wmask(plic_icb_cmd_wmask),

.icb_rsp_ready(plic_icb_rsp_ready),
.icb_rsp_valid(plic_icb_rsp_valid),
.icb_rsp_err(plic_icb_rsp_err),
.icb_rsp_rdata(plic_icb_rsp_rdata),

.clk(clk),
.rst_n(rst_n)
);

HiCore_nop_slave #(
.AW(`HiCore_ADDR_SIZE),
.DW(`HiCore_REG_SIZE)
)pd_slave(
.icb_cmd_valid(pd_icb_cmd_valid),
.icb_cmd_ready(pd_icb_cmd_ready),
.icb_cmd_addr(pd_icb_cmd_addr),
.icb_cmd_read(pd_icb_cmd_read),
.icb_cmd_wdata(pd_icb_cmd_wdata),
.icb_cmd_wmask(pd_icb_cmd_wmask),

.icb_rsp_ready(pd_icb_rsp_ready),
.icb_rsp_valid(pd_icb_rsp_valid),
.icb_rsp_err(pd_icb_rsp_err),
.icb_rsp_rdata(pd_icb_rsp_rdata),

.clk(clk),
.rst_n(rst_n)
);

wire csr2rob_wb_wen;
wire [`HiCore_ROB_PTR_SIZE-1:0] csr2rob_wb_ptr;
wire [`HiCore_REG_SIZE-1:0] csr2rob_wb_rd_data;
wire [`HiCore_REG_SIZE-1:0] csr2rob_wb_csr_data;
wire [`HiCore_WB_SIZE-1:0] csr2rob_wb_info;
wire commit2csr_valid;
wire [`HiCore_EXCP_SIZE-1:0] commit2csr_excp;
wire [`HiCore_IRQ_SIZE-1:0] commit2csr_irq;
wire [`HiCore_PC_SIZE-1:0] commit2csr_pc;
wire commit2csr_csr_need;
wire [`HiCore_CSRIDX_WIDTH-1:0] commit2csr_csr_idx;
wire [`HiCore_REG_SIZE-1:0] commit2csr_csr_data;
wire [`HiCore_PC_SIZE-1:0] commit2csr_next_pc;
wire commit2csr_mret_op;
wire [`HiCore_IRQ_SIZE-1:0] csr2commit_irq_msk;
wire [`HiCore_REG_SIZE-1:0] csr2commit_mepc;
wire [`HiCore_REG_SIZE-1:0] csr2commit_mtvec;
HiCore_csr u_HiCore_csr(
    // disp interface
.i_issue2csr_valid(csr_valid),
.i_issue2csr_ready(csr_ready),
.i_issue2csr_cancel(csr_cancel),
.csr_reg_src(csr_reg_src),
.csr_idx(issue2csr_csr_idx),
.csr_msg(csr_msg),
.csr_info(csr_info),
    // wb interface
.rob_wb_wen(csr2rob_wb_wen),
.rob_wb_ptr(csr2rob_wb_ptr),
.rob_wb_rd_data(csr2rob_wb_rd_data),
.rob_wb_csr_data(csr2rob_wb_csr_data),
.rob_wb_info(csr2rob_wb_info),
    // commit interface
.commit_valid(commit2csr_valid),
.commit_excp(commit2csr_excp),
.commit_irq(commit2csr_irq),
.commit_pc(commit2csr_pc),
.commit_next_pc(commit2csr_next_pc),
.commit_csr_need(commit2csr_csr_need),
.commit_csr_idx(commit2csr_csr_idx),
.commit_csr_data(commit2csr_csr_data),
.commit_mret_op(commit2csr_mret_op),
.flush(flush),
.irq_msk(csr2commit_irq_msk),
.csr_mepc(csr2commit_mepc),
.csr_mtvec(csr2commit_mtvec),
    // irq interface
.ext_irq(m_ext_irq),
.sft_irq(m_soft_irq),
.tmr_irq(m_time_irq),
    // system interface
.clk(clk),
.rst_n(rst_n)
);

wire commit_valid;
wire commit_ready;
wire commit_rd_need;
wire [`HiCore_RFIDX_WIDTH-1:0] commit_rd_idx;
wire [`HiCore_REG_SIZE-1:0] commit_rd_data;
wire [`HiCore_PC_SIZE-1:0] commit_next_pc;
wire commit_csr_need;
wire [`HiCore_CSRIDX_WIDTH-1:0] commit_csr_idx;
wire [`HiCore_REG_SIZE-1:0] commit_csr_data;
wire commit_fence_i_op;
wire commit_mret_op;
wire [`HiCore_WB_SIZE-1:0] commit_info;
HiCore_ROB u_HiCore_ROB(
// decoe interface
.issue_wen(de2rob_wen),
.issue_rd_need(de2rob_rd_need),
.issue_rd_idx(de2rob_rd_idx),
.issue_csr_need(de2rob_csr_need),
.issue_csr_idx(de2rob_csr_idx),
.issue_fence_i_op(de2rob_fence_i_op),
.issue_next_pc(de2rob_next_pc),
.issue_mret_op(de2rob_mret_op),
.issue_tail_ptr(de2rob_tail_ptr),
.issue_full(full),
// bjp writeback interface
.bjp_wb_wen(bjp2rob_wb_wen),
.bjp_wb_ptr(bjp2rob_wb_ptr),
.bjp_wb_rd_data(bjp2rob_wb_rd_data),
.bjp_wb_info(bjp2rob_wb_info),
// alu writeback interface
.alu_wb_wen(alu2rob_wb_wen),
.alu_wb_ptr(alu2rob_wb_ptr),
.alu_wb_rd_data(alu2rob_wb_rd_data),
.alu_wb_info(alu2rob_wb_info),
// lsu writeback interface
.lsu_wb_wen(lsu2rob_wb_wen),
.lsu_wb_ptr(lsu2rob_wb_ptr),
.lsu_wb_rd_data(lsu2rob_wb_rd_data),
.lsu_wb_info(lsu2rob_wb_info),
// csr writeback interface
.csr_wb_wen(csr2rob_wb_wen),
.csr_wb_ptr(csr2rob_wb_ptr),
.csr_wb_rd_data(csr2rob_wb_rd_data),
.csr_wb_csr_data(csr2rob_wb_csr_data),
.csr_wb_info(csr2rob_wb_info),
// nop writeback interface
.nop_wb_wen(nop2rob_wb_wen),
.nop_wb_ptr(nop2rob_wb_ptr),
.nop_wb_info(nop2rob_wb_info),
// commit interface
.commit_valid(commit_valid),
.commit_ready(commit_ready),
.commit_rd_need(commit_rd_need),
.commit_rd_idx(commit_rd_idx),
.commit_rd_data(commit_rd_data),
.commit_csr_need(commit_csr_need),
.commit_csr_idx(commit_csr_idx),
.commit_csr_data(commit_csr_data),
.commit_fence_i_op(commit_fence_i_op),
.commit_mret_op(commit_mret_op),
.commit_next_pc(commit_next_pc),
.commit_info(commit_info),
.flush(flush),
// dependency interface TODO:
.de_rs1_need(rs1_need),
.de_rs2_need(rs2_need),
.de_rs1_idx(rob_rs1_idx),
.de_rs2_idx(rob_rs2_idx),
.de_csr_need(csr_need),
.de_csr_idx(csr_idx),
.de_depend(depend),
.de_empty(empty),  
// store interface
.lsu_head_ptr(lsu_head_ptr),
// system interface
.clk(clk),
.rst_n(rst_n)
);

HiCore_commit u_HiCore_commit(
// rob interface
.rob_valid(commit_valid),
.rob_ready(commit_ready),
.rob_rd_need(commit_rd_need),
.rob_rd_idx(commit_rd_idx),
.rob_rd_data(commit_rd_data),
.rob_next_pc(commit_next_pc),
.rob_csr_need(commit_csr_need),
.rob_csr_idx(commit_csr_idx),
.rob_csr_data(commit_csr_data),
.rob_fence_i_op(commit_fence_i_op),
.rob_mret_op(commit_mret_op),
.rob_info(commit_info),
// csr interface
.csr_valid(commit2csr_valid),
.csr_excp(commit2csr_excp),
.csr_irq(commit2csr_irq),
.csr_pc(commit2csr_pc),
.csr_next_pc(commit2csr_next_pc),
.csr_csr_need(commit2csr_csr_need),
.csr_csr_idx(commit2csr_csr_idx),
.csr_csr_data(commit2csr_csr_data),
.csr_mret_op(commit2csr_mret_op),
.csr_irq_msk(csr2commit_irq_msk),
.csr_mepc(csr2commit_mepc),
.csr_mtvec(csr2commit_mtvec),
// register file interface
.reg_wen(wbck_dest_wen),
.reg_rd_idx(wbck_dest_idx),
.reg_rd_data(wbck_dest_dat),
// flush
.flush(flush),
.flush_pc(flush_pc)
);
endmodule
