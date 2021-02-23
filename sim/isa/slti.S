
	li	ra,0
slti	t5,ra,0
	li	t4,0
	li	gp,2
bne	t5,t4,fail

	li	ra,1
slti	t5,ra,1
	li	t4,0
	li	gp,3
bne	t5,t4,fail

	li	ra,3
slti	t5,ra,7
	li	t4,1
	li	gp,4
bne	t5,t4,fail

	li	ra,7
slti	t5,ra,3
	li	t4,0
	li	gp,5
bne	t5,t4,fail

	li	ra,0
slti	t5,ra,-2048
	li	t4,0
	li	gp,6
bne	t5,t4,fail

lui	ra,0x80000
slti	t5,ra,0
	li	t4,1
	li	gp,7
bne	t5,t4,fail

lui	ra,0x80000
slti	t5,ra,-2048
	li	t4,1
	li	gp,8
bne	t5,t4,fail

	li	ra,0
slti	t5,ra,2047
	li	t4,1
	li	gp,9
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
slti	t5,ra,0
	li	t4,0
	li	gp,10
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
slti	t5,ra,2047
	li	t4,0
	li	gp,11
bne	t5,t4,fail

lui	ra,0x80000
slti	t5,ra,2047
	li	t4,1
	li	gp,12
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
slti	t5,ra,-2048
	li	t4,0
	li	gp,13
bne	t5,t4,fail

	li	ra,0
slti	t5,ra,-1
	li	t4,0
	li	gp,14
bne	t5,t4,fail

li	ra,-1
slti	t5,ra,1
	li	t4,1
	li	gp,15
bne	t5,t4,fail

li	ra,-1
slti	t5,ra,-1
	li	t4,0
	li	gp,16
bne	t5,t4,fail

	li	ra,11
slti	ra,ra,13
	li	t4,1
	li	gp,17
bne	ra,t4,fail


lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
slti	zero,ra,-1
	li	t4,0
	li	gp,25
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