module HiCore_pipe #(
    parameter CUT_READY = 0,
    parameter DW = 32
)(
    input           i_vld,
    output          i_rdy,
    input  [DW-1:0] i_dat,
    input           i_cancel,
    output          o_vld,
    input           o_rdy,
    output [DW-1:0] o_dat,
    output          o_cancel,
    
    input           branch,

    input           clk,
    input           rst_n
);

wire vld_set;
wire vld_clr;
wire vld_ena;
wire vld_r;
wire vld_nxt;

assign vld_set = i_vld & i_rdy;
assign vld_clr = o_vld & o_rdy;
assign vld_ena = vld_set | vld_clr;
assign vld_nxt = vld_set | (~vld_clr);

gnrl_dfflr #(1) vld_dfflr(vld_ena,vld_nxt,vld_r,clk,rst_n);
assign o_vld = vld_r;

gnrl_dfflr #(DW) dat_dfflr(vld_set, i_dat, o_dat, clk, rst_n);

wire cancel_ena = branch | vld_set;
wire cancel_nxt = (branch)? 1'b1: i_cancel;
gnrl_dfflr #(1) cancel_dfflr(cancel_ena,cancel_nxt,o_cancel,clk,rst_n); 

generate 
if (CUT_READY == 1) begin:cut_ready_pipe
    assign i_rdy = (~vld_r);
end
else begin:no_cut_ready_pipe
    assign i_rdy = (~vld_r) | vld_clr;
end
endgenerate

endmodule

// ================================================

module HiCore_sync_fifo #(
    parameter DP        = 1,
    parameter DW        = 32
)(
    input           i_vld,
    output          i_rdy,
    input  [DW-1:0] i_dat,
    output          o_vld,
    input           o_rdy,
    output [DW-1:0] o_dat,

    input           clk,
    input           rst_n
);

localparam PTR_W = $clog2(DP)+1;
generate 
if (DP == 1) begin:dp1_fifo
    HiCore_pipe #(
        .DW(DW),
        .CUT_READY(1)
    ) u_Hicore_pipe(
        .i_vld(i_vld),
        .i_rdy(i_rdy),
        .i_dat(i_dat),
        .o_vld(o_vld),
        .o_rdy(o_rdy),
        .o_dat(o_dat),
        .clk(clk),
        .rst_n(rst_n)
    );
end
else begin: dpn_fifo
    reg [DW-1:0] fifo_reg[DP-1:0];

    reg [PTR_W-1:0] wr_ptr;
    reg [PTR_W-1:0] rd_ptr;

    wire wen = i_vld & i_rdy;
    wire ren = o_vld & o_rdy;

    always @(posedge clk or negedge rst_n)begin
        if (~rst_n)
            wr_ptr<=0;
         else if (wen)
            wr_ptr<=wr_ptr+1;
        else wr_ptr<=wr_ptr; 
    end

    always @(posedge clk or negedge rst_n)begin
        if (~rst_n)
            rd_ptr<=0;
        else if (ren)
            rd_ptr<=rd_ptr+1;
        else rd_ptr<=0; 
    end

    integer i;
    always @(posedge clk)begin
        for (i=0;i<DP;i=i+1)begin
            if (wen && (i==wr_ptr))
                fifo_reg[i] <= i_dat;
            else 
                fifo_reg[i] <= fifo_reg[i];
        end
    end

    assign o_dat = fifo_reg[rd_ptr[PTR_W-1:0]];
    wire empty;
    wire full;
    assign full = (wr_ptr[PTR_W-1] ^ rd_ptr[PTR_W-1]) & (wr_ptr[PTR_W-2:0]==rd_ptr[PTR_W-2:0]);
    assign empty = (wr_ptr==rd_ptr);
    assign o_vld = ~empty;
    assign i_rdy = ~full;
end
endgenerate

endmodule

//module HiCore_bypbuf #(
//    parameter DP = 8,
//    parameter DW = 32
//)(
//    input           i_vld,
//    output          i_rdy,
//    input  [DW-1:0] i_dat,
//    output          o_vld,
//    input           o_rdy,
//    output [DW-1:0] o_dat,
//
//    input clk,
//    input rst_n
//);
//
//wire          fifo_i_vld;
//wire          fifo_i_rdy;
//wire [DW-1:0] fifo_i_dat;
//
//wire          fifo_o_vld;
//wire          fifo_o_rdy;
//wire [DW-1:0] fifo_o_dat;
//
//HiCore_fifo # (
//       .DP(DP),
//       .DW(DW)
//) u_bypbuf_fifo(
//    .i_vld   (fifo_i_vld),
//    .i_rdy   (fifo_i_rdy),
//    .i_dat   (fifo_i_dat),
//    .o_vld   (fifo_o_vld),
//    .o_rdy   (fifo_o_rdy),
//    .o_dat   (fifo_o_dat),
//    .clk     (clk  ),
//    .rst_n   (rst_n)
//);
//
//assign i_rdy = fifo_i_rdy;
//
//wire byp = i_vld & o_rdy & (~fifo_o_vld);
//
//assign fifo_o_rdy = o_rdy;
//assign o_vld = fifo_o_vld | i_vld;
//
//assign o_dat = fifo_o_vld ? fifo_o_dat:i_dat;
//assign fifo_i_dat = i_dat;
//
//assign fifo_i_vld = i_vld & (~byp);
//
//endmodule
module HiCore_sync#(
    parameter DP = 2,
    parameter DW = 32
)(
    input  [DW-1:0] dina,
    output [DW-1:0] dout,
    
    input  rst_n,
    input  clk
);
wire [DW-1:0] sync_dat [DP-1:0];
genvar i;
generate
    for (i=0;i<DP;i=i+1)begin:sync_gen
        if (i==0) begin: i_is_0
            gnrl_dffr #(DW) sync_dffr(dina,sync_dat[0],clk,rst_n);
        end
        else begin: i_is_not_0
            gnrl_dffr #(DW) sync_dffr(sync_dat[i-1],sync_dat[i],clk,rst_n);
        end
    end
endgenerate

assign dout = sync_dat[DP-1];
endmodule