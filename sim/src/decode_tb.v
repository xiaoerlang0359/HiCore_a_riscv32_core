`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/10 23:31:39
// Design Name: 
// Module Name: decode_tb
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


module decode_tb();

reg flush;
reg [`HiCore_PC_SIZE-1:0] flush_pc;
reg m_ext_irq;
reg m_time_irq;
reg m_soft_irq;
reg clk;
reg rst_n;
initial begin
    flush<=1'b0;
    flush_pc<=32'd0;
    m_ext_irq<=1'b0;
    m_time_irq<=1'b0;
    m_soft_irq<=1'b0;
    clk<=1'b0;
    rst_n<=1'b0;
    #10 rst_n<=1'b1;
end
always #5 clk<=~clk;

decode_test u_decode_test(
.flush(flush),
.flush_pc(flush_pc),
.m_ext_irq(m_ext_irq),
.m_time_irq(m_time_irq),
.m_soft_irq(m_soft_irq),
.clk(clk),
.rst_n(rst_n)
);
endmodule
