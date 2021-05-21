`include "config.v"
module HiCore_csr(
    // disp interface
    input  i_issue2csr_valid,
    output i_issue2csr_ready,
    input  i_issue2csr_cancel,
    input  [`HiCore_REG_SIZE-1:0] csr_reg_src,
    input  [`HiCore_CSRIDX_WIDTH-1:0] csr_idx,
    input  [2:0] csr_msg,
    input  [`HiCore_ISSUE2ALU_SIZE-1:0] csr_info,
    // wb interface
    output rob_wb_wen,
    output [`HiCore_ROB_PTR_SIZE-1:0] rob_wb_ptr,
    output [`HiCore_REG_SIZE-1:0] rob_wb_rd_data,
    output [`HiCore_REG_SIZE-1:0] rob_wb_csr_data,
    output [`HiCore_WB_SIZE-1:0] rob_wb_info,
    // commit interface
    input  commit_valid,
    input  [`HiCore_EXCP_SIZE-1:0] commit_excp,
    input  [`HiCore_IRQ_SIZE-1:0] commit_irq,
    input  [`HiCore_PC_SIZE-1:0] commit_pc,
    input  [`HiCore_PC_SIZE-1:0] commit_next_pc,
    input  commit_csr_need,
    input  [`HiCore_CSRIDX_WIDTH-1:0] commit_csr_idx,
    input  [`HiCore_REG_SIZE-1:0] commit_csr_data,
    input  commit_mret_op,
    input  flush,
    output [`HiCore_IRQ_SIZE-1:0] irq_msk,
    output [`HiCore_REG_SIZE-1:0] csr_mepc,
    output [`HiCore_REG_SIZE-1:0] csr_mtvec,
    // irq interface
    input  ext_irq,
    input  sft_irq,
    input  tmr_irq,
    // system interface
    input  clk,
    input  rst_n
);

localparam fflags_idx   = 12'h001;//
localparam frm_idx      = 12'h002;//
localparam fcsr_idx     = 12'h003;//
localparam mstatus_idx  = 12'h300;//
localparam misa_idx     = 12'h301;//
localparam mie_idx      = 12'h304;//
localparam mtvec_idx    = 12'h305;//
localparam mscratch_idx = 12'h340;//
localparam mepc_idx     = 12'h341;
localparam mcause_idx   = 12'h342;
localparam mtval_idx    = 12'h343;
localparam mip_idx      = 12'h344;//
localparam mcycle_idx   = 12'hB00;//
localparam mcycleh_idx  = 12'hB80;//
localparam minstret_idx = 12'hB02;//
localparam minstreth_idx= 12'hB82;//
localparam mvendorid_idx= 12'hF11;//
localparam marchid_idx  = 12'hF12;//
localparam mimpid_idx   = 12'hF13;//
localparam mhartid_idx  = 12'hF14;//

localparam fflags_w   = 1'b1;
localparam frm_w      = 1'b1;
localparam fcsr_w     = 1'b1;
localparam mstatus_w  = 1'b1;//
localparam misa_w     = 1'b0;//
localparam mie_w      = 1'b1;//
localparam mtvec_w    = 1'b1;//
localparam mscratch_w = 1'b1;//
localparam mepc_w     = 1'b1;//
localparam mcause_w   = 1'b1;//
localparam mtval_w    = 1'b1;//
localparam mip_w      = 1'b0;//
localparam mcycle_w   = 1'b1;//
localparam mcycleh_w  = 1'b1;//
localparam minstret_w = 1'b1;//
localparam minstreth_w= 1'b1;//
localparam mvendorid_w= 1'b1;//
localparam marchid_w  = 1'b0;//
localparam mimpid_w   = 1'b0;//
localparam mhartid_w  = 1'b0;//

//////////////////////////////////////////////////
// issue interface
//////////////////////////////////////////////////
wire csr_rd_en;
wire [`HiCore_REG_SIZE-1:0] csr_rdata;
wire [`HiCore_REG_SIZE-1:0] csr_wdata;


assign csr_wdata= ({`HiCore_REG_SIZE{csr_msg==3'b001}} & csr_reg_src) |
                   ({`HiCore_REG_SIZE{csr_msg==3'b010}} & (csr_rdata | csr_reg_src)) |
                   ({`HiCore_REG_SIZE{csr_msg==3'b011}} & (csr_rdata & (~csr_reg_src))) |
                   ({`HiCore_REG_SIZE{csr_msg==3'b101}} & csr_reg_src) |
                   ({`HiCore_REG_SIZE{csr_msg==3'b110}} & (csr_rdata | csr_reg_src)) |
                   ({`HiCore_REG_SIZE{csr_msg==3'b111}} & (csr_rdata & (~csr_reg_src)));
assign csr_rd_en = i_issue2csr_valid & i_issue2csr_ready & (~i_issue2csr_cancel);
///////////////////////////////////////////////////
// commit interface
///////////////////////////////////////////////////
wire excp_en = (|commit_excp) & commit_valid;
wire irq_en = (|commit_irq) & commit_valid;
wire csr_wr_en;
assign csr_wr_en = commit_valid & commit_csr_need & (~excp_en);

wire sel_misa;
wire rd_misa;
wire [`HiCore_REG_SIZE-1:0] misa_r;
assign sel_misa = (csr_idx==misa_idx);
assign rd_misa  = sel_misa & csr_rd_en;
assign misa_r   = `HiCore_REG_SIZE'h8000_0100;

wire sel_mvendorid;
wire rd_mvendorid;
wire [`HiCore_REG_SIZE-1:0] mvendorid_r;
assign sel_mvendorid = (csr_idx == mvendorid_idx);
assign rd_mvendorid  = sel_mvendorid & csr_rd_en; 
assign mvendorid_r   = `HiCore_REG_SIZE'd0;

wire sel_marchid;
wire rd_marchid;
wire [`HiCore_REG_SIZE-1:0] marchid_r;
assign sel_marchid= (csr_idx == marchid_idx);
assign rd_marchid = sel_marchid & csr_rd_en;
assign marchid_r  = `HiCore_REG_SIZE'h0000_0005;

wire sel_mimpid;
wire rd_mimpid;
wire [`HiCore_REG_SIZE-1:0] mimpid_r;
assign sel_mimpid= (csr_idx == mimpid_idx);
assign rd_mimpid = sel_mimpid & csr_rd_en;
assign mimpid_r  = `HiCore_REG_SIZE'h0000_0000;

wire sel_mhartid;
wire rd_mhartid;
wire [`HiCore_REG_SIZE-1:0] mhartid_r;
assign sel_mhartid= (csr_idx == mhartid_idx);
assign rd_mhartid = sel_mhartid & csr_rd_en;
assign mhartid_r  = `HiCore_REG_SIZE'h0000_0000;
/////////////////////////////////////////////////
// mstatus reg
/////////////////////////////////////////////////
wire rd_mstatus;
wire wr_mstatus;
assign rd_mstatus  = (csr_idx==mstatus_idx) & csr_rd_en;
assign wr_mstatus  = (commit_csr_idx == mstatus_idx) & csr_wr_en;

wire status_mie_r;
wire status_mpie_r;
wire status_mie_ena;
wire status_mie_nxt;
assign status_mie_ena = wr_mstatus | commit_mret_op | excp_en | irq_en;
assign status_mie_nxt = (excp_en|irq_en) ? 1'b0:
                        (commit_mret_op) ? status_mpie_r:
                        (wr_mstatus)      ? commit_csr_data[3]: status_mie_r;
gnrl_dfflr #(1) status_mie_dfflr (status_mie_ena, status_mie_nxt, status_mie_r, clk, rst_n);

wire status_mpie_ena;
wire status_mpie_nxt;
assign status_mpie_ena = status_mie_ena;
assign status_mpie_nxt = (excp_en|irq_en) ? status_mie_r:
                         (commit_mret_op) ? 1'b1:
                         (wr_mstatus)      ? commit_csr_data[7]: status_mpie_r;
gnrl_dfflr #(1) status_mpie_dfflr (status_mpie_ena, status_mpie_nxt, status_mpie_r, clk, rst_n);

wire [1:0] status_fs_r;
wire [1:0] status_xs_r;
wire status_sd_r;
assign status_fs_r = 2'b0;
assign status_xs_r = 2'b0;
assign status_sd_r = (status_fs_r == 2'b11) | (status_xs_r == 2'b11);

wire [`HiCore_REG_SIZE-1:0] mstatus_r;
assign mstatus_r[31]    = status_sd_r;                        //SD
assign mstatus_r[30:23] = 8'b0; // Reserved
assign mstatus_r[22:17] = 6'b0;               // TSR--MPRV
assign mstatus_r[16:15] = status_xs_r;                        // XS
assign mstatus_r[14:13] = status_fs_r;                        // FS
assign mstatus_r[12:11] = 2'b11;              // MPP 
assign mstatus_r[10:9]  = 2'b0; // Reserved
assign mstatus_r[8]     = 1'b0;               // SPP
assign mstatus_r[7]     = status_mpie_r;                      // MPIE
assign mstatus_r[6]     = 1'b0; // Reserved
assign mstatus_r[5]     = 1'b0;               // SPIE 
assign mstatus_r[4]     = 1'b0;               // UPIE 
assign mstatus_r[3]     = status_mie_r;                       // MIE
assign mstatus_r[2]     = 1'b0; // Reserved
assign mstatus_r[1]     = 1'b0;               // SIE 
assign mstatus_r[0]     = 1'b0;               // UIE 
/////////////////////////////////////////////////
// mie reg
/////////////////////////////////////////////////
wire rd_mie  = (csr_idx == mie_idx) & csr_rd_en;
wire wr_mie  = (commit_csr_idx == mie_idx) & csr_wr_en;
wire [`HiCore_REG_SIZE-1:0] mie_r;
wire [`HiCore_REG_SIZE-1:0] mie_nxt;
assign mie_nxt[31:12] = 20'b0;
assign mie_nxt[11]    = commit_csr_data[11];//MEIE
assign mie_nxt[10:8]  = 3'b0;
assign mie_nxt[7]     = commit_csr_data[7]; //MTIE
assign mie_nxt[6:4]   = 3'b0;
assign mie_nxt[3]     = commit_csr_data[3]; //MSIE
assign mie_nxt[2:0]   = 3'b0;
gnrl_dfflr #(`HiCore_REG_SIZE) mie_dfflr (wr_mie, mie_nxt, mie_r, clk, rst_n);
/////////////////////////////////////////////////
// mip reg
/////////////////////////////////////////////////
wire [`HiCore_REG_SIZE-1:0] mip_r;
wire sel_mip = (csr_idx == mip_idx);
wire rd_mip  = sel_mip & csr_rd_en;
wire meip_r;
wire msip_r;
wire mtip_r;

gnrl_dffr #(1) meip_dffr (ext_irq, meip_r, clk, rst_n);
gnrl_dffr #(1) msip_dffr (sft_irq, msip_r, clk, rst_n);
gnrl_dffr #(1) mtip_dffr (tmr_irq, mtip_r, clk, rst_n);
assign mip_r[31:12] = 20'b0;
assign mip_r[11]    = meip_r;
assign mip_r[10:8]  = 3'b0;
assign mip_r[7]     = mtip_r;
assign mip_r[6:4]   = 3'b0;
assign mip_r[3]     = msip_r;
assign mip_r[2:0]   = 3'b0;
/////////////////////////////////////////////////
// mtvec reg
/////////////////////////////////////////////////
wire rd_mtvec  = (csr_idx==mtvec_idx) & csr_rd_en;
wire wr_mtvec  = (commit_csr_idx==mtvec_idx) & csr_wr_en;
wire [`HiCore_REG_SIZE-1:0] mtvec_r;
wire [`HiCore_REG_SIZE-1:0] mtvec_nxt;
assign mtvec_nxt = commit_csr_data;
gnrl_dfflr #(`HiCore_REG_SIZE) mtvec_dfflr(wr_mtvec,mtvec_nxt,mtvec_r,clk,rst_n);
/////////////////////////////////////////////////
// mscratch reg
/////////////////////////////////////////////////
wire rd_mscratch  = (csr_idx == mscratch_idx) & csr_rd_en;
wire wr_mscratch  = (commit_csr_idx == mscratch_idx) & csr_wr_en;
wire [`HiCore_REG_SIZE-1:0] mscratch_r;
wire [`HiCore_REG_SIZE-1:0] mscratch_nxt = commit_csr_data;
gnrl_dfflr #(`HiCore_REG_SIZE) mscratch_dfflr(wr_mscratch, mscratch_nxt,mscratch_r,clk,rst_n);
/////////////////////////////////////////////////
// mcycle reg
/////////////////////////////////////////////////
wire [`HiCore_REG_SIZE-1:0] mcycle_r;
wire [`HiCore_REG_SIZE-1:0] mcycleh_r;
wire rd_mcycle   = (csr_idx==mcycle_idx)  & csr_rd_en;
wire rd_mcycleh  = (csr_idx==mcycleh_idx) & csr_rd_en;
wire wr_mcycle   = (commit_csr_idx==mcycle_idx) & csr_wr_en;
wire wr_mcycleh  = (commit_csr_idx==mcycleh_idx) & csr_wr_en;
wire mcycleh_ena = wr_mcycleh | (mcycle_r=={`HiCore_REG_SIZE{1'b1}});
wire [`HiCore_REG_SIZE-1:0] mcycle_nxt = (wr_mcycle)? commit_csr_data: (mcycle_r  + 1'b1);
wire [`HiCore_REG_SIZE-1:0] mcycleh_nxt= (wr_mcycleh) ? commit_csr_data: (mcycleh_r + 1'b1);
gnrl_dffr #(`HiCore_REG_SIZE) mcycle_dffr (mcycle_nxt, mcycle_r, clk, rst_n);
gnrl_dfflr #(`HiCore_REG_SIZE) mcycleh_dfflr(mcycleh_ena,mcycleh_nxt,mcycleh_r,clk, rst_n);
/////////////////////////////////////////////////
// minstret reg
/////////////////////////////////////////////////
wire rd_minstret   = (csr_idx == minstret_idx)  & csr_rd_en;
wire rd_minstreth  = (csr_idx == minstreth_idx) & csr_rd_en;
wire [`HiCore_REG_SIZE-1:0] minstret_r;
wire [`HiCore_REG_SIZE-1:0] minstreth_r;
wire wr_minstret   = (commit_csr_idx == minstret_idx)  & csr_wr_en;
wire wr_minstreth  = (commit_csr_idx == minstreth_idx) & csr_wr_en; 
wire minstret_ena  = wr_minstret | commit_valid;
wire minstreth_ena = wr_minstreth | (commit_valid & (minstret_r=={`HiCore_REG_SIZE{1'b1}})); 
wire [`HiCore_REG_SIZE-1:0] minstret_nxt  = (wr_minstret)  ? commit_csr_data : (minstret_r + 1'b1); 
wire [`HiCore_REG_SIZE-1:0] minstreth_nxt = (wr_minstreth) ? commit_csr_data : (minstreth_r+ 1'b1);
gnrl_dfflr #(`HiCore_REG_SIZE) minstret_dfflr (minstret_ena, minstret_nxt, minstret_r, clk, rst_n);
gnrl_dfflr #(`HiCore_REG_SIZE) minstreth_dfflr(minstreth_ena,minstreth_nxt,minstreth_r,clk, rst_n);
////////////////////////////////////////////////
// mtval reg
////////////////////////////////////////////////
wire sel_mtval = (csr_idx == mtval_idx);
wire rd_mtval  = sel_mtval & csr_rd_en;
wire mtval_ena = excp_en;
wire [`HiCore_REG_SIZE-1:0] mtval_r;
wire [`HiCore_REG_SIZE-1:0] mtval_nxt;
assign mtval_nxt = commit_pc; // TODO: need to refresh as other value
gnrl_dfflr #(`HiCore_REG_SIZE) mtval_dfflr (mtval_ena, mtval_nxt, mtval_r, clk, rst_n);
////////////////////////////////////////////////
// mepc reg
////////////////////////////////////////////////
wire sel_mepc = (csr_idx == mepc_idx);
wire rd_mepc  = sel_mepc & csr_rd_en;
wire wr_mepc  = (commit_csr_idx == mepc_idx) & csr_wr_en;
wire mepc_ena = excp_en | irq_en | wr_mepc;
wire [`HiCore_REG_SIZE-1:0] mepc_r;
wire [`HiCore_REG_SIZE-1:0] mepc_nxt;
assign mepc_nxt = (excp_en)? commit_pc: 
                  (irq_en) ? commit_next_pc: commit_csr_data;
gnrl_dfflr #(`HiCore_REG_SIZE) mepc_dfflr (mepc_ena, mepc_nxt, mepc_r, clk, rst_n);
////////////////////////////////////////////////
// mcause reg
////////////////////////////////////////////////
wire [3:0] excp_idx;
wire [3:0] irq_idx;
wire [7:0] excp_data_8;
wire [3:0] excp_data_4;
wire [1:0] excp_data_2;
wire [7:0] irq_data_8;
wire [3:0] irq_data_4;
wire [1:0] irq_data_2;
assign excp_idx[3] = ~|commit_excp[7:0];
assign excp_data_8 = (excp_idx[3])? commit_excp[15:8]:commit_excp[7:0];
assign excp_idx[2] = ~|excp_data_8[3:0];
assign excp_data_4 = (excp_idx[2])? excp_data_8[7:4]:excp_data_8[3:0];
assign excp_idx[1] = ~|excp_data_4[1:0];
assign excp_data_2 = (excp_idx[1])? excp_data_4[3:2]:excp_data_4[1:0];
assign excp_idx[0] = ~excp_data_2[0];
assign irq_idx[3] = ~|commit_irq[7:0];
assign irq_data_8 = (irq_idx[3])? {4'd0,commit_irq[11:8]}:commit_irq[7:0];
assign irq_idx[2] = ~|irq_data_8[3:0];
assign irq_data_4 = (irq_idx[2])? irq_data_8[7:4]:irq_data_8[3:0];
assign irq_idx[1] = ~|irq_data_4[1:0];
assign irq_data_2 = (irq_idx[1])? irq_data_4[3:2]:irq_data_4[1:0];
assign irq_idx[0] = ~irq_data_2[0];

wire sel_mcause = (csr_idx == mcause_idx);
wire rd_mcause  = sel_mcause & csr_rd_en;
wire mcause_ena = excp_en | irq_en;
wire [`HiCore_REG_SIZE-1:0] mcause_r;
wire [`HiCore_REG_SIZE-1:0] mcause_nxt;
assign mcause_nxt[31]   = (excp_en)? 1'b0:1'b1;
assign mcause_nxt[30:4] = 27'b0;
assign mcause_nxt[3:0]  = (excp_en)? excp_idx: irq_idx;
gnrl_dfflr #(`HiCore_REG_SIZE) mcause_dfflr (mcause_ena, mcause_nxt, mcause_r, clk, rst_n);

assign csr_rdata = ({`HiCore_REG_SIZE{rd_mstatus}}  & mstatus_r)  |
                   ({`HiCore_REG_SIZE{rd_mie}}      & mie_r)      |
                   ({`HiCore_REG_SIZE{rd_mtvec}}    & mtvec_r)    |
                   ({`HiCore_REG_SIZE{rd_mepc}}     & mepc_r)     |
                   ({`HiCore_REG_SIZE{rd_mscratch}} & mscratch_r) |
                   ({`HiCore_REG_SIZE{rd_mcause}}   & mcause_r)   |
                   ({`HiCore_REG_SIZE{rd_mtval}}    & mtval_r)    |
                   ({`HiCore_REG_SIZE{rd_mip}}      & mip_r)      |
                   ({`HiCore_REG_SIZE{rd_misa}}     & misa_r)     |
                   ({`HiCore_REG_SIZE{rd_mvendorid}}& mvendorid_r)|
                   ({`HiCore_REG_SIZE{rd_marchid}}  & marchid_r)  |
                   ({`HiCore_REG_SIZE{rd_mimpid}}   & mimpid_r)   |
                   ({`HiCore_REG_SIZE{rd_mhartid}}  & mhartid_r)  |
                   ({`HiCore_REG_SIZE{rd_mcycle}}   & mcycle_r)   |
                   ({`HiCore_REG_SIZE{rd_mcycleh}}  & mcycleh_r)  |
                   ({`HiCore_REG_SIZE{rd_minstret}} & minstret_r) |
                   ({`HiCore_REG_SIZE{rd_minstreth}}& minstreth_r);

// commit interface
assign csr_mepc          = mepc_r;
assign csr_mtvec         = mtvec_r;
assign irq_msk = {`HiCore_IRQ_SIZE{status_mie_r}} & mie_r[`HiCore_IRQ_SIZE-1:0];
/////////////////////////////////////////////
// csr2wb pipeline
/////////////////////////////////////////////
wire [`HiCore_CSR2WB_SIZE-1:0] i_csr2wb_info;
wire [`HiCore_CSR2WB_SIZE-1:0] o_csr2wb_info;
wire o_csr2wb_valid;
wire o_csr2wb_ready = 1'b1;
wire o_csr2wb_cancel;
assign i_csr2wb_info = {csr_wdata,csr_rdata,csr_info};

HiCore_pipe # (
  .CUT_READY(0),
  .DW(`HiCore_CSR2WB_SIZE)
) csr2wb_pipe(
  .i_vld(i_issue2csr_valid), 
  .i_rdy(i_issue2csr_ready), 
  .i_dat(i_csr2wb_info),
  .i_cancel(i_issue2csr_cancel),
  .o_vld(o_csr2wb_valid), 
  .o_rdy(o_csr2wb_ready), 
  .o_dat(o_csr2wb_info),
  .o_cancel(o_csr2wb_cancel),

  .branch(flush),

  .clk(clk),
  .rst_n(rst_n)
);
//////////////////////////////////////////////////////
// write back interface
//////////////////////////////////////////////////////
assign rob_wb_wen = o_csr2wb_valid & o_csr2wb_ready & (~o_csr2wb_cancel) & (~flush);
assign {rob_wb_csr_data,rob_wb_rd_data,rob_wb_ptr,rob_wb_info} = o_csr2wb_info;

endmodule
