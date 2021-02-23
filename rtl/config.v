`define FPGA_SOURCE 
`define HiCore_ADDR_SIZE 32
`define HiCore_PC_SIZE 32
`define HiCore_REG_SIZE 32
`define HiCore_INT_SIZE 32
`define HiCore_EXCP_SIZE 16
`define HiCore_IRQ_SIZE 12
`define HiCore_RST_PC     `HiCore_PC_SIZE'h0000_0000
`define HiCore_RFIDX_WIDTH 5
`define HiCore_CSRIDX_WIDTH 12
`define HiCore_IF2DE_SIZE `HiCore_PC_SIZE+`HiCore_INT_SIZE+16
`define HiCore_DE2BJ_SIZE `HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE + `HiCore_REG_SIZE + `HiCore_RFIDX_WIDTH + 1
`define HiCore_DE2ALU_SIZE `HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE + `HiCore_REG_SIZE*2 + `HiCore_RFIDX_WIDTH + 8
`define HiCore_DE2AGU_SIZE `HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE + `HiCore_REG_SIZE*3 + `HiCore_RFIDX_WIDTH + 6
`define HiCore_DE2CSR_SIZE `HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE + `HiCore_REG_SIZE + `HiCore_RFIDX_WIDTH + `HiCore_CSRIDX_WIDTH + 4
`define HiCore_DE2NOP_SIZE `HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE + 3
`define HiCore_DE2ISSUE_PRE_SIZE `HiCore_DE2AGU_SIZE
`define HiCore_DE2ISSUE_SIZE `HiCore_DE2ISSUE_PRE_SIZE + `HiCore_ROB_PTR_SIZE + 5
`define HiCore_DE2EX_SIZE (`HiCore_REG_SIZE*3) + 13 + `HiCore_PC_SIZE +5
`define HiCore_ROB_PTR_SIZE 4
`define HiCore_ROB_SIZE 16
`define HiCore_ISSUE2ALU_SIZE `HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE + `HiCore_ROB_PTR_SIZE 
`define HiCore_WB_SIZE `HiCore_EXCP_SIZE + `HiCore_IRQ_SIZE + `HiCore_PC_SIZE
`define HiCore_ALU2WB_SIZE `HiCore_ISSUE2ALU_SIZE + `HiCore_REG_SIZE
`define HiCore_CSR2WB_SIZE `HiCore_ALU2WB_SIZE + `HiCore_REG_SIZE
`define HiCore_AGUINFO_SIZE `HiCore_ALU2WB_SIZE + `HiCore_REG_SIZE/8 + `HiCore_ADDR_SIZE + 5
`define HiCore_LSU_SIZE `HiCore_ISSUE2ALU_SIZE + 7

`define HiCore_IADDR_BASE   `HiCore_ADDR_SIZE'h0000_0000
`define HiCore_IADDR_REGION `HiCore_ADDR_SIZE-1:`HiCore_ADDR_SIZE-16
`define HiCore_IADDR_COMP   16'h0000

`define HiCore_BOOT_BASE  `HiCore_ADDR_SIZE'h0000_0000
`define HiCore_BOOT_LIM   `HiCore_ADDR_SIZE'h0100_0000

`define HiCore_OS_BASE    `HiCore_ADDR_SIZE'h0100_0000
`define HiCore_OS_LIM     `HiCore_ADDR_SIZE'h2000_0000

`define HiCore_DADDR_BASE   `HiCore_ADDR_SIZE'h8000_0000
`define HiCore_DADDR_REGION `HiCore_ADDR_SIZE-1:`HiCore_ADDR_SIZE-16
`define HiCore_DADDR_COMP   16'h8000

`define HiCore_PADDR_BASE   `HiCore_ADDR_SIZE'hF000_0000
`define HiCore_PADDR_REGION `HiCore_ADDR_SIZE-1:`HiCore_ADDR_SIZE-4
`define HiCore_PADDR_COMP   4'b1111

`define HiCore_CLINT_ADDR_BASE   `HiCore_ADDR_SIZE'hF000_0000
`define HiCore_CLINT_ADDR_REGION `HiCore_ADDR_SIZE-1:`HiCore_ADDR_SIZE-16
`define HiCore_CLINT_ADDR_COMP   16'hF000

`define HiCore_PLIC_ADDR_BASE    `HiCore_ADDR_SIZE'hF100_0000
`define HiCore_PLIC_ADDR_REGION  `HiCore_ADDR_SIZE-1:`HiCore_ADDR_SIZE-8
`define HiCore_PLIC_ADDR_COMP    8'hF1

`define HiCore_ICB_CMD_SIZE `HiCore_ADDR_SIZE + `HiCore_REG_SIZE + `HiCore_REG_SIZE/8 + 1
