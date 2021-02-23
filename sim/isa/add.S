test_2:
li	ra,0
li	sp,0
add	t5,ra,sp
li	t4,0
li	gp,2
bne	t5,t4,fail

test_3:
li	ra,1
li	sp,1
add	t5,ra,sp
li	t4,2
li	gp,3
bne	t5,t4,fali 

test_4:
li	ra,3
li	sp,7
add	t5,ra,sp
li	t4,10
li	gp,4
bne	t5,t4,fali <fail>

test_5:
li	ra,0
lui	sp,0xffff8
add	t5,ra,sp
lui	t4,0xffff8
li	gp,5
bne	t5,t4,fali <fail>

test_6:
lui	ra,0x80000
li	sp,0
add	t5,ra,sp
lui	t4,0x80000
li	gp,6
bne	t5,t4,fali <fail>

test_7:
lui	ra,0x80000
lui	sp,0xffff8
add	t5,ra,sp
lui	t4,0x7fff8
li	gp,7
bne	t5,t4,fali <fail>

test_8:
li	ra,0
lui	sp,0x8
addi	sp,sp,-1 # 7fff <_start-0x7fff8001>
add	t5,ra,sp
lui	t4,0x8
addi	t4,t4,-1 # 7fff <_start-0x7fff8001>
li	gp,8
bne	t5,t4,fali <fail>

test_9:
lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
li	sp,0
add	t5,ra,sp
lui	t4,0x80000
addi	t4,t4,-1 # 7fffffff <_end+0xffffdfef>
li	gp,9
bne	t5,t4,fali <fail>

test_10:
lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
lui	sp,0x8
addi	sp,sp,-1 # 7fff <_start-0x7fff8001>
add	t5,ra,sp
lui	t4,0x80008
addi	t4,t4,-2 # 80007ffe <_end+0x5fee>
li	gp,10
bne	t5,t4,fali <fail>

test_11:
lui	ra,0x80000
lui	sp,0x8
addi	sp,sp,-1 # 7fff <_start-0x7fff8001>
add	t5,ra,sp
lui	t4,0x80008
addi	t4,t4,-1 # 80007fff <_end+0x5fef>
li	gp,11
bne	t5,t4,fali <fail>

test_12:
lui	ra,0x80000
addi	ra,ra,-1 # 7fffffff <_end+0xffffdfef>
lui	sp,0xffff8
add	t5,ra,sp
lui	t4,0x7fff8
addi	t4,t4,-1 # 7fff7fff <_start-0x8001>
li	gp,12
bne	t5,t4,fali <fail>

test_13:
li	ra,0
li	sp,-1
add	t5,ra,sp
li	t4,-1
li	gp,13
bne	t5,t4,fali <fail>

test_14:
li	ra,-1
li	sp,1
add	t5,ra,sp
li	t4,0
li	gp,14
bne	t5,t4,fali <fail>

test_15:
li	ra,-1
li	sp,-1
add	t5,ra,sp
li	t4,-2
li	gp,15
bne	t5,t4,fali <fail>

test_16:
li	ra,1
lui	sp,0x80000
addi	sp,sp,-1 # 7fffffff <_end+0xffffdfef>
add	t5,ra,sp
lui	t4,0x80000
li	gp,16
bne	t5,t4,fali <fail>

test_17:
li	ra,13
li	sp,11
add	ra,ra,sp
li	t4,24
li	gp,17
bne	ra,t4,fali <fail>

test_18:
li	ra,14
li	sp,11
add	sp,sp,ra
li	t4,25
li	gp,18
bne	sp,t4,fali <fail>

test_19:
li	ra,13
add	ra,ra,ra
li	t4,26
li	gp,19
bne	ra,t4,fali <fail>

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
