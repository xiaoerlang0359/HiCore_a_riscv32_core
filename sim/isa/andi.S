test_2:
lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
andi	t5,ra,-241
lui	t4,0xff010
addi	t4,t4,-256 # ff00ff00 <_end+0x7f00def0>
li	gp,2
bne	t5,t4,fail

test_3:
lui	ra,0xff01
addi	ra,ra,-16 # ff00ff0 <_start-0x700ff010>
andi	t5,ra,240
li	t4,240
li	gp,3
bne	t5,t4,fail

test_4:
lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
andi	t5,ra,1807
li	t4,15
li	gp,4
bne	t5,t4,fail

test_5:
lui	ra,0xf00ff
addi	ra,ra,15 # f00ff00f <_end+0x700fcfff>
andi	t5,ra,240
li	t4,0
li	gp,5
bne	t5,t4,fail

test_6:
lui	ra,0xff010
addi	ra,ra,-256 # ff00ff00 <_end+0x7f00def0>
andi	ra,ra,240
li	t4,0
li	gp,6
bne	ra,t4,fail

test_13:
andi	ra,zero,240
li	t4,0
li	gp,13
bne	ra,t4,fail

test_14:
lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
andi	zero,ra,1807
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