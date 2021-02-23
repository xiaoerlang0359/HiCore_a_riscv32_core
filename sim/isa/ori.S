lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
ori	t5,ra,-241
li	t4,-241
li	gp,2
bne	t5,t4,fail

lui	ra,0xff01
addi	ra,ra,-16 # ff00ff0 <_start-0x700ff010>
ori	t5,ra,240
lui	t4,0xff01
addi	t4,t4,-16 # ff00ff0 <_start-0x700ff010>
li	gp,3
bne	t5,t4,fail

lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
ori	t5,ra,1807
lui	t4,0xff0
addi	t4,t4,2047 # ff07ff <_start-0x7f00f801>
li	gp,4
bne	t5,t4,fail

lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
ori	zero,ra,1807
li	t4,0
li	gp,14
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