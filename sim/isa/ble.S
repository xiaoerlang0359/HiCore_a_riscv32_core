test_2:
li	gp,2
li	ra,0
li	sp,0
ble	sp,ra,next_2
bne	zero,gp,fail
back_2:
bne	zero,gp,test_3
next_2:
ble	sp,ra,back_2
bne	zero,gp,fail

test_3:
li	gp,3
li	ra,1
li	sp,1
ble	sp,ra,next_3
bne	zero,gp,fail
back_3:
bne	zero,gp,test_4
next_3:
ble	sp,ra,back_3
bne	zero,gp,fail

test_4:
li	gp,4
li	ra,-1
li	sp,-1
ble	sp,ra,next_4
bne	zero,gp,fail
back_4:
bne	zero,gp,test_12
next_4:
ble	sp,ra,back_4
bne	zero,gp,fail

test_12:
li	gp,12
li	tp,0
next_12:
li	ra,-1
li	sp,0
ble	sp,ra,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,next_12

test_13:
li	gp,13
li	tp,0
next_13:
li	ra,-1
li	sp,0
nop
ble	sp,ra,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,next_13

test_14:
li	gp,14
li	tp,0
next_14:
li	ra,-1
li	sp,0
nop
nop
ble	sp,ra,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,next_14

test_24:
li	ra,1
bgez	ra,next_24
addi	ra,ra,1
addi	ra,ra,1
addi	ra,ra,1
addi	ra,ra,1
next_24:
addi	ra,ra,1
addi	ra,ra,1
li	t4,3
li	gp,24
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