test_2:
li	gp,2
li	ra,0
li	sp,0
beq	ra,sp,next_2
bne	zero,gp,fail
back_2:
bne	zero,gp,test_3
next_2:
beq	ra,sp,back_2
bne	zero,gp,fail

test_3:
li	gp,3
li	ra,1
li	sp,1
beq	ra,sp,next_3
bne	zero,gp,fail
back_3:
bne	zero,gp,test_4
next_3:
beq	ra,sp,back_3
bne	zero,gp,fail

test_4:
li	gp,4
li	ra,-1
li	sp,-1
beq	ra,sp,next_4
bne	zero,gp,fail
back_4:
bne	zero,gp,test_5
next_4:
beq	ra,sp,back_4
bne	zero,gp,fail

test_5:
li	gp,5
li	ra,0
li	sp,1
beq	ra,sp,next_5
bne	zero,gp,next_5_2
next_5:
bne	zero,gp,fail
next_5_2:
beq	ra,sp,next_5

test_9:
li	gp,9
li	tp,0
next_9:
li	ra,0
li	sp,-1
beq	ra,sp,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,next_9

test_10:
li	gp,10
li	tp,0
next_10:
li	ra,0
li	sp,-1
nop
beq	ra,sp,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,next_10

test_11:
li	gp,11
li	tp,0
next_11:
li	ra,0
li	sp,-1
nop
nop
beq	ra,sp,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,next_11

test_12:
li	gp,12
li	tp,0
next_12:
li	ra,0
nop
li	sp,-1
beq	ra,sp,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,next_12

test_13:
li	gp,13
li	tp,0
next_13:
li	ra,0
nop
li	sp,-1
nop
beq	ra,sp,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,next_13

test_14:
li	gp,14
li	tp,0
next_14:
li	ra,0
nop
nop
li	sp,-1
beq	ra,sp,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,next_14

test_21:
li	ra,1
beqz	zero,next_21
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
