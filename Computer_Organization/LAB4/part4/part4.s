# This program displays a selected save register on the Terminal window

.equ SW_BASE, 0xFF200040
.equ KEY_BASE, 0xFF200050
.equ JTAG_UART_BASE, 0xFF20100

.global _start 
_start:     li      sp, 0x20000         # set up the stack
            la      a0, prompt    
            jal     puts
            la      s0, SW_BASE
            la      s1, KEY_BASE

            addi    sp, sp, -48        # load save registers onto stack 
get_KEY:    
            lw      s2, 0(s1)
            beqz    s2, get_KEY        # no keys are pressed

	    sw      s0, 0(sp)
	    sw      s1, 4(sp)
	    sw      s2, 8(sp)
	    sw      s3, 12(sp)
	    sw      s4, 16(sp)
	    sw      s5, 20(sp)
	    sw      s6, 24(sp)
	    sw      s7, 28(sp)
	    sw      s8, 32(sp)
	    sw      s9, 36(sp)
	    sw      s10, 40(sp)
	    sw      s11, 44(sp)

	    la      a0, string         # print "Contents of s"
            jal     puts
            lw      s3, (s0)         
	    li      t0, 12	       # cap register index to 11
            blt     s3, t0, cont
	    li      s3, 11
cont:
            mv      a0, s3
	    jal     dec_word           # print register index
            la      a0, separator
            jal     puts               # print seprator
	    slli    t0, s3, 2          # offset = index*4
	    add     t0, t0, sp
	    lw      a0, 0(t0)
            li      t1, 1
            beq     s2, t1, hex
            jal     dec_word
            j       next
hex:        jal     hex_word

next:       li      a0, '\n'
            jal     put_JTAG
release:    lw      t0, (s1)            # wait for button release
            beqz    t0, get_KEY
            j       release

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
 
prompt: .asciz "Press a pushbutton KEY to continue...\n"
string: .asciz "Contents of s"
separator: .asciz ": "