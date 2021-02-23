start:
jal x31,main
nop
nop
trap_vector:
csrw mscratch,a0
csrr t5,mcause
csrr a0,mscratch
mret
main:
auipc t0,0
addi t0,t0,-16
csrrw s0,mtvec,t0
csrr tp,mtvec
csrrsi s0,mstatus,8
li t0, 0x800
csrrs s0,mie,t0
auipc t0,0
jalr x31,t0,4
nop
nop
nop
nop
nop
