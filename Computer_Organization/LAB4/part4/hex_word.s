# Subroutine displays a hexadecimal value of a WORD on the JTAG Terminal window
#   a0: the hex WORD to display    
.global hex_word
hex_word:   addi    sp, sp, -12	
            sw      ra, 8(sp)           # save
            sw      s0, 4(sp)
            sw	    s1, (sp)

            mv      s0, a0		# preserve WORD
            li      s1, 0x1C            # how many bits to shift 
            la      a0, hex_prefix      # print 0x
            jal     puts
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

hex_prefix: .asciz "0x"