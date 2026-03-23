.global read_keys

# a0 contains index to low digit
# a1 contains index to high digit
# a2 contains bit mask of pressed key
read_keys:
key_0:	andi t5, a2, 0x1   # check if key0 is pressed
	beqz t5, key_1
	li a0, 1
	li a1, 1
	j return

key_1:	andi t5, a2, 0x2   # check if key1 is pressed
	beqz t5, key_2
	addi a0, a0, 1
	li t5, 0x1         # ensure a1 displays something
	bge a1, t5, cont
	li a1, 1	   # make it display "0"
cont:
	li t5, 0x10
	bge t5, a0, return # 0x10 >= a0
	li a0, 1 	   # overflow a0 to display "0"
	addi a1, a1, 1
	bge t5, a1, return # 0x10 >= a1
	li a1, 1	   # overflow a1 to display "0"
	j return

key_2:	andi t5, a2, 0x4   # check if key2 is pressed
	beqz t5, key_3
	addi a0, a0, -1
	li t5, 0x1
	bge a0, t5, return # a0 >= 0x1
	li a0, 0x10        # overflow a0 to display "F"
	addi a1, a1, -1
	bge a1, t5, return # a1 >= 0x1
	li a1, 0x10        # overflow a1 to display "F"
	j return

key_3:	li a0, 0
	li a1, 0
return:
	ret