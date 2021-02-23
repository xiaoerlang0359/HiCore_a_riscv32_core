module sirv_icb_splt #(
    parameter AW = 32,
    parameter DW = 32,
    // The number of outstanding supported
    parameter FIFO_CUT_READY = 0,
    parameter SPLT_NUM = 4,
    parameter SPLT_PTR_W = 4
)(
    input [SPLT_NUM-1:0] i_icb_splt_indic,

    input                       i_icb_cmd_valid,
    output                      i_icb_cmd_ready,
    input                       i_icb_cmd_read,
    input  [AW-1:0]             i_icb_cmd_addr,
    input  [DW-1:0]             i_icb_cmd_wdata,
    input  [DW/8-1:0]           i_icb_cmd_wmask,

    output                      i_icb_rsp_valid,
    input                       i_icb_rsp_ready,
    output                      i_icb_rsp_err,
    output [DW-1:0]             i_icb_rsp_rdata,

    input  [SPLT_NUM*1-1:0]     o_bus_icb_cmd_ready,
    output [SPLT_NUM*1-1:0]     o_bus_icb_cmd_valid,
    output [SPLT_NUM*1-1:0]     o_bus_icb_cmd_read,
    output [SPLT_NUM*AW-1:0]    o_bus_icb_cmd_addr,
    output [SPLT_NUM*DW-1:0]    o_bus_icb_cmd_wdata,
    output [SPLT_NUM*DW/8-1:0]  o_bus_icb_cmd_wmask,

    input  [SPLT_NUM*1-1:0]     o_bus_icb_rsp_valid,
    output [SPLT_NUM*1-1:0]     o_bus_icb_rsp_ready,
    input  [SPLT_NUM*1-1:0]     o_bus_icb_rsp_err,
    input  [SPLT_NUM*DW-1:0]    o_bus_icb_rsp_rdata,

    input                       clk,
    input                       rst_n
);

integer j;

wire [SPLT_NUM-1:0] o_icb_cmd_valid;
wire [SPLT_NUM-1:0] o_icb_cmd_ready;

wire [1-1:0]        o_icb_cmd_read [SPLT_NUM-1:0];
wire [AW-1:0]       o_icb_cmd_addr [SPLT_NUM-1:0];
wire [DW-1:0]       o_icb_cmd_wdata[SPLT_NUM-1:0];
wire [DW/8-1:0]     o_icb_cmd_wmask[SPLT_NUM-1:0];

wire [SPLT_NUM-1:0] o_icb_rsp_valid;
wire [SPLT_NUM-1:0] o_icb_rsp_ready;
wire [SPLT_NUM-1:0] o_icb_rsp_err;
wire [DW-1:0]       o_icb_rsp_rdata [SPLT_NUM-1:0];

reg  sel_o_icb_cmd_ready;

wire rspid_fifo_bypass;
wire rspid_fifo_wen;
wire rspid_fifo_ren;

wire [SPLT_PTR_W-1:0] o_icb_rsp_port_id;

wire rspid_fifo_i_valid;
wire rspid_fifo_o_valid;
wire rspid_fifo_i_ready;
wire rspid_fifo_o_ready;
wire [SPLT_PTR_W-1:0] rspid_fifo_rdat;
wire [SPLT_PTR_W-1:0] rspid_fifo_wdat;

wire rspid_fifo_full;
wire rspid_fifo_empty;
reg  [SPLT_PTR_W-1:0] i_splt_indic_id;

wire i_icb_cmd_ready_pre;
wire i_icb_cmd_valid_pre;

wire i_icb_rsp_ready_pre;
wire i_icb_rsp_valid_pre;

