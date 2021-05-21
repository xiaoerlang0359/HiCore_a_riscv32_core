module sirv_icb_arbt #(
    parameter AW = 32,
    parameter DW = 32,
    parameter FIFO_OUTS_NUM = 1,
    
    parameter ARBT_NUM = 4,
    parameter ARBT_PTR_W = 2
)(
    output              o_icb_cmd_valid,
    input               o_icb_cmd_ready,
    output [1-1:0]      o_icb_cmd_read,
    output [AW-1:0]     o_icb_cmd_addr,
    output [DW-1:0]     o_icb_cmd_wdata,
    output [DW/8-1:0]   o_icb_cmd_wmask,

    input               o_icb_rsp_valid,
    output              o_icb_rsp_ready,
    input               o_icb_rsp_err,
    input  [DW-1:0]     o_icb_rsp_rdata,

    output [ARBT_NUM*1-1:0]     i_bus_icb_cmd_ready,
    input  [ARBT_NUM*1-1:0]     i_bus_icb_cmd_valid,
    input  [ARBT_NUM*1-1:0]     i_bus_icb_cmd_read,
    input  [ARBT_NUM*AW-1:0]    i_bus_icb_cmd_addr,
    input  [ARBT_NUM*DW-1:0]    i_bus_icb_cmd_wdata,
    input  [ARBT_NUM*DW/8-1:0]  i_bus_icb_cmd_wmask,

    output [ARBT_NUM*1-1:0]     i_bus_icb_rsp_valid,
    input  [ARBT_NUM*1-1:0]     i_bus_icb_rsp_ready,
    output [ARBT_NUM*1-1:0]     i_bus_icb_rsp_err,
    output [ARBT_NUM*DW-1:0]    i_bus_icb_rsp_rdata,

    input clk,
    input rst_n 
);

integer j;
wire [ARBT_NUM-1:0] i_bus_icb_cmd_grt_vec;
wire [ARBT_NUM-1:0] i_bus_icb_cmd_sel;
wire o_icb_cmd_valid_real;
wire o_icb_cmd_ready_real;

wire [1-1:0]    i_icb_cmd_read [ARBT_NUM-1:0];
wire [AW-1:0]   i_icb_cmd_addr [ARBT_NUM-1:0];
wire [DW-1:0]   i_icb_cmd_wdata[ARBT_NUM-1:0];
wire [DW/8-1:0] i_icb_cmd_wmask[ARBT_NUM-1:0];

reg  [1-1:0]    sel_o_icb_cmd_read;
reg  [AW-1:0]   sel_o_icb_cmd_addr;
reg  [DW-1:0]   sel_o_icb_cmd_wdata;
reg  [DW/8-1:0] sel_o_icb_cmd_wmask;

wire o_icb_rsp_ready_pre;
wire o_icb_rsp_valid_pre;

wire rspid_fifo_bypass;
wire rspid_fifo_wen;
wire rspid_fifo_ren;

wire [ARBT_PTR_W-1:0] i_icb_rsp_port_id;
wire rspid_fifo_i_valid;
wire rspid_fifo_o_valid;
wire rspid_fifo_i_ready;
wire rspid_fifo_o_ready;
wire [ARBT_PTR_W-1:0] rspid_fifo_rdat;
wire [ARBT_PTR_W-1:0] rspid_fifo_wdat;

wire rspid_fifo_full;
wire rspid_fifo_empty;
reg  [ARBT_PTR_W-1:0] i_arbt_indic_id;

wire i_icb_cmd_ready_pre;
wire i_icb_cmd_valid_pre;

wire arbt_ena;

wire [ARBT_PTR_W-1:0] o_icb_rsp_port_id;

