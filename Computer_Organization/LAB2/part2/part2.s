.global	_start
_start:	la t0, test_num # t0 = address of data word
	xor s0, s0, s0 # store highest number of 1s here
loop:	lw a0, (t0) # t0 = data word
	addi t0, t0, 4 # point at next word
	beqz a0, stop # when word is 0 end
	jal ones
	bge s0, a0, loop
	mv s0, a0
	j loop	

stop:	j stop


ones:	
	xor a1, a1, a1
o_loop:	beqz a0, end # loop until a0 has no more 1s
	srli t1, a0, 1 # shift and then ...
	and a0, a0, t1 # and to count the 1s
	addi a1, a1, 1 # increment counter
	j o_loop

end:	mv a0, a1
	ret

test_num: 
	.word 0x103fe00f
	.word 0xffffffff
	.word 0xff00ffc0
	.word 0x11111111
	.word 0x00000001
	.word 0x070701f7
	.word 0x01234567
	.word 0x89abcdef
	.word 0x78aaaaaa
	.word 0x01248f70
	.word 0x00000000