genvar i;
generate
    if (SPLT_NUM ==1) begin:splt_num_eq_1_gen
        assign i_icb_cmd_ready     = o_bus_icb_cmd_ready;
        assign o_bus_icb_cmd_valid = i_icb_cmd_valid;
        assign o_bus_icb_cmd_read  = i_icb_cmd_read;
        assign o_bus_icb_cmd_addr  = i_icb_cmd_addr;
        assign o_bus_icb_cmd_wdata = i_icb_cmd_wdata;
        assign o_bus_icb_cmd_wmask = i_icb_cmd_wmask;

        assign o_bus_icb_rsp_ready = i_icb_rsp_ready;
        assign i_icb_rsp_valid     = o_bus_icb_rsp_valid;
        assign i_icb_rsp_err       = o_bus_icb_rsp_err;
        assign i_icb_rsp_rdata     = o_bus_icb_rsp_rdata;
    end
    else begin:splt_num_gt_1_gen
        for(i=0; i< SPLT_NUM; i=i+1)
        begin: icb_distract_gen
            assign o_icb_cmd_ready[i]                             = o_bus_icb_cmd_ready[(i+1)*1     -1 : (i)*1     ]; 
            assign o_bus_icb_cmd_valid[(i+1)*1     -1 : i*1     ] = o_icb_cmd_valid[i];
            assign o_bus_icb_cmd_read [(i+1)*1     -1 : i*1     ] = o_icb_cmd_read [i];
            assign o_bus_icb_cmd_addr [(i+1)*AW    -1 : i*AW    ] = o_icb_cmd_addr [i];
            assign o_bus_icb_cmd_wdata[(i+1)*DW    -1 : i*DW    ] = o_icb_cmd_wdata[i];
            assign o_bus_icb_cmd_wmask[(i+1)*(DW/8)-1 : i*(DW/8)] = o_icb_cmd_wmask[i];
            
            assign o_bus_icb_rsp_ready[(i+1)*1-1 :i*1 ] = o_icb_rsp_ready[i]; 
            assign o_icb_rsp_valid[i]                   = o_bus_icb_rsp_valid[(i+1)*1-1 :i*1 ]; 
            assign o_icb_rsp_err  [i]                   = o_bus_icb_rsp_err  [(i+1)*1-1 :i*1 ];
            assign o_icb_rsp_rdata[i]                   = o_bus_icb_rsp_rdata[(i+1)*DW-1:i*DW];
        end

        always @(*) begin: sel_o_icb_cmd_ready_proc
            sel_o_icb_cmd_ready = 1'b0;
            for (j=0;j<SPLT_NUM;j=j+1) begin
                sel_o_icb_cmd_ready = sel_o_icb_cmd_ready | (i_icb_splt_indic[j] & o_icb_cmd_ready[j]);
            end
        end

        assign i_icb_cmd_ready_pre = sel_o_icb_cmd_ready;
        
        wire cmd_diff_branch = (~rspid_fifo_empty) & (rspid_fifo_wdat != rspid_fifo_rdat);
        assign i_icb_cmd_valid_pre = i_icb_cmd_valid & (~cmd_diff_branch) & (~rspid_fifo_full);
        assign i_icb_cmd_ready     = i_icb_cmd_ready_pre & (~cmd_diff_branch) & (~rspid_fifo_full);

        assign rspid_fifo_wen = i_icb_cmd_valid & i_icb_cmd_ready;
        assign rspid_fifo_ren = i_icb_rsp_valid & i_icb_rsp_ready;

        assign rspid_fifo_bypass  = 1'b0;
        assign o_icb_rsp_port_id  = rspid_fifo_empty? {SPLT_PTR_W{1'b0}}:rspid_fifo_rdat;
        assign i_icb_rsp_valid    = (~rspid_fifo_empty) & i_icb_rsp_valid_pre;
        assign i_icb_rsp_ready_pre= (~rspid_fifo_empty) & i_icb_rsp_ready;

        assign rspid_fifo_i_valid = rspid_fifo_wen & (~rspid_fifo_bypass);
        assign rspid_fifo_full    = (~rspid_fifo_i_ready);
        assign rspid_fifo_o_ready = rspid_fifo_ren & (~rspid_fifo_bypass);
        assign rspid_fifo_empty   = (~rspid_fifo_o_valid);

        assign rspid_fifo_wdat = i_icb_splt_indic;

        HiCore_pipe # (
          .CUT_READY(0),
          .DW(SPLT_NUM)
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
        for (i=0;i<SPLT_NUM;i=i+1)
        begin: o_icb_cmd_valid_gen
            assign o_icb_cmd_valid[i] = i_icb_splt_indic[i] & i_icb_cmd_valid_pre;
            assign o_icb_cmd_read [i] = i_icb_cmd_read;
            assign o_icb_cmd_wdata[i] = i_icb_cmd_wdata;
            assign o_icb_cmd_addr [i] = i_icb_cmd_addr;
            assign o_icb_cmd_wmask[i] = i_icb_cmd_wmask;
        end
        for (i=0; i<SPLT_NUM;i=i+1)
        begin: o_icb_rsp_ready_gen
            assign o_icb_rsp_ready[i] = (o_icb_rsp_port_id[i] & i_icb_rsp_ready_pre);
        end
        assign i_icb_rsp_valid_pre = |(o_icb_rsp_valid & o_icb_rsp_port_id);

        reg sel_i_icb_rsp_err;
        reg [DW-1:0] sel_i_icb_rsp_rdata;

        always @(*)begin: sel_icb_rsp_PROC
            sel_i_icb_rsp_err = 1'b0;
            sel_i_icb_rsp_rdata = {DW{1'b0}};
            for (j=0;j<SPLT_NUM;j=j+1)begin
                sel_i_icb_rsp_err  = sel_i_icb_rsp_err  | (    o_icb_rsp_port_id[j]  & o_icb_rsp_err[i]);
                sel_i_icb_rsp_rdata= sel_i_icb_rsp_rdata| ({DW{o_icb_rsp_port_id[j]}}& o_icb_rsp_rdata[j]);
            end
        end
        assign i_icb_rsp_err = sel_i_icb_rsp_err;
        assign i_icb_rsp_rdata = sel_i_icb_rsp_rdata;
    end
endgenerate

endmodule
