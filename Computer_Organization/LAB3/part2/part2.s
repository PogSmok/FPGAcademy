.equ	HEX_BASE, 0xFF200020
.equ 	KEY_BASE, 0xFF200050

.global _start
_start:	
	li t0, KEY_BASE  # load pointer to key register
	li t1, HEX_BASE  # load pointer to hex register
	la t2, HEX_DIGIT # load pointer to hex digits	
	li t3, 0	 # t3 stores current digit, 0=blank,1='0',2='1'

loop:	lw t4, (t0)      # read keys
	beqz t4, loop	 # no keys pressed

key_0:	andi t5, t4, 0x1 # check if key0 is pressed
	beqz t5, key_1
	li t3, 1
	j disp

key_1:	andi t5, t4, 0x2 # check if key1 is pressed
	beqz t5, key_2
	addi t3, t3, 1
	li t6, 0x10
	bge t6, t3, disp # 0x10 >= t3
	li t3, 0x10	 # cap t3 to 0x10
	j disp

key_2:	andi t5, t4, 0x4 # check if key2 is pressed
	beqz t5, key_3
	addi t3, t3, -1
	li t6, 0x1
	bge t3, t6, disp # t3 >= 0x1
	li t3, 0x1	 # cap t3 to 0x1
	j disp

key_3:	li t3, 0

disp:	add t5, t3, t2
	lb t4, (t5)
	sb t4, (t1)
hold:	lw t4, (t0)
	beqz t4, loop # wait for release
	j hold

.data 
HEX_DIGIT:
	.byte 0x00 # blank
	.byte 0x3F
    	.byte 0x06
    	.byte 0x5B
    	.byte 0x4F
    	.byte 0x66
    	.byte 0x6D
    	.byte 0x7D
    	.byte 0x07
    	.byte 0x7F
    	.byte 0x6F
    	.byte 0x77
    	.byte 0x7C
    	.byte 0x39
    	.byte 0x5E
    	.byte 0x79
    	.byte 0x71