genvar i;
generate
    if (ARBT_NUM == 1) begin:arbt_num_eq_1_gen
        assign i_bus_icb_cmd_ready = o_icb_cmd_ready;
        assign o_icb_cmd_valid     = i_bus_icb_cmd_valid;
        assign o_icb_cmd_read      = i_bus_icb_cmd_read;
        assign o_icb_cmd_addr      = i_bus_icb_cmd_addr;
        assign o_icb_cmd_wdata     = i_bus_icb_cmd_wdata;
        assign o_icb_cmd_wmask     = i_bus_icb_cmd_wmask;

        assign o_icb_rsp_ready     = i_bus_icb_rsp_ready;
        assign i_bus_icb_rsp_valid = o_icb_rsp_valid;
        assign i_bus_icb_rsp_err   = o_icb_rsp_err;
        assign i_bus_icb_rsp_rdata = o_icb_rsp_rdata;
    end
    else begin:arbt_num_gt_1_gen
        
        assign o_icb_cmd_valid = o_icb_cmd_valid_real & (~rspid_fifo_full);
        assign o_icb_cmd_ready_real = o_icb_cmd_ready & (~rspid_fifo_full);
        // distract the icb from the bus declared ports

        for(i=0;i<ARBT_NUM;i=i+1)
        begin:icb_distract_gen
            assign i_icb_cmd_read [i] = i_bus_icb_cmd_read [(i+1)*1     -1:i*1];
            assign i_icb_cmd_addr [i] = i_bus_icb_cmd_addr [(i+1)*AW    -1:i*AW];
            assign i_icb_cmd_wdata[i] = i_bus_icb_cmd_wdata[(i+1)*DW    -1:i*DW];
            assign i_icb_cmd_wmask[i] = i_bus_icb_cmd_wmask[(i+1)*DW/8  -1:i*(DW/8)];
            
            assign i_bus_icb_cmd_ready[i] = i_bus_icb_cmd_grt_vec[i] & o_icb_cmd_ready_real;
            assign i_bus_icb_rsp_valid[i] = o_icb_rsp_valid_pre & (o_icb_rsp_port_id == i);
        end

        assign arbt_ena = 1'b0;
        for (i=0; i< ARBT_NUM; i=i+1)
        begin:priroty_grt_vec_gen
            if (i==0) begin: i_is_0
                assign i_bus_icb_cmd_grt_vec[i] = 1'b1;
            end
            else begin:i_is_not_0
                assign i_bus_icb_cmd_grt_vec[i] = ~(|i_bus_icb_cmd_valid[i-1:0]);
            end
            assign i_bus_icb_cmd_sel[i] = i_bus_icb_cmd_grt_vec[i] & i_bus_icb_cmd_valid[i];
        end

        always @(*)begin: sel_o_apb_cmd_ready_PROC
            sel_o_icb_cmd_read = {1   {1'b0}};
            sel_o_icb_cmd_addr = {AW  {1'b0}};
            sel_o_icb_cmd_wdata= {DW  {1'b0}};
            sel_o_icb_cmd_wmask= {DW/8{1'b0}};
            for (j=0;j<ARBT_NUM;j=j+1)begin
                sel_o_icb_cmd_read = sel_o_icb_cmd_read | ({1   {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_read [j]);
                sel_o_icb_cmd_addr = sel_o_icb_cmd_addr | ({AW  {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_addr [j]);
                sel_o_icb_cmd_wdata= sel_o_icb_cmd_wdata| ({DW  {i_bus_icb_cmd_sel[j]}} & i_icb_cmd_wdata[j]);
                sel_o_icb_cmd_wmask= sel_o_icb_cmd_wmask| ({DW/8{i_bus_icb_cmd_sel[j]}} & i_icb_cmd_wmask[j]);
            end
        end

        assign o_icb_cmd_valid_real = |i_bus_icb_cmd_valid; 

        always @(*) begin:i_arbt_indic_proc
            i_arbt_indic_id = {ARBT_PTR_W{1'b0}};
            for(j=0;j<ARBT_NUM;j=j+1)begin
                i_arbt_indic_id = i_arbt_indic_id | {ARBT_PTR_W{i_bus_icb_cmd_sel[j]}} & $unsigned(j);
            end
        end

        assign rspid_fifo_wen = o_icb_cmd_valid & o_icb_cmd_ready;
        assign rspid_fifo_ren = o_icb_rsp_valid & o_icb_rsp_ready;

        assign rspid_fifo_bypass    = 1'b0;
        assign o_icb_rsp_port_id    = rspid_fifo_empty ? {ARBT_PTR_W{1'b0}} : rspid_fifo_rdat;
        assign o_icb_rsp_valid_pre  = (~rspid_fifo_empty) & o_icb_rsp_valid;
        assign o_icb_rsp_ready      = (~rspid_fifo_empty) & o_icb_rsp_ready_pre;

        assign rspid_fifo_i_valid = rspid_fifo_wen & (~rspid_fifo_bypass);
        assign rspid_fifo_full    = (~rspid_fifo_i_ready);
        assign rspid_fifo_o_ready = rspid_fifo_ren & (~rspid_fifo_bypass);
        assign rspid_fifo_empty   = (~rspid_fifo_o_valid);

        assign rspid_fifo_wdat = i_arbt_indic_id;

        if (FIFO_OUTS_NUM == 1) begin:dp_1
            HiCore_pipe # (
              .CUT_READY(0),
              .DW(ARBT_PTR_W)
            ) split_fifo(
              .i_vld(rspid_fifo_i_valid), 
              .i_rdy(rspid_fifo_i_ready), 
              .i_dat(rspid_fifo_wdat),
              .i_cancel(1'b0),
              .o_vld(rspid_fifo_o_valid), 
              .o_rdy(rspid_fifo_o_ready), 
              .o_dat(rspid_fifo_rdat),
              .o_cancel(),

              .branch(1'b0),

              .clk(clk),
              .rst_n(rst_n)
            );
        end
        else begin: dp_gt1
            HiCore_queue#(
              .DW(ARBT_PTR_W),
              .DP(FIFO_OUTS_NUM),
              .LOGDP($clog2(FIFO_OUTS_NUM+1)-1)
            )arbt_queue(
              .i_valid(rspid_fifo_i_valid),
              .i_ready(rspid_fifo_i_ready),
              .i_cancel(1'b0),
              .i_info(rspid_fifo_wdat),
              .o_valid(rspid_fifo_o_valid),
              .o_ready(rspid_fifo_o_ready),
              .o_cancel(),
              .o_info(rspid_fifo_rdat),

              .flush(1'b0),

              .clk(clk),
              .rst_n(rst_n)
            );
        end

        assign o_icb_cmd_read = sel_o_icb_cmd_read;
        assign o_icb_cmd_addr  = sel_o_icb_cmd_addr ; 
        assign o_icb_cmd_wdata = sel_o_icb_cmd_wdata; 
        assign o_icb_cmd_wmask = sel_o_icb_cmd_wmask;

        assign o_icb_rsp_ready_pre = i_bus_icb_rsp_ready[o_icb_rsp_port_id];

        assign i_bus_icb_rsp_err  = {ARBT_NUM{o_icb_rsp_err}};
        assign i_bus_icb_rsp_rdata= {ARBT_NUM{o_icb_rsp_rdata}};
    end
endgenerate

endmodule
