
lui	ra,0x80000
	li	sp,0
sra	t5,ra,sp
lui	t4,0x80000
	li	gp,2
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,1
sra	t5,ra,sp
lui	t4,0xc0000
	li	gp,3
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,7
sra	t5,ra,sp
lui	t4,0xff000
	li	gp,4
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,14
sra	t5,ra,sp
lui	t4,0xfffe0
	li	gp,5
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,1 # 80000001 <_end+0xffffdff1>
	li	sp,31
sra	t5,ra,sp
li	t4,-1
	li	gp,6
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
	li	sp,0
sra	t5,ra,sp
lui	t4,0x80000
addi	t4,t4,-1 # 7fffffff <_end+0xffffdfef>
	li	gp,7
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
	li	sp,1
sra	t5,ra,sp
lui	t4,0x40000
addi	t4,t4,-1 # 3fffffff <_start-0x40000001>
	li	gp,8
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
	li	sp,7
sra	t5,ra,sp
lui	t4,0x1000
addi	t4,t4,-1 # ffffff <_start-0x7f000001>
	li	gp,9
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
	li	sp,14
sra	t5,ra,sp
lui	t4,0x20
addi	t4,t4,-1 # 1ffff <_start-0x7ffe0001>
	li	gp,10
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
	li	sp,31
sra	t5,ra,sp
	li	t4,0
	li	gp,11
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
	li	sp,0
sra	t5,ra,sp
lui	t4,0x81818
addi	t4,t4,385 # 81818181 <_end+0x1816171>
	li	gp,12
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
	li	sp,1
sra	t5,ra,sp
lui	t4,0xc0c0c
addi	t4,t4,192 # c0c0c0c0 <_end+0x40c0a0b0>
	li	gp,13
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
	li	sp,7
sra	t5,ra,sp
lui	t4,0xff030
addi	t4,t4,771 # ff030303 <_end+0x7f02e2f3>
	li	gp,14
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
	li	sp,14
sra	t5,ra,sp
lui	t4,0xfffe0
addi	t4,t4,1542 # fffe0606 <_end+0x7ffde5f6>
	li	gp,15
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
	li	sp,31
sra	t5,ra,sp
li	t4,-1
	li	gp,16
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
li	sp,-64
sra	t5,ra,sp
lui	t4,0x81818
addi	t4,t4,385 # 81818181 <_end+0x1816171>
	li	gp,17
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
li	sp,-63
sra	t5,ra,sp
lui	t4,0xc0c0c
addi	t4,t4,192 # c0c0c0c0 <_end+0x40c0a0b0>
	li	gp,18
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
li	sp,-57
sra	t5,ra,sp
lui	t4,0xff030
addi	t4,t4,771 # ff030303 <_end+0x7f02e2f3>
	li	gp,19
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
li	sp,-50
sra	t5,ra,sp
lui	t4,0xfffe0
addi	t4,t4,1542 # fffe0606 <_end+0x7ffde5f6>
	li	gp,20
bne	t5,t4,fail

lui	ra,0x81818
addi	ra,ra,385 # 81818181 <_end+0x1816171>
li	sp,-1
sra	t5,ra,sp
li	t4,-1
	li	gp,21
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,7
sra	ra,ra,sp
lui	t4,0xff000
	li	gp,22
bne	ra,t4,fail

lui	ra,0x80000
	li	sp,14
sra	sp,ra,sp
lui	t4,0xfffe0
	li	gp,23
bne	sp,t4,fail

	li	ra,7
sra	ra,ra,ra
	li	t4,0
	li	gp,24
bne	ra,t4,fail

li	ra,1024
lui	sp,0x1
addi	sp,sp,-2048 # 800 <_start-0x7ffff800>
sra	zero,ra,sp
	li	t4,0
li	gp,43
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