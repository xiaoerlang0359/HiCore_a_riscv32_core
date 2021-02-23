
	li	ra,0
	li	sp,0
slt	t5,ra,sp
	li	t4,0
	li	gp,2
bne	t5,t4,fail

	li	ra,1
	li	sp,1
slt	t5,ra,sp
	li	t4,0
	li	gp,3
bne	t5,t4,fail

	li	ra,3
	li	sp,7
slt	t5,ra,sp
	li	t4,1
	li	gp,4
bne	t5,t4,fail

	li	ra,7
	li	sp,3
slt	t5,ra,sp
	li	t4,0
	li	gp,5
bne	t5,t4,fail

	li	ra,0
lui	sp,0xffff8
slt	t5,ra,sp
	li	t4,0
	li	gp,6
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,0
slt	t5,ra,sp
	li	t4,1
	li	gp,7
bne	t5,t4,fail

lui	ra,0x80000
lui	sp,0xffff8
slt	t5,ra,sp
	li	t4,1
	li	gp,8
bne	t5,t4,fail

	li	ra,0
lui	sp,0x8
addi	sp,sp,-1 # 7fff <_start-0x7fff8001>
slt	t5,ra,sp
	li	t4,1
	li	gp,9
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
	li	sp,0
slt	t5,ra,sp
	li	t4,0
	li	gp,10
bne	t5,t4,fail

	li	ra,16
	li	sp,30
slt	zero,ra,sp
	li	t4,0
li	gp,38
bne	zero,t4,fail
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