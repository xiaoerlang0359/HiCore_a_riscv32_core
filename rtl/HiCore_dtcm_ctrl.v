module  HiCore_dtcm_ctrl#(
    parameter DW=32,
    parameter RAM_DEPTH=14
)(
// dtcm icb interface
    input  mem_icb_cmd_valid,
    output mem_icb_cmd_ready,
    input  mem_icb_cmd_read,
    input  [`HiCore_ADDR_SIZE-1:0] mem_icb_cmd_addr,
    input  [`HiCore_REG_SIZE-1:0] mem_icb_cmd_wdata,
    input  [`HiCore_REG_SIZE/8-1:0] mem_icb_cmd_wmask,
    
    output mem_icb_rsp_valid,
    input  mem_icb_rsp_ready,
    output mem_icb_rsp_err,
    output [`HiCore_REG_SIZE-1:0] mem_icb_rsp_rdata,
// system interface
    input  clk,
    input  rst_n
);
// dtcm
wire [RAM_DEPTH-1:0] addra = mem_icb_cmd_addr[RAM_DEPTH+1:2];
wire [DW-1:0] dina = mem_icb_cmd_wdata;
wire [DW/8-1:0] wea = {4{~mem_icb_cmd_read}} & mem_icb_cmd_wmask;
wire [DW-1:0] douta;
wire ena = mem_icb_cmd_valid & mem_icb_cmd_ready;

dtcm_ram udtcm_ram(
.addra(addra),
.clka(clk),
.dina(dina),
.douta(douta),
.ena(ena),
.wea(wea)
);
// pipe
wire i_dat=1'b1;
HiCore_pipe#(
    .CUT_READY(0),
    .DW(1)
)dtcm_pipe(
.i_vld(mem_icb_cmd_valid),
.i_rdy(mem_icb_cmd_ready),
.i_dat(i_dat),
.i_cancel(1'b0),
.o_vld(mem_icb_rsp_valid),
.o_rdy(mem_icb_rsp_ready),
.o_dat(),
.o_cancel(),

.branch(1'b0),

.clk(clk),
.rst_n(rst_n)
);
// rsp channel
assign mem_icb_rsp_err = 1'b0;
assign mem_icb_rsp_rdata = douta;
// NOTE: douta need to keep its value when the ram is not enable
endmodule
