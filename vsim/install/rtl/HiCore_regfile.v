`include "config.v"
module Hicore_regfile(
    input  [`HiCore_RFIDX_WIDTH-1:0] read_src1_idx,
    input  [`HiCore_RFIDX_WIDTH-1:0] read_src2_idx,
    output [`HiCore_REG_SIZE-1:0]    read_src1_dat,
    output [`HiCore_REG_SIZE-1:0]    read_src2_dat,

    input                            wbck_dest_wen,
    input  [`HiCore_RFIDX_WIDTH-1:0] wbck_dest_idx,
    input  [`HiCore_REG_SIZE-1:0]    wbck_dest_dat,

    input clk,
    input rst_n
);

wire [`HiCore_REG_SIZE-1:0] rf_r [31:0];
wire [31:0] rf_wen;

genvar i;
generate for(i=0;i<32;i=i+1) begin : regfile
    if (i==0) begin:rf0
        assign rf_wen[i] = 1'b0;
        assign rf_r[i]   = {`HiCore_REG_SIZE{1'b0}};
    end
    else begin: rfno0
        assign rf_wen[i] = wbck_dest_wen & (wbck_dest_idx==i);
        gnrl_dfflr #(`HiCore_REG_SIZE) reg_dfflr(rf_wen[i],wbck_dest_dat,rf_r[i],clk,rst_n);
    end

end
endgenerate

assign read_src1_dat = rf_r[read_src1_idx];
assign read_src2_dat = rf_r[read_src2_idx];

endmodule
