`include "config.v"

module tb_top();
reg clk;
reg rst_n;

`define CPU_TOP u_HiCore_cpu
`define REGFILE `CPU_TOP.u_HiCore_regfile
`define ITCM `CPU_TOP.u_ifetch_sram_ctrl.HiCore_sim_ram
`define PC_WRITE_TOHOST 32'h00000098

wire [`HiCore_REG_SIZE-1:0] x3 = `REGFILE.rf_r[3];
wire [`HiCore_PC_SIZE-1:0] pc = `CPU_TOP.u_HiCore_commit.commit_pc;
wire pc_vld = `CPU_TOP.u_HiCore_commit.rob_ready;

reg [31:0] pc_write_to_host_cnt;
reg [31:0] pc_write_to_host_cycle;
reg [31:0] cycle_count;
reg [31:0] valid_ir_cycle;
reg pc_write_to_host_flag;

always @(posedge clk or negedge rst_n)
begin
    if (rst_n==1'b0)begin
        pc_write_to_host_cnt <= 32'b0;
        pc_write_to_host_flag <= 1'b0;
        pc_write_to_host_cycle <= 32'b0;
    end
    else if (pc_vld & (pc == `PC_WRITE_TOHOST)) begin
        pc_write_to_host_cnt <= pc_write_to_host_cnt + 1'b1;
        pc_write_to_host_flag <= 1'b1;
        if (pc_write_to_host_flag == 1'b0)begin
            pc_write_to_host_cycle <= cycle_count;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n==1'b0)begin
        cycle_count<=32'd0;
    end
    else begin
        cycle_count<=cycle_count+1'b1;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (rst_n == 1'b0)begin
        valid_ir_cycle<=32'd0;
    end
    else if (pc_vld)begin
        valid_ir_cycle<=valid_ir_cycle+1'b1;
    end
end

reg [8*300:1] testcase;
integer dumpwave;

initial begin
    $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    if ($value$plusargs("TESTCASE=%s",testcase)) begin
        $display("TESTCASE=%s",testcase);
    end

    pc_write_to_host_flag<=0;
    clk<=0;
    rst_n<=0;
    #120 rst_n<=1;
    @(pc_write_to_host_cnt == 32'd8) #10 rst_n<=1;
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~~~~ Test Result Summary ~~~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("~TESTCASE: %s ~~~~~~~~~~~~~", testcase);
    $display("~~~~~~~~~~~~~~Total cycle_count value: %d ~~~~~~~~~~~~~", cycle_count);
    $display("~~~~~~~~~~The valid Instruction Count: %d ~~~~~~~~~~~~~", valid_ir_cycle);
    $display("~~~~~The test ending reached at cycle: %d ~~~~~~~~~~~~~", pc_write_to_host_cycle);
    $display("~~~~~~~~~~~~~~~The final x3 Reg value: %d ~~~~~~~~~~~~~", x3);
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    if (x3 == 1) begin
        $display("~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end
    else begin
        $display("~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end
    #10
    $finish;
end

initial begin
    #40000000
    $display("Time out !!!");
    $finish;
end

always begin
    #2 clk<=~clk;
end

integer i;
reg [7:0] itcm_mem [0:(`HiCore_RAM_DEPTH*4)-1];
initial begin
    $readmemh({testcase, ".verilog"},itcm_mem);
    for (i=0;i<(`HiCore_RAM_DEPTH);i=i+1) begin
          `ITCM.mem_r[i][00+7:00] = itcm_mem[i*4+0];
          `ITCM.mem_r[i][08+7:08] = itcm_mem[i*4+1];
          `ITCM.mem_r[i][16+7:16] = itcm_mem[i*4+2];
          `ITCM.mem_r[i][24+7:24] = itcm_mem[i*4+3];
    end
    $display("ITCM 0x00: %h", `ITCM.mem_r[8'h00]);
    $display("ITCM 0x01: %h", `ITCM.mem_r[8'h01]);
    $display("ITCM 0x02: %h", `ITCM.mem_r[8'h02]);
    $display("ITCM 0x03: %h", `ITCM.mem_r[8'h03]);
    $display("ITCM 0x04: %h", `ITCM.mem_r[8'h04]);
    $display("ITCM 0x05: %h", `ITCM.mem_r[8'h05]);
    $display("ITCM 0x06: %h", `ITCM.mem_r[8'h06]);
    $display("ITCM 0x07: %h", `ITCM.mem_r[8'h07]);
    $display("ITCM 0x16: %h", `ITCM.mem_r[8'h16]);
    $display("ITCM 0x20: %h", `ITCM.mem_r[8'h20]);
end

initial begin
    $value$plusargs("DUMPWAVE=%d",dumpwave);
    if (dumpwave != 0)begin
        $fsdbDumpfile("ware.fsdb");
        $fsdbDumpvars("+all");
    end
end

HiCore_cpu u_HiCore_cpu(
.uart_irq(1'b0),
.ext_irq0(1'b0),
.ext_irq1(1'b0),
.async_clk(1'b0),
.clk(clk),
.rst_n(rst_n),
.flush(),
.branch()
);

endmodule
