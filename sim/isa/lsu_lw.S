li t2, 0x8f000000
li t0, 0x80000000
li t1, 0x00
li s0, 0x01000000
store_main:
sw t1, 0(t0)
add t1,t1,s0
addi t0,t0,4
bleu t1,t2,store_main

li t0, 0x80000000
li t1, 0x00
load_main:
lw t3, 0(t0)
add t1,t1,s0
addi t0,t0,4
bleu t1,t2,load_main

loop:
j loop