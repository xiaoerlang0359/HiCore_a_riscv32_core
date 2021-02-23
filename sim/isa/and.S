test_2:
lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
lui	sp,0xf0f1
addi	sp,sp,-241 # f0f0f0f <_start-0x70f0f0f1>
and	t5,ra,sp
lui	t4,0xf001
addi	t4,t4,-256 # f000f00 <_start-0x70fff100>
li	gp,2
bne	t5,t4,fail

test_3:
lui	ra,0xff01
addi	ra,ra,-16 # ff00ff0 <_start-0x700ff010>
lui	sp,0xf0f0f
addi	sp,sp,240 # f0f0f0f0 <_end+0x70f0d0e0>
and	t5,ra,sp
lui	t4,0xf00
addi	t4,t4,240 # f000f0 <_start-0x7f0fff10>
li	gp,3
bne	t5,t4,fail

test_4:
lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
lui	sp,0xf0f1
addi	sp,sp,-241 # f0f0f0f <_start-0x70f0f0f1>
and	t5,ra,sp
lui	t4,0xf0
addi	t4,t4,15 # f000f <_start-0x7ff0fff1>
li	gp,4
bne	t5,t4,fail

test_5:
lui	ra,0xf00ff
addi	ra,ra,15 # f00ff00f <_end+0x700fcfff>
lui	sp,0xf0f0f
addi	sp,sp,240 # f0f0f0f0 <_end+0x70f0d0e0>
and	t5,ra,sp
lui	t4,0xf000f
li	gp,5
bne	t5,t4,fail

test_6:
lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
lui	sp,0xf0f1
addi	sp,sp,-241 # f0f0f0f <_start-0x70f0f0f1>
and	ra,ra,sp
lui	t4,0xf001
addi	t4,t4,-256 # f000f00 <_start-0x70fff100>
li	gp,6
bne	ra,t4,fail

test_7:
lui	ra,0xff01
addi	ra,ra,-16 # ff00ff0 <_start-0x700ff010>
lui	sp,0xf0f0f
addi	sp,sp,240 # f0f0f0f0 <_end+0x70f0d0e0>
and	sp,ra,sp
lui	t4,0xf00
addi	t4,t4,240 # f000f0 <_start-0x7f0fff10>
li	gp,7
bne	sp,t4,fail

test_8:
lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
and	ra,ra,ra
lui	t4,0xff010
addi	t4,t4,-256 # ff00ff00 <_end+0x7f00def0>
li	gp,8
bne	ra,t4,fail

test_24:
lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
and	sp,zero,ra
li	t4,0
li	gp,24
bne	sp,t4,fail

test_25:
lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
and	sp,ra,zero
li	t4,0
li	gp,25
bne	sp,t4,fail

test_26:
and	ra,zero,zero
li	t4,0
li	gp,26
bne	ra,t4,fail

test_27:
lui	ra,0x11111
addi	ra,ra,273 # 11111111 <_start-0x6eeeeeef>
lui	sp,0x22222
addi	sp,sp,546 # 22222222 <_start-0x5dddddde>
and	zero,ra,sp
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

