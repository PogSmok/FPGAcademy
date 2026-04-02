# Subroutine displays a decimal representation of HEX word on the JTAG Terminal window
# a0: WORD to display
.global dec_word
dec_word:   addi    sp, sp, -12
            sw      ra, 8(sp)
	    sw      s0, 4(sp)
            sw      s1, (sp)

	    jal     get_dec
	    la      s0, decimal
	    addi    s0, s0, -1          # substract to simplify skip_lead logic

skip_lead:  addi    s0, s0, 1
	    lbu     t0, (s0)
	    beqz    t0, skip_lead 

	    li      s1, 0xFF            # decimal space terminator
            lbu     a0, (s0)
            bne     a0, s1, display

	    li      a0, 0x30            # print 0 if WORD=0
            jal     put_JTAG
            j       ret_word

display:    lbu     a0, (s0)
            addi    s0, s0, 1
	    beq     a0, s1, ret_word
	    addi    a0, a0, 0x30        # add for all ASCII codes
            jal     put_JTAG
            j 	    display

ret_word:
            lw      s1, (sp)
	    lw      s0, 4(sp)
            lw      ra, 8(sp)
            addi    sp, sp, 12
            ret

# Subroutine calculates decimal representation of WORD and stores it in decimal
# each digit is a separate byte, e.g. 0x12 -> (18) 0x01 0x08
# decimal space is terminated with 0xFF
# a0: WORD to convert
get_dec:    addi    sp, sp, -4
            sw      ra, (sp)

            li      t2, 0
            la      t0, decimal
            li      t1, 10
clear_dec: 				# clear decimal space
            sb      t2, (t0)
            addi    t0, t0, 1
            addi    t1, t1, -1
            bne     t1, x0, clear_dec

	    li      t2, 0xFF
	    sb      t2, (t0)            # terminate decimal space

	    la      t0, decimal         # pointer to the beginning of decimal space
	    addi    t0, t0, 9           # points to last character of decimal space
	    mv	    t1, a0
            li      t2, 10

calc:       beqz    t1, ret_dec
	    remu    t3, t1, t2
	    divu    t1, t1, t2
	    sb      t3, (t0)
	    addi    t0, t0, -1
	    j       calc

ret_dec:
            lw      ra, (sp)
            addi    sp, sp, 4
            ret

decimal:    .zero  11