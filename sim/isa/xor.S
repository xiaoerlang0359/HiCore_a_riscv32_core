
lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
lui	sp,0xf0f1
addi	sp,sp,-241 # f0f0f0f <_start-0x70f0f0f1>
xor	t5,ra,sp
lui	t4,0xf00ff
addi	t4,t4,15 # f00ff00f <_end+0x700fcfff>
	li	gp,2
bne	t5,t4,fail

lui	ra,0xff01
addi	ra,ra,-16 # ff00ff0 <_start-0x700ff010>
lui	sp,0xf0f0f
addi	sp,sp,240 # f0f0f0f0 <_end+0x70f0d0e0>
xor	t5,ra,sp
lui	t4,0xff010
addi	t4,t4,-256 # ff00ff00 <_end+0x7f00def0>
	li	gp,3
bne	t5,t4,fail

lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
lui	sp,0xf0f1
addi	sp,sp,-241 # f0f0f0f <_start-0x70f0f0f1>
xor	t5,ra,sp
lui	t4,0xff01
addi	t4,t4,-16 # ff00ff0 <_start-0x700ff010>
	li	gp,4
bne	t5,t4,fail

lui	ra,0xf00ff
addi	ra,ra,15 # f00ff00f <_end+0x700fcfff>
lui	sp,0xf0f0f
addi	sp,sp,240 # f0f0f0f0 <_end+0x70f0d0e0>
xor	t5,ra,sp
lui	t4,0xff0
addi	t4,t4,255 # ff00ff <_start-0x7f00ff01>
	li	gp,5
bne	t5,t4,fail

lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
lui	sp,0xf0f1
addi	sp,sp,-241 # f0f0f0f <_start-0x70f0f0f1>
xor	ra,ra,sp
lui	t4,0xf00ff
addi	t4,t4,15 # f00ff00f <_end+0x700fcfff>
	li	gp,6
bne	ra,t4,fail

lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
lui	sp,0xf0f1
addi	sp,sp,-241 # f0f0f0f <_start-0x70f0f0f1>
xor	sp,ra,sp
lui	t4,0xf00ff
addi	t4,t4,15 # f00ff00f <_end+0x700fcfff>
	li	gp,7
bne	sp,t4,fail

lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
xor	ra,ra,ra
	li	t4,0
	li	gp,8
bne	ra,t4,fail

lui	ra,0x11111
addi	ra,ra,273 # 11111111 <_start-0x6eeeeeef>
lui	sp,0x22222
addi	sp,sp,546 # 22222222 <_start-0x5dddddde>
xor	zero,ra,sp
	li	t4,0
	li	gp,27
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