
lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
lui	sp,0xf0f1
addi	sp,sp,-241 # f0f0f0f <_start-0x70f0f0f1>
or	t5,ra,sp
lui	t4,0xff100
addi	t4,t4,-241 # ff0fff0f <_end+0x7f0fdeff>
li	gp,2
bne	t5,t4,fail

lui	ra,0xff01
addi	ra,ra,-16 # ff00ff0 <_start-0x700ff010>
lui	sp,0xf0f0f
addi	sp,sp,240 # f0f0f0f0 <_end+0x70f0d0e0>
or	t5,ra,sp
lui	t4,0xfff10
addi	t4,t4,-16 # fff0fff0 <_end+0x7ff0dfe0>
li	gp,3
bne	t5,t4,fail

lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
lui	sp,0xf0f1
addi	sp,sp,-241 # f0f0f0f <_start-0x70f0f0f1>
or	t5,ra,sp
lui	t4,0xfff1
addi	t4,t4,-1 # fff0fff <_start-0x7000f001>
	li	gp,4
bne	t5,t4,fail

lui	ra,0x11111
addi	ra,ra,273 # 11111111 <_start-0x6eeeeeef>
lui	sp,0x22222
addi	sp,sp,546 # 22222222 <_start-0x5dddddde>
or	zero,ra,sp
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