li t2, 0x8f00
li t0, 0x80000000
li t1, 0x00
store_main:
sh t1, 0(t0)
addi t0,t0,2
addi t1,t1,0x100
bleu t1,t2,store_main

li t0, 0x80000000
li t1, 0x00
load_main:
lhu t3, 0(t0)
addi t1,t1,0x100
addi t0,t0,2
bleu t1,t2,load_main

loop:
j loop