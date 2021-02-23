`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/27 16:12:52
// Design Name: 
// Module Name: ifetch_tb
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


module ifetch_tb();
reg branch;
reg [31:0] branch_pc;
reg flush;
reg [31:0] flush_pc;
reg clk;
reg rst_n;
initial begin
    branch<=1'b0;
    branch_pc<=32'd0;
    flush<=1'b0;
    flush_pc<=32'd0;
    clk<=1'b0;
    rst_n<=1'b0;
    #10 rst_n<=1'b1;
    #100 branch<=1'b1;
    #10 branch<=1'b0;
    #100 flush<=1'b1;
    #10 flush<=1'b0;
    #150 $finish;
end
always #5 clk<=~clk;
ifetch_test u_ifetch_test(
.branch(branch),
.branch_pc(branch_pc),
.flush(flush),
.flush_pc(flush_pc),
.clk(clk),
.rst_n(rst_n)
);
endmodule
