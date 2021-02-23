li t2, 0x8f
li t0, 0x80000000
li t1, 0x00
store_main:
sb t1, 0(t0)
addi t0,t0,1
addi t1,t1,1
ble t1,t2,store_main

li t0, 0x80000000
li t1, 0x00
load_main:
lbu t3, 0(t0)
addi t1,t1,1
addi t0,t0,1
ble t1,t2,load_main

loop:
j loop