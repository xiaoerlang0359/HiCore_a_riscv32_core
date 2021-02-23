
csrrwi x0,mscratch,3
csrr	a0,mscratch
	li	t4,3
	li	gp,2
bne	a0,t4,fail

csrrci	a1,mscratch,1
	li	t4,3
	li	gp,3
bne	a1,t4,fail

csrrsi	a2,mscratch,4
	li	t4,2
	li	gp,4
bne	a2,t4,fail

csrrwi	a3,mscratch,2
	li	t4,6
	li	gp,5
bne	a3,t4,fail

lui	a0,0xbad2
addi	a0,a0,-534 # bad1dea <_start-0x7452e216>
csrrw	a1,mscratch,a0
	li	t4,2
	li	gp,6
bne	a1,t4,fail

lui	a0,0x2
addi	a0,a0,-534 # 1dea <_start-0x7fffe216>
csrrc	a0,mscratch,a0
lui	t4,0xbad2
addi	t4,t4,-534 # bad1dea <_start-0x7452e216>
	li	gp,7
bne	a0,t4,fail

lui	a0,0xc
addi	a0,a0,-273 # beef <_start-0x7fff4111>
csrrs	a0,mscratch,a0
lui	t4,0xbad0
	li	gp,8
bne	a0,t4,fail

csrr	a0,mscratch
lui	t4,0xbadc
addi	t4,t4,-273 # badbeef <_start-0x74524111>
	li	gp,9
bne	a0,t4,fail
	li	a0,8
csrs	mstatus,a0
csrr	a0,misa
andi	a0,a0,32
	beqz	a0,test_11
	lui	a1,0x6
csrs	mstatus,a1
csrc	mstatus,a1
auipc	a1,0x2
addi	a1,a1,-778 # 80002010 <begin_signature>

test_11:
li	a0,255
csrrsi a0,mcycle,8
csrrsi a0,mie,8
csrrsi a0,mtvec,8
csrrsi a0,mepc,8
csrrsi a0,mcause,8
csrrsi a0,mtval,8
csrrsi a0,mip,8
csrrsi a0,mcycleh,8
csrrsi a0,minstret,8
csrrsi a0,minstreth,8
csrrsi a0,mvendorid,8
csrrsi a0,marchid,8
csrrsi a0,mipid,8
csrrsi a0,mhartid,8

pass:
li x0, 0
li x0, 0
jal x0, pass
li x0, 0
li x0, 0

fail:
li x0, 0
li x9, 0
jal x0, fail
li x0,0
li x0,0

