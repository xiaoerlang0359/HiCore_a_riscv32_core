module HiCore_biu #(
)(
    input                               i_icb_cmd_valid,
    output                              i_icb_cmd_ready,
    input                               i_icb_cmd_read,
    input  [`HiCore_ADDR_SIZE-1:0]      i_icb_cmd_addr,
    input  [`HiCore_REG_SIZE-1:0]       i_icb_cmd_wdata,
    input  [`HiCore_REG_SIZE/8-1:0]     i_icb_cmd_wmask,

    output                              i_icb_rsp_valid,
    input                               i_icb_rsp_ready,
    output                              i_icb_rsp_err,
    output [`HiCore_REG_SIZE-1:0]       i_icb_rsp_rdata,

    input                               dcache_icb_cmd_ready,
    output                              dcache_icb_cmd_valid,
    output                              dcache_icb_cmd_read,
    output [`HiCore_ADDR_SIZE-1:0]      dcache_icb_cmd_addr,
    output [`HiCore_REG_SIZE-1:0]       dcache_icb_cmd_wdata,
    output [`HiCore_REG_SIZE/8-1:0]     dcache_icb_cmd_wmask,

    input                               dcache_icb_rsp_valid,
    output                              dcache_icb_rsp_ready,
    input                               dcache_icb_rsp_err,
    input  [`HiCore_REG_SIZE-1:0]       dcache_icb_rsp_rdata,

    input                               icache_icb_cmd_ready,
    output                              icache_icb_cmd_valid,
    output                              icache_icb_cmd_read,
    output [`HiCore_ADDR_SIZE-1:0]      icache_icb_cmd_addr,
    output [`HiCore_REG_SIZE-1:0]       icache_icb_cmd_wdata,
    output [`HiCore_REG_SIZE/8-1:0]     icache_icb_cmd_wmask,

    input                               icache_icb_rsp_valid,
    output                              icache_icb_rsp_ready,
    input                               icache_icb_rsp_err,
    input  [`HiCore_REG_SIZE-1:0]       icache_icb_rsp_rdata,  

    input                               plic_icb_cmd_ready,
    output                              plic_icb_cmd_valid,
    output                              plic_icb_cmd_read,
    output [`HiCore_ADDR_SIZE-1:0]      plic_icb_cmd_addr,
    output [`HiCore_REG_SIZE-1:0]       plic_icb_cmd_wdata,
    output [`HiCore_REG_SIZE/8-1:0]     plic_icb_cmd_wmask,

    input                               plic_icb_rsp_valid,
    output                              plic_icb_rsp_ready,
    input                               plic_icb_rsp_err,
    input  [`HiCore_REG_SIZE-1:0]       plic_icb_rsp_rdata, 

    input                               nop_icb_cmd_ready,
    output                              nop_icb_cmd_valid,
    output                              nop_icb_cmd_read,
    output [`HiCore_ADDR_SIZE-1:0]      nop_icb_cmd_addr,
    output [`HiCore_REG_SIZE-1:0]       nop_icb_cmd_wdata,
    output [`HiCore_REG_SIZE/8-1:0]     nop_icb_cmd_wmask,

    input                               nop_icb_rsp_valid,
    output                              nop_icb_rsp_ready,
    input                               nop_icb_rsp_err,
    input  [`HiCore_REG_SIZE-1:0]       nop_icb_rsp_rdata, 

    input                       clk,
    input                       rst_n
);

wire [4-1:0] i_icb_splt_indic;
assign i_icb_splt_indic[0] = (i_icb_cmd_addr[`HiCore_DADDR_REGION]==`HiCore_DADDR_COMP);
assign i_icb_splt_indic[1] = (i_icb_cmd_addr[`HiCore_IADDR_REGION]==`HiCore_IADDR_COMP);
assign i_icb_splt_indic[2] = (i_icb_cmd_addr[`HiCore_PLIC_ADDR_REGION]==`HiCore_PLIC_ADDR_COMP);
assign i_icb_splt_indic[3] = ~(|i_icb_splt_indic[2:0]);

sirv_icb_splt #(
    .AW(`HiCore_ADDR_SIZE),
    .DW(`HiCore_REG_SIZE),
    // The number of outstanding supported
    .FIFO_CUT_READY(0),
    .SPLT_NUM(4),
    .SPLT_PTR_W(4)
)u_icb_bus_splt(
.i_icb_splt_indic(i_icb_splt_indic),

.i_icb_cmd_valid(i_icb_cmd_valid),
.i_icb_cmd_ready(i_icb_cmd_ready),
.i_icb_cmd_read(i_icb_cmd_read),
.i_icb_cmd_addr(i_icb_cmd_addr),
.i_icb_cmd_wdata(i_icb_cmd_wdata),
.i_icb_cmd_wmask(i_icb_cmd_wmask),

.i_icb_rsp_valid(i_icb_rsp_valid),
.i_icb_rsp_ready(i_icb_rsp_ready),
.i_icb_rsp_err(i_icb_rsp_err),
.i_icb_rsp_rdata(i_icb_rsp_rdata),

.o_bus_icb_cmd_ready({nop_icb_cmd_ready,plic_icb_cmd_ready,icache_icb_cmd_ready,dcache_icb_cmd_ready}),
.o_bus_icb_cmd_valid({nop_icb_cmd_valid,plic_icb_cmd_valid,icache_icb_cmd_valid,dcache_icb_cmd_valid}),
.o_bus_icb_cmd_read({nop_icb_cmd_read,plic_icb_cmd_read,icache_icb_cmd_read,dcache_icb_cmd_read}),
.o_bus_icb_cmd_addr({nop_icb_cmd_addr,plic_icb_cmd_addr,icache_icb_cmd_addr,dcache_icb_cmd_addr}),
.o_bus_icb_cmd_wdata({nop_icb_cmd_wdata,plic_icb_cmd_wdata,icache_icb_cmd_wdata,dcache_icb_cmd_wdata}),
.o_bus_icb_cmd_wmask({nop_icb_cmd_wmask,plic_icb_cmd_wmask,icache_icb_cmd_wmask,dcache_icb_cmd_wmask}),

.o_bus_icb_rsp_valid({nop_icb_rsp_valid,plic_icb_rsp_valid,icache_icb_rsp_valid,dcache_icb_rsp_valid}),
.o_bus_icb_rsp_ready({nop_icb_rsp_ready,plic_icb_rsp_ready,icache_icb_rsp_ready,dcache_icb_rsp_ready}),
.o_bus_icb_rsp_err({nop_icb_rsp_err,plic_icb_rsp_err,icache_icb_rsp_err,dcache_icb_rsp_err}),
.o_bus_icb_rsp_rdata({nop_icb_rsp_rdata,plic_icb_rsp_rdata,icache_icb_rsp_rdata,dcache_icb_rsp_rdata}),
.clk(clk),
.rst_n(rst_n)
);

endmodule
