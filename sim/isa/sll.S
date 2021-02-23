li	ra,1
li	sp,0
sll	t5,ra,sp
li	t4,1
li	gp,2
bne	t5,t4,fail


li	ra,1
li	sp,1
sll	t5,ra,sp
li	t4,2
li	gp,3
bne	t5,t4,fail


li	ra,1
li	sp,7
sll	t5,ra,sp
li	t4,128
li	gp,4
bne	t5,t4,fail


li	ra,1
li	sp,14
sll	t5,ra,sp
lui	t4,0x4
li	gp,5
bne	t5,t4,fail


li	ra,1
li	sp,31
sll	t5,ra,sp
lui	t4,0x80000
li	gp,6
bne	t5,t4,fail


li	ra,-1
li	sp,0
sll	t5,ra,sp
li	t4,-1
li	gp,7
bne	t5,t4,fail


li	ra,-1
li	sp,1
sll	t5,ra,sp
li	t4,-2
li	gp,8
bne	t5,t4,fail


li	ra,-1
li	sp,7
sll	t5,ra,sp
li	t4,-128
li	gp,9
bne	t5,t4,fail


li	ra,-1
li	sp,14
sll	t5,ra,sp
lui	t4,0xffffc
li	gp,10
bne	t5,t4,fail


li	ra,-1
li	sp,31
sll	t5,ra,sp
lui	t4,0x80000
li	gp,11
bne	t5,t4,fail


li	ra,1024
lui	sp,0x1
addi	sp,sp,-2048 # 800 <_start-0x7ffff800>
sll	zero,ra,sp
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