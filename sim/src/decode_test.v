`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/10 20:57:18
// Design Name: 
// Module Name: decode_test
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

module decode_test(
    input flush,
    input [`HiCore_PC_SIZE-1:0] flush_pc,
    input m_ext_irq,
    input m_time_irq,
    input m_soft_irq,
    input clk,
    input rst_n
);
wire icache_icb_cmd_valid;
wire icache_icb_cmd_ready;
wire [`HiCore_ADDR_SIZE-1:0] icache_icb_cmd_addr;
wire icache_icb_rsp_ready;
wire icache_icb_rsp_valid;
wire icache_icb_rsp_cancel;
wire [`HiCore_IF2DE_SIZE-1:0] icache_icb_rsp_rdata;
wire if2de_valid;
wire if2de_ready;
wire [`HiCore_IF2DE_SIZE-1:0] if2de_info;
wire if2de_cancel;
wire branch;
wire [`HiCore_PC_SIZE-1:0] branch_pc;

HiCore_ifetch u_HiCore_ifetch(
    // interface of icache icb
.icache_icb_cmd_valid(icache_icb_cmd_valid),
.icache_icb_cmd_ready(icache_icb_cmd_ready),
.icache_icb_cmd_read(),
.icache_icb_cmd_addr(icache_icb_cmd_addr),
.icache_icb_cmd_wdata(),
.icache_icb_cmd_wmask(),

.icache_icb_rsp_ready(icache_icb_rsp_ready),
.icache_icb_rsp_valid(icache_icb_rsp_valid),
.icache_icb_rsp_rdata(icache_icb_rsp_rdata),
.icache_icb_rsp_cancel(icache_icb_rsp_cancel),
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

ifetch_sram_ctrl #(
    .DW(32),
    .RAM_DEPTH(14)
)u_ifetch_sram_ctrl(
// itcm interface
.icache_icb_cmd_valid(icache_icb_cmd_valid),
.icache_icb_cmd_ready(icache_icb_cmd_ready),
.icache_icb_cmd_read(1'b1),
.icache_icb_cmd_addr(icache_icb_cmd_addr),
.icache_icb_cmd_wdata(0),
.icache_icb_cmd_wmask(0),

.icache_icb_rsp_ready(icache_icb_rsp_ready),
.icache_icb_rsp_valid(icache_icb_rsp_valid),
.icache_icb_rsp_rdata(icache_icb_rsp_rdata),
.icache_icb_rsp_cancel(icache_icb_rsp_cancel),
// flush interface
.flush(flush),
.branch(branch),
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
.rs1_need(),
.rs2_need(),
.rob_rs1_idx(),
.rob_rs2_idx(),
.csr_need(),
.csr_idx(),
.depend(1'b0),
.empty(1'b0), // for fence instruction
.full(1'b0),

.rob_wen(),
.rob_rd_need(),
.rob_rd_idx(),
.rob_csr_need(),
.rob_csr_idx(),
.rob_fence_i_op(),
.rob_mret_op(),
.rob_tail_ptr(1),
    // irq interface
.m_ext_irq(m_ext_irq),
.m_time_irq(m_time_irq),
.m_soft_irq(m_soft_irq),
    // system interface
.clk(clk),
.rst_n(rst_n)
);

Hicore_regfile u_HiCore_regfile( 
.read_src1_idx(rs1_idx),
.read_src2_idx(rs2_idx),
.read_src1_dat(read_src1_dat),
.read_src2_dat(read_src2_dat),

.wbck_dest_wen(1'b0),
.wbck_dest_idx(0),
.wbck_dest_dat(0),

.clk(clk),
.rst_n(rst_n)
);

HiCore_Issue u_HiCore_Issue(
    // de2issue pipe interface
.i_de2issue_valid(de2issue_valid),
.i_de2issue_ready(de2issue_ready),
.i_de2issue_cancel(de2issue_cancel),
.i_de2issue_info(de2issue_info),
    // issue2bjp interface
.bjp_valid(),
.bjp_ready(1'b1),
.bjp_cancel(),
.bjp_rd_result(),
.bjp_rd_need(),
.bjp_rd_idx(),
.bjp_info(),
    // issue2alu interface
.alu_valid(),
.alu_ready(1'b1),
.alu_cancel(),
.alu_src1(),
.alu_src2(),
.alu_rd_need(),
.alu_rd_idx(),
.alu_msg(),
.alu_dir(),
.auipc_op(),
.lui_op(),
.alu_op(),
.alu_info(),
    // issue2agu interface
.agu_valid(),
.agu_ready(1'b1),
.agu_cancel(),
.agu_src1(),
.agu_src2(),
.agu_src3(),
.agu_rd_need(),
.agu_rd_idx(),
.agu_msg(),
.load_op(),
.store_op(),
.agu_info(),
    // issue2csr interface
.csr_valid(),
.csr_ready(1'b1),
.csr_cancel(),
.csr_reg_src(),
.csr_rd_need(),
.csr_rd_idx(),
.csr_idx(),
.csr_msg(),
.csr_info(),
    // issue2nop interface
.nop_valid(),
.nop_ready(1'b1),
.nop_cancel(),
.mret_op(),
.fence_i_op(),
.nop_info()
);
endmodule
