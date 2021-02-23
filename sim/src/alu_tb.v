`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/11 18:45:05
// Design Name: 
// Module Name: alu_tb
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


module alu_tb();
reg m_ext_irq;
reg m_time_irq;
reg m_soft_irq;
reg clk;
reg rst_n;
initial begin
    m_ext_irq<=1'b0;
    m_time_irq<=1'b0;
    m_soft_irq<=1'b0;
    clk<=1'b0;
    rst_n<=1'b0;
    #20 rst_n<=1'b1;
//    #100 m_ext_irq<=1'b1;
//    #30 m_ext_irq<=1'b0;
end
always #5 clk<=~clk;
alu_test u_alu_test( 
.m_ext_irq(m_ext_irq),
.m_time_irq(m_time_irq),
.m_soft_irq(m_soft_irq),
.clk(clk),
.rst_n(rst_n)
    );
endmodule
