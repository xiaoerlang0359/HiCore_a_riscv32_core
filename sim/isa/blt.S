test_2:
li	gp,2
li	ra,0
li	sp,1
blt	ra,sp,next_2
bne	zero,gp,fail
back_2:
bne	zero,gp,test_3
next_2:
blt	ra,sp,back_2
bne	zero,gp,fail

test_3:
li	gp,3
li	ra,-1
li	sp,1
blt	ra,sp,next_3
bne	zero,gp,fail
back_3:
bne	zero,gp,test_4
next_3:
blt	ra,sp,back_3
bne	zero,gp,fail

test_4:
li	gp,4
li	ra,-2
li	sp,-1
blt	ra,sp,next_4
bne	zero,gp,fail
back_4:
bne	zero,gp,test_5
next_4:
blt	ra,sp,back_4
bne	zero,gp,fail

test_5:
li	gp,5
li	ra,1
li	sp,0
blt	ra,sp,next_5
bne	zero,gp,back_5
next_5:
bne	zero,gp,fail
back_5:
blt	ra,sp,next_5

test_6:
li	gp,6
li	ra,1
li	sp,-1
blt	ra,sp,next_6
bne	zero,gp,back_6
next_6:
bne	zero,gp,fail
back_6:
blt	ra,sp,next_6

test_7:
li	gp,7
li	ra,-1
li	sp,-2
blt	ra,sp,next_7
bne	zero,gp,back_7
next_7:
bne	zero,gp,fail
back_7:
blt	ra,sp,next_7

test_21:
li	ra,1
bgtz	ra,next_21
addi	ra,ra,1
addi	ra,ra,1
addi	ra,ra,1
addi	ra,ra,1
next_21:
addi	ra,ra,1
addi	ra,ra,1
li	t4,3
li	gp,21
bne	ra,t4,fail
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