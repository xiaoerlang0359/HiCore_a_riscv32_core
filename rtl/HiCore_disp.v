module HiCore_disp(
    // de2ex pipe interface
    input  i_de2ex_valid,
    output i_de2ex_ready,
    input  [`HiCore_DE2EX_SIZE-1:0]  i_de2ex_info,
    // disp 2 branch interface
    output o_de2bj_valid,
    input  o_de2bj_ready,
    output [`HiCore_DE2BJ_SIZE-1:0]  o_de2bj_info,
    // disp 2 alu interface
    output o_de2alu_valid,
    input  o_de2alu_ready,
    output [`HiCore_DE2ALU_SIZE-1:0] o_de2alu_info,
    // disp 2 agu interface
    output o_de2agu_valid,
    input  o_de2agu_ready,
    output [`HiCore_DE2ALU_SIZE-1:0] o_de2agu_info,
    // disp 2 csr interface
    output o_de2csr_valid,
    input  o_de2csr_ready,
    output [`HiCore_DE2CSR_SIZE-1:0] o_de2csr_info,
    // nop interface
    output o_de2nop_valid,
    input  o_de2nop_ready,
    output [1:0] o_de2nop_info,
    // dependency interface
    output ex_rd_need,
    output [`HiCore_RFIDX_WIDTH-1:0] ex_rd_idx,
    // system interface
    input clk,
    input rst_n
);

assign o_de2bj_valid = i_de2ex_valid & (~i_de2ex_info[0]) & i_de2ex_info[4];
assign o_de2alu_valid= i_de2ex_valid & (~i_de2ex_info[0]) & i_de2ex_info[3];
assign o_de2agu_valid= i_de2ex_valid & (~i_de2ex_info[0]) & i_de2ex_info[2];
assign o_de2csr_valid= i_de2ex_valid & (~i_de2ex_info[0]) & i_de2ex_info[1];
assign o_de2nop_valid= i_de2ex_valid & (i_de2ex_info[0] | i_de2ex_info[5] | i_de2ex_info[6]);

assign o_de2bj_info  = {`HiCore_DE2BJ_SIZE{o_de2bj_valid}}   & i_de2ex_info[`HiCore_DE2BJ_SIZE-1:0]; 
assign o_de2alu_info = {`HiCore_DE2ALU_SIZE{o_de2alu_valid}} & i_de2ex_info[`HiCore_DE2ALU_SIZE-1:0];
assign o_de2agu_info = {`HiCore_DE2AGU_SIZE{o_de2agu_valid}} & i_de2ex_info[`HiCore_DE2AGU_SIZE-1:0];
assign o_de2csr_info = {`HiCore_DE2CSR_SIZE{o_de2csr_valid}} & i_de2ex_info[`HiCore_DE2CSR_SIZE-1:0];
assign o_de2nop_info = {2{o_de2nop_valid}} & i_de2ex_info[6:5];

assign ex_rd_need    = (~i_de2ex_info[0]) & i_de2ex_info[12];
assign ex_rd_idx     = i_de2ex_info[11:7];

assign i_de2ex_ready = o_de2bj_ready & o_de2alu_ready & o_de2agu_ready & o_de2csr_ready & o_de2nop_ready;

endmodule