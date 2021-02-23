addi	a3,a3,333
li	a3,111
auipc	a0,0
lw	a0,-8(a0) 
auipc	t0,0x0
sw	a0,12(t0) 
fence.i
addi	a3,a3,222

li	t4,444
li	gp,2
bne	a3,t4,fail
li	a4,100
back_2:
addi	a4,a4,-1
bnez	a4,back_2
auipc	t0,0x0
sw	a0,12(t0) # 800002c0 <test_2+0x28>
fence.i
addi	a3,a3,555

nop
li	t4,777
li	gp,3
bne	a3,t4,fail
bne	zero,gp,pass

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