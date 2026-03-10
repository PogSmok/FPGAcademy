# Program that finds the largest number in a list of integers
.global _start

_start: la 	s0, result
	lw 	a0, 4(s0) # a0 holds number of list elements
	addi 	a1, s0, 8 # a1 points to the list
	jal 	ra, large
	sw 	a0, (s0)  # store result

stop: 	j 	stop # wait here

large:
	lw 	a3, (a1)	  # initialize the max element to first element
skip_init:
	addi 	a0, a0, -1 	  # decrement the iterator
	beqz	a0, finish 	  # if iterator is equal zero finish
	addi	a1, a1, 4  	  # increment pointer to point at next element (each word is 4 bytes)
	lw 	a2, (a1)  	  # load element
	blt	a2, a3, skip_init # if current max element is >= than current element continue
	mv	a3, a2     	  # set current max element as current element
	j 	skip_init
finish:
	mv	a0, a3     	  # store max integer in ABI return value register (r0)
	ret

result:	.word 0 # result will be stored here
N: 	.word 7 # number of entries in the list
numbers:
	.word 4, 5, 3, 6 # numbers in the list
	.word 1, 8, 2    # ...