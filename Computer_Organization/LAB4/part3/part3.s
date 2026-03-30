# This program uses the Terminal window

.global _start 
_start:     li      sp, 0x20000         # set up the stack
            la      a0, string     
            jal     puts
            li      a0, 0xBEEF          # sample word
            jal     dec_word
            li      a0, '\n'
            jal     put_JTAG

end:        j       end

.equ JTAG_UART_BASE, 0xFF201000
# Subroutine to send a character to the JTAG UART
#   a0: character to send
.global put_JTAG 
put_JTAG:   la      t2, JTAG_UART_BASE
            lw      t0, 4(t2)           # read the JTAG UART control register
            lui     t1, 0xffff0         # t1 = 0xffff0000
            and     t0, t0, t1          # check for write space
            beqz    t0, end_put         # if no space, ignore the character
            sw      a0, (t2)            # send the character
end_put:    ret                         

# Subroutine to display a string on the JTAG Terminal window
#   a0: pointer to string
.global puts
puts:       addi    sp, sp, -8
            sw      ra, 4(sp)           # save
            sw      s0, (sp)

            mv      s0, a0              # save the string pointer
ploop:      lb      a0, (s0)            # get byte
            beqz    a0, puts_end        # string is null-terminated
            jal     put_JTAG            
            addi    s0, s0, 1           
            j       ploop                

puts_end:   lw      s0, (sp)            # restore
            lw      ra, 4(sp)
            addi    sp, sp, 8
            ret

# Subroutine displays a decimal representation of HEX word on the JTAG Terminal window
# a0: WORD to display
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

string:     .asciz  "\nWord value: " 
decimal:    .zero  11
