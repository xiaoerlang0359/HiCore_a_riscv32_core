test_2:
li	gp,2
li	t0,0
auipc	t1,0x0
addi	t1,t1,16 # 80000274 <target_2>
jalr	t0,t1

j	fail

target_2:
auipc	t1,0x0
addi	t1,t1,-2 # 80000272 <linkaddr_2>
bne	t0,t1,fail

test_4:
li	gp,4
li	tp,0
back_4:
auipc	t1,0x0
addi	t1,t1,16 # 80000294 <test_4+0x14>
jalr	s3,t1
bne	zero,gp,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,back_4

test_5:
li	gp,5
li	tp,0
back_5:
auipc	t1,0x0
addi	t1,t1,20 # 800002b2 <test_5+0x16>
nop
jalr	s3,t1
bne	zero,gp,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,back_5

test_6:
li	gp,6
li	tp,0
back_6:
auipc	t1,0x0
addi	t1,t1,24 # 800002d2 <test_6+0x18>
nop
nop
jalr	s3,t1
bne	zero,gp,fail
addi	tp,tp,1
li	t0,2
bne	tp,t0,back_6

test_7:
li	t0,1
auipc	t1,0x0
addi	t1,t1,28 # 800002fa <test_7+0x20>
jr	-4(t1)
addi	t0,t0,1
addi	t0,t0,1
addi	t0,t0,1
addi	t0,t0,1
addi	t0,t0,1
addi	t0,t0,1
li	t4,4
li	gp,7
bne	t0,t4,fail
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