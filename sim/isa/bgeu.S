test_2:
li	gp,2
li	ra,0
li	sp,0
bleu	sp,ra,next_2 
bne	zero,gp,fail
back_2:
bne	zero,gp,test_3
next_2:
bleu	sp,ra,back_2
bne	zero,gp,fail

test_3:
li	gp,3
li	ra,1
li	sp,1
bleu	sp,ra,next_3
bne	zero,gp,fail
back_3:
bne	zero,gp,test_4
next_3:
bleu	sp,ra,back_3
bne	zero,gp,fail

test_4:
li	gp,4
li	ra,-1
li	sp,-1
bleu	sp,ra,next_4
bne	zero,gp,fail
back_4:
bne	zero,gp,test_5
next_4:
bleu	sp,ra,back_4
bne	zero,gp,fail

test_5:
li	gp,5
li	ra,1
li	sp,0
bleu	sp,ra,next_5
bne	zero,gp,fail
back_5:
bne	zero,gp,test_6
next_5:
bleu	sp,ra,back_5
bne	zero,gp,fail

test_6:
li	gp,6
li	ra,-1
li	sp,-2
bleu	sp,ra,next_6
bne	zero,gp,fail
back_6:
bne	zero,gp,test_7
next_6:
bleu	sp,ra,back_6
bne	zero,gp,fail

test_7:
li	gp,7
li	ra,-1
li	sp,0
bleu	sp,ra,next_7
bne	zero,gp,fail
back_7:
bne	zero,gp,test_8
next_7:
bleu	sp,ra,back_7
bne	zero,gp,fail

test_8:
li	gp,9
li	ra,-2
li	sp,-1
bleu	sp,ra,next_8
bne	zero,gp,back_8
next_8:
bne	zero,gp,fail
back_8:
bleu	sp,ra,next_8

test_24:
li	ra,1
bleu	zero,ra,next_24
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
