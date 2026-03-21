.equ	HEX_BASE, 0xFF200020
.equ 	EDGE_BASE, 0xFF20005C

.global _start
_start:	
	li t0, EDGE_BASE # load pointer to key edge register
	li t1, HEX_BASE  # load pointer to hex register
	la t2, HEX_DIGIT # load pointer to hex digits	
	li a0, 0	 # a0 stores current low digit
	li a1, 0	 # a1 stores current high digit

loop:
	li t6, 5000000   # wait for a little while
dloop:	addi t6, t6, -1
	lw a2, (t0)	 # check if key is pressed
	beqz a2, cont
	call read_keys
	call disp
	li a2, 0xF	 # clear edge register
	sw a2, (t0)
cont:
	bnez t6, dloop
	
	li t5, 0x1         # ensure a1 displays something
	bge a1, t5, cont_1
	li a1, 1	   # make it display "0"	

cont_1:
	addi a0, a0, 1   # increment
	li t6, 0x10
	bge t6, a0, g_disp
	li a0, 1
	addi a1, a1, 1
	bge t6, a1, g_disp
	li a1, 0
g_disp:
	call disp
	j loop

disp:	
	add t5, a1, t2   # high digit
	lb t4, (t5)
	slli t4, t4, 8   # shift into high bits
	add t5, a0, t2   # low digit
	lb t5, (t5)
	or t4, t4, t5
	sw t4, (t1)
	ret

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