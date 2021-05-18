module ifetch_sram_ctrl #(
    parameter DW=32,
    parameter RAM_DEPTH=14
)(
// itcm interface
input                           icache_icb_cmd_valid,
output                          icache_icb_cmd_ready,
input                           icache_icb_cmd_read,
input  [`HiCore_ADDR_SIZE-1:0]  icache_icb_cmd_addr,
input  [`HiCore_PC_SIZE-1:0]    icache_icb_cmd_wdata,
input  [`HiCore_INT_SIZE/8-1:0] icache_icb_cmd_wmask,

input                           icache_icb_rsp_ready,
output                          icache_icb_rsp_valid,
output [`HiCore_IF2DE_SIZE-1:0]   icache_icb_rsp_rdata,
output                          icache_icb_rsp_cancel,
// flush interface
input                           flush,
input                           branch,
// system interface
input                           clk,
input                           rst_n
);
// itcm interface
wire [15:0] excp_code;
assign excp_code[0] = (|icache_icb_cmd_addr[1:0]);
assign excp_code[1] = (icache_icb_cmd_addr[`HiCore_IADDR_REGION]!=`HiCore_IADDR_COMP);
assign excp_code[15:2] = 14'd0;
wire [RAM_DEPTH-1:0] addra = icache_icb_cmd_addr[RAM_DEPTH+1:2];
wire [DW-1:0] dina = 0;
wire [DW-1:0] douta;
wire ena = icache_icb_cmd_valid & icache_icb_cmd_ready & (~excp_code[0]) & (~excp_code[1]);
wire wea = 1'b0;

itcm_ram u_itcm_ram(
.addra(addra),
.clka(clk),
.dina(dina),
.douta(douta),
.ena(ena),
.wea(wea)
);
// pipe stage
wire [`HiCore_ADDR_SIZE+15:0] i_dat = {icache_icb_cmd_addr,excp_code};
wire [`HiCore_ADDR_SIZE+15:0] o_dat;
HiCore_pipe#(
    .CUT_READY(0),
    .DW(`HiCore_ADDR_SIZE+16)
)ifetch_pipe(
.i_vld(icache_icb_cmd_valid),
.i_rdy(icache_icb_cmd_ready),
.i_dat(i_dat),
.i_cancel(1'b0),
.o_vld(icache_icb_rsp_valid),
.o_rdy(icache_icb_rsp_ready),
.o_dat(o_dat),
.o_cancel(icache_icb_rsp_cancel),
    
.branch((flush|branch)),

.clk(clk),
.rst_n(rst_n)    
);

assign icache_icb_rsp_rdata = {douta,o_dat};

endmodule
