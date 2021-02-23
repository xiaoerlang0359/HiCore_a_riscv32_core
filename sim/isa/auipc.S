test_2:
nop
nop
auipc	a0,0x2
addi	a0,a0,1820 # 80002984 <_end+0x974>
jal	a1, next_2
next_2:
sub	a0,a0,a1
lui	t4,0x2
addi	t4,t4,1808 # 2710 <_start-0x7fffd8f0>
li	gp,2
bne	a0,t4,fail

test_3:
nop
auipc	a0,0xffffe
addi	a0,a0,-1796 # 7fffdb84 <_start-0x247c>
jal	a1,next_3
next_3:
sub	a0,a0,a1
lui	t4,0xffffe
addi	t4,t4,-1808 # ffffd8f0 <_end+0x7fffb8e0>
li	gp,3
bne	a0,t4,fail
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