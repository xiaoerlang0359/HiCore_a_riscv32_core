
lui	ra,0xff1
addi	ra,ra,-256 # ff0f00 <_start-0x7f00f100>
xori	t5,ra,-241
lui	t4,0xff00f
addi	t4,t4,15 # ff00f00f <_end+0x7f00cfff>
	li	gp,2
bne	t5,t4,fail

lui	ra,0xff01
addi	ra,ra,-16 # ff00ff0 <_start-0x700ff010>
xori	t5,ra,240
lui	t4,0xff01
addi	t4,t4,-256 # ff00f00 <_start-0x700ff100>
	li	gp,3
bne	t5,t4,fail

lui	ra,0xff1
addi	ra,ra,-1793 # ff08ff <_start-0x7f00f701>
xori	t5,ra,1807
lui	t4,0xff1
addi	t4,t4,-16 # ff0ff0 <_start-0x7f00f010>
	li	gp,4
bne	t5,t4,fail

lui	ra,0xf00ff
addi	ra,ra,15 # f00ff00f <_end+0x700fcfff>
xori	t5,ra,240
lui	t4,0xf00ff
addi	t4,t4,255 # f00ff0ff <_end+0x700fd0ef>
	li	gp,5
bne	t5,t4,fail

lui	ra,0xff00f
addi	ra,ra,1792 # ff00f700 <_end+0x7f00d6f0>
xori	ra,ra,1807
lui	t4,0xff00f
addi	t4,t4,15 # ff00f00f <_end+0x7f00cfff>
	li	gp,6
bne	ra,t4,fail

lui	ra,0xff0
addi	ra,ra,255 # ff00ff <_start-0x7f00ff01>
xori	zero,ra,1807
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