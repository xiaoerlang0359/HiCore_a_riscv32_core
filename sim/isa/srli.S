
lui	ra,0x80000
srli	t5,ra,0x0
lui	t4,0x80000
	li	gp,2
bne	t5,t4,fail

lui	ra,0x80000
srli	t5,ra,0x1
lui	t4,0x40000
	li	gp,3
bne	t5,t4,fail

lui	ra,0x80000
srli	t5,ra,0x7
lui	t4,0x1000
	li	gp,4
bne	t5,t4,fail

lui	ra,0x80000
srli	t5,ra,0xe
lui	t4,0x20
	li	gp,5
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,1 # 80000001 <_end+0xffffdff1>
srli	t5,ra,0x1f
	li	t4,1
	li	gp,6
bne	t5,t4,fail

li	ra,-1
srli	t5,ra,0x0
li	t4,-1
	li	gp,7
bne	t5,t4,fail

li	ra,-1
srli	t5,ra,0x1
lui	t4,0x80000
addi	t4,t4,-1 # 7fffffff <_end+0xffffdfef>
	li	gp,8
bne	t5,t4,fail

li	ra,-1
srli	t5,ra,0x7
lui	t4,0x2000
addi	t4,t4,-1 # 1ffffff <_start-0x7e000001>
	li	gp,9
bne	t5,t4,fail

li	ra,-1
srli	t5,ra,0xe
lui	t4,0x40
addi	t4,t4,-1 # 3ffff <_start-0x7ffc0001>
	li	gp,10
bne	t5,t4,fail

li	ra,-1
srli	t5,ra,0x1f
	li	t4,1
	li	gp,11
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
srli	t5,ra,0x0
lui	t4,0x21212
addi	t4,t4,289 # 21212121 <_start-0x5edededf>
	li	gp,12
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
srli	t5,ra,0x1
lui	t4,0x10909
addi	t4,t4,144 # 10909090 <_start-0x6f6f6f70>
	li	gp,13
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
srli	t5,ra,0x7
lui	t4,0x424
addi	t4,t4,578 # 424242 <_start-0x7fbdbdbe>
	li	gp,14
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
srli	t5,ra,0xe
lui	t4,0x8
addi	t4,t4,1156 # 8484 <_start-0x7fff7b7c>
	li	gp,15
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
srli	t5,ra,0x1f
	li	t4,0
	li	gp,16
bne	t5,t4,fail

lui	ra,0x80000
srli	ra,ra,0x7
lui	t4,0x1000
	li	gp,17
bne	ra,t4,fail

li	ra,33
srli	zero,ra,0xa
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

