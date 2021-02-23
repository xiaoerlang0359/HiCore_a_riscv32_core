
lui	ra,0x80000
	li	sp,0
srl	t5,ra,sp
lui	t4,0x80000
	li	gp,2
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,1
srl	t5,ra,sp
lui	t4,0x40000
	li	gp,3
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,7
srl	t5,ra,sp
lui	t4,0x1000
	li	gp,4
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,14
srl	t5,ra,sp
lui	t4,0x20
	li	gp,5
bne	t5,t4,fail

lui	ra,0x80000
addi	ra,ra,1 # 80000001 <_end+0xffffdff1>
	li	sp,31
srl	t5,ra,sp
	li	t4,1
	li	gp,6
bne	t5,t4,fail

li	ra,-1
	li	sp,0
srl	t5,ra,sp
li	t4,-1
	li	gp,7
bne	t5,t4,fail

li	ra,-1
	li	sp,1
srl	t5,ra,sp
lui	t4,0x80000
addi	t4,t4,-1 # 7fffffff <_end+0xffffdfef>
	li	gp,8
bne	t5,t4,fail

li	ra,-1
	li	sp,7
srl	t5,ra,sp
lui	t4,0x2000
addi	t4,t4,-1 # 1ffffff <_start-0x7e000001>
	li	gp,9
bne	t5,t4,fail

li	ra,-1
	li	sp,14
srl	t5,ra,sp
lui	t4,0x40
addi	t4,t4,-1 # 3ffff <_start-0x7ffc0001>
	li	gp,10
bne	t5,t4,fail

li	ra,-1
	li	sp,31
srl	t5,ra,sp
	li	t4,1
	li	gp,11
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
	li	sp,0
srl	t5,ra,sp
lui	t4,0x21212
addi	t4,t4,289 # 21212121 <_start-0x5edededf>
	li	gp,12
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
	li	sp,1
srl	t5,ra,sp
lui	t4,0x10909
addi	t4,t4,144 # 10909090 <_start-0x6f6f6f70>
	li	gp,13
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
	li	sp,7
srl	t5,ra,sp
lui	t4,0x424
addi	t4,t4,578 # 424242 <_start-0x7fbdbdbe>
	li	gp,14
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
	li	sp,14
srl	t5,ra,sp
lui	t4,0x8
addi	t4,t4,1156 # 8484 <_start-0x7fff7b7c>
	li	gp,15
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
	li	sp,31
srl	t5,ra,sp
	li	t4,0
	li	gp,16
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
li	sp,-64
srl	t5,ra,sp
lui	t4,0x21212
addi	t4,t4,289 # 21212121 <_start-0x5edededf>
	li	gp,17
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
li	sp,-63
srl	t5,ra,sp
lui	t4,0x10909
addi	t4,t4,144 # 10909090 <_start-0x6f6f6f70>
	li	gp,18
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
li	sp,-57
srl	t5,ra,sp
lui	t4,0x424
addi	t4,t4,578 # 424242 <_start-0x7fbdbdbe>
	li	gp,19
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
li	sp,-50
srl	t5,ra,sp
lui	t4,0x8
addi	t4,t4,1156 # 8484 <_start-0x7fff7b7c>
	li	gp,20
bne	t5,t4,fail

lui	ra,0x21212
addi	ra,ra,289 # 21212121 <_start-0x5edededf>
li	sp,-1
srl	t5,ra,sp
	li	t4,0
	li	gp,21
bne	t5,t4,fail

lui	ra,0x80000
	li	sp,7
srl	ra,ra,sp
lui	t4,0x1000
	li	gp,22
bne	ra,t4,fail

lui	ra,0x80000
	li	sp,14
srl	sp,ra,sp
lui	t4,0x20
	li	gp,23
bne	sp,t4,fail

	li	ra,7
srl	ra,ra,ra
	li	t4,0
	li	gp,24
bne	ra,t4,fail

li	ra,1024
lui	sp,0x1
addi	sp,sp,-2048 # 800 <_start-0x7ffff800>
srl	zero,ra,sp
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