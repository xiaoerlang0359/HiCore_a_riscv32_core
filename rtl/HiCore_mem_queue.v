module HiCore_queue#(
    parameter DW = `HiCore_ISSUE2ALU_SIZE,
    parameter DP = 4,
    parameter LOGDP = 2
)(
    input  i_valid,
    output i_ready,
    input  i_cancel,
    input  [DW-1:0] i_info,
    output o_valid,
    input  o_ready,
    output o_cancel,
    output [DW-1:0] o_info,

    input  flush,

    input  clk,
    input  rst_n
);

// valid and ready
wire empty;
wire full;
wire wen;
wire ren;
assign i_ready = ~full;
assign o_valid = ~empty;
assign wen = i_valid & i_ready;
assign ren = o_valid & o_ready;

// write ptr;
wire [LOGDP:0] wr_ptr;
wire [LOGDP:0] wr_ptr_nxt = wr_ptr + 1'b1;
wire wr_ptr_ena = wen;
gnrl_dfflr #(LOGDP+1) wr_ptr_dfflr (wr_ptr_ena,wr_ptr_nxt,wr_ptr,clk,rst_n);
//read ptr
wire [LOGDP:0] rd_ptr;
wire [LOGDP:0] rd_ptr_nxt = rd_ptr + 1'b1;
wire rd_ptr_ena = ren;
gnrl_dfflr #(LOGDP+1) rd_ptr_dfflr (rd_ptr_ena,rd_ptr_nxt,rd_ptr,clk,rst_n);
assign empty = (rd_ptr==wr_ptr);
assign full = (rd_ptr[LOGDP] ^ wr_ptr[LOGDP]) & (rd_ptr[LOGDP-1:0] == wr_ptr[LOGDP-1:0]);

// content
wire [DW-1:0] queue_ram[DP-1:0];
wire [DP-1:0] queue_wen;
genvar i;
generate
    for (i=0;i<DP;i=i+1) begin: gen_for_content
        assign queue_wen[i] = wen & (wr_ptr[LOGDP-1:0]==i);
        gnrl_dffl #(DW) queue_ram_dffl   (queue_wen[i],i_info,  queue_ram[i],   clk);
    end
endgenerate
assign o_info = queue_ram[rd_ptr[LOGDP-1:0]];
// cancel
wire [DP-1:0] queue_cancel;
wire [DP-1:0] queue_cancel_ena;
wire [DP-1:0] queue_cancel_nxt;
generate
    for (i=0;i<DP;i=i+1) begin: gen_for_cancel
        assign queue_cancel_ena[i] = (wen & (wr_ptr[LOGDP-1:0])==i) | flush;
        assign queue_cancel_nxt[i] = (flush)? 1'b1: i_cancel;
        gnrl_dfflr #(1) queue_cancel_dfflr (queue_cancel_ena[i],queue_cancel_nxt[i],queue_cancel[i],clk,rst_n);
    end 
endgenerate
assign o_cancel = queue_cancel[rd_ptr[LOGDP-1:0]];

endmodule
