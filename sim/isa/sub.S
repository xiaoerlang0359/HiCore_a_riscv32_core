
	li	ra,0
	li	sp,0
sub	t5,ra,sp
	li	t4,0
	li	gp,2
bne	t5,t4,fail

	li	ra,1
	li	sp,1
sub	t5,ra,sp
	li	t4,0
	li	gp,3
bne	t5,t4,fail

	li	ra,3
	li	sp,7
sub	t5,ra,sp
li	t4,-4
	li	gp,4
bne	t5,t4,fail

	li	ra,0
lui	sp,0xffff8
sub	t5,ra,sp
	lui	t4,0x8
	li	gp,5
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,0
sub	t5,ra,sp
lui	t4,0x80000
	li	gp,6
bne	t5,t4,fail

lui	ra,0x80000
lui	sp,0xffff8
sub	t5,ra,sp
lui	t4,0x80008
	li	gp,7
bne	t5,t4,fail

	li	ra,0
lui	sp,0x8
addi	sp,sp,-1 # 7fff <_start-0x7fff8001>
sub	t5,ra,sp
lui	t4,0xffff8
addi	t4,t4,1 # ffff8001 <_end+0x7fff5ff1>
	li	gp,8
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
	li	sp,0
sub	t5,ra,sp
lui	t4,0x80000
addi	t4,t4,-1 # 7fffffff <_end+0xffffdfef>
	li	gp,9
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
lui	sp,0x8
addi	sp,sp,-1 # 7fff <_start-0x7fff8001>
sub	t5,ra,sp
lui	t4,0x7fff8
	li	gp,10
bne	t5,t4,fail

lui	ra,0x80000
lui	sp,0x8
addi	sp,sp,-1 # 7fff <_start-0x7fff8001>
sub	t5,ra,sp
lui	t4,0x7fff8
addi	t4,t4,1 # 7fff8001 <_start-0x7fff>
	li	gp,11
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
lui	sp,0xffff8
sub	t5,ra,sp
lui	t4,0x80008
addi	t4,t4,-1 # 80007fff <_end+0x5fef>
	li	gp,12
bne	t5,t4,fail

	li	ra,0
li	sp,-1
sub	t5,ra,sp
	li	t4,1
	li	gp,13
bne	t5,t4,fail

li	ra,-1
	li	sp,1
sub	t5,ra,sp
li	t4,-2
	li	gp,14
bne	t5,t4,fail

li	ra,-1
li	sp,-1
sub	t5,ra,sp
	li	t4,0
	li	gp,15
bne	t5,t4,fail

	li	ra,13
	li	sp,11
sub	ra,ra,sp
	li	t4,2
	li	gp,16
bne	ra,t4,fail

	li	ra,14
	li	sp,11
sub	sp,ra,sp
	li	t4,3
	li	gp,17
bne	sp,t4,fail

	li	ra,13
sub	ra,ra,ra
	li	t4,0
	li	gp,18
bne	ra,t4,fail

	li	ra,16
	li	sp,30
sub	zero,ra,sp
	li	t4,0
li	gp,37
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

