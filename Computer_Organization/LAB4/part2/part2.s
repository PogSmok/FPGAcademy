# This program uses the Terminal window

.global _start 
_start:     li      sp, 0x20000         # set up the stack
            la      a0, string     
            jal     puts
            li      a0, 0xBEEF         # sample WORD
            jal     hex_word
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
     
# Subroutine displays a hexadecimal value of a WORD on the JTAG Terminal window
#   a0: the hex WORD to display    
.global hex_word
hex_word:   addi    sp, sp, -12	
            sw      ra, 8(sp)           # save
            sw      s0, 4(sp)
            sw	    s1, (sp)

            mv      s0, a0		# preserve WORD
            li      s1, 0x1C            # how many bits to shift 
extract:    
            srl     a0, s0, s1
            andi    a0, a0, 0xF
            li      t0, 0xA
            blt	    a0, t0, number
letter:     addi    a0, a0, 0x7         # add extra for A to F ASCII codes
number:     addi    a0, a0, 0x30        # add for all ASCII codes	
            jal	    put_JTAG
            beqz    s1, word_end
            addi    s1, s1, -4
            j 	    extract
word_end:
            lw      s1, (sp)            # restore
            lw	    s0, 4(sp)
            lw      ra, 8(sp)
            addi    sp, sp, 12
            ret	

string:     .asciz  "\nWord value: 0x" 
