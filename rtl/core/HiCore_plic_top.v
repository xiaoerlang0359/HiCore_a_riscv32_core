`include "config.v"
module HiCore_plic_top(
    input                           plic_icb_cmd_valid,
    output                          plic_icb_cmd_ready,
    input                           plic_icb_cmd_read,
    input  [`HiCore_ADDR_SIZE-1:0]  plic_icb_cmd_addr,
    input  [`HiCore_REG_SIZE-1:0]   plic_icb_cmd_wdata,
    input  [`HiCore_REG_SIZE/8-1:0] plic_icb_cmd_wmask,

    output                          plic_icb_rsp_valid,
    input                           plic_icb_rsp_ready,
    output [`HiCore_REG_SIZE-1:0]   plic_icb_rsp_rdata,
    output                          plic_icb_rsp_err,

    input uart_irq,
    input ext_irq0,
    input ext_irq1,

    output plic_ext_irq,

    input clk,
    input rst_n
);
wire [3:0] plic_irq_i = {ext_irq1,ext_irq0,uart_irq,1'b0};
sirv_plic_man #(
    .PLIC_PRIO_WIDTH(2),
    .PLIC_IRQ_NUM(4),
    .PLIC_IRQ_NUM_LOG2(2),
    .PLIC_ICB_RSP_FLOP(1),
    .PLIC_IRQ_I_FLOP(1),
    .PLIC_IRQ_O_FLOP(1)
)u_sirv_plic_man(
    .icb_cmd_valid(plic_icb_cmd_valid),
    .icb_cmd_ready(plic_icb_cmd_ready),
    .icb_cmd_read (plic_icb_cmd_read),
    .icb_cmd_addr (plic_icb_cmd_addr),
    .icb_cmd_wdata(plic_icb_cmd_wdata),
    
    .icb_rsp_valid(plic_icb_rsp_valid),
    .icb_rsp_ready(plic_icb_rsp_ready),
    .icb_rsp_rdata(plic_icb_rsp_rdata),

    .plic_irq_i(plic_irq_i),
    .plic_irq_o(plic_ext_irq),

    .clk(clk),
    .rst_n(rst_n)
);

assign plic_icb_rsp_err = 1'b0;

endmodule
