test_2:
li	gp,2
li	ra,0
jal	tp,target_2

nop
nop
j	fail

target_2:
auipc	sp,0x0
addi	sp,sp,-6 # 8000026a <linkaddr_2>
bne	sp,tp,fail

test_3:
li	ra,1
j	next_3
addi	ra,ra,1
addi	ra,ra,1
addi	ra,ra,1
addi	ra,ra,1
next_3:
addi	ra,ra,1
addi	ra,ra,1
li	t4,3
li	gp,3
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