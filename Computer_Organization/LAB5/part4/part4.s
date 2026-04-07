.equ HEX3_HEX0_BASE,  0xFF200020
.equ SW_BASE,         0xFF200040
.equ MTIME_BASE,      0xFF202100
.equ MTIMECMP_BASE,   0xFF202108

.global _start
_start:     # set up stack location
            li      sp, 0x20000

            jal     set_timer           # initialize the timer
     
            la      t0, handler
            csrw    mtvec, t0           # set trap address
            li      t0, 0x80
            csrs    mie, t0             # enable machine timer interrupt (0x80)
            csrsi   mstatus, 0b1000     # enable Nios V interrupts

            la      s0, HEX_code        # pointer to variable
            la      s1, HEX3_HEX0_BASE  # pointer to displays
            la      s2, SW_BASE         # pointer to switches
loop:       wfi
            lw      t0, (s0)            # load the counter value
            sw      t0, (s1)            # write to the lights
wait:       lw      t0, (s2)            # if any SW is set, wait
            bnez    t0, wait            

            j       loop

# Trap handler
handler:    addi    sp, sp, -16
            sw      ra, (sp)
            sw      a0, 4(sp)
            sw      t0, 8(sp)
            sw      t1, 12(sp)

            csrr    t0, mcause
            li      t1, 0x80000007      # machine timer interrupt
            beq     t0, t1, timer_irq
stay:       j       stay                # unexpected cause of trap

timer_irq:  la      t0, time
            lw      a0, (t0)
            addi    a0, a0, 1
            li      t1, 6001
            bne     a0, t1, irq_cont
            mv      a0, x0              # reset to 0 after counting 60 seconds
irq_cont:
            sw      a0, (t0)
            jal     display

	    la      t0, MTIME_BASE      # reset mtime to 0
            sw      x0, (t0)
            sw      x0, 4(t0)

            lw      ra, (sp)
            lw      a0, 4(sp)
            lw      t0, 8(sp)
            lw      t1, 12(sp)
            addi    sp, sp, 16
            mret

# Set Machine Timer for 1/100 second timeout
set_timer:  
            la      t0, MTIME_BASE
            sw      x0, 0(t0)
            sw      x0, 4(t0)
            la      t0, MTIMECMP_BASE
            li      t1, 0x000F4240      # CLK has 100_000_000 Hz, so count to 1_000_000
            sw      t1, 0(t0)
            sw      x0, 4(t0)
            ret

# Convert the time value to codes for display on HEX3-0; store in HEX_code
display:    addi    sp, sp, -12
            sw      ra, (sp)
            sw      s0, 4(sp)
            sw      s1, 8(sp)
            
            la      s0, time
            lw      s0, (s0)

            # extract centiseconds
            li      t0, 100
            remu    s1, s0, t0
            li      t1, 10
            remu    a0, s1, t1 
            divu    s1, s1, t1

            # get 7 segment code for HEX0
            jal     seg7_code
            la      t0, HEX_code
            sb      a0, (t0)

            # get 7 segment code for HEX1
            mv      a0, s1
            jal     seg7_code
            la      t0, HEX_code
            sb      a0, 1(t0)

            # extract seconds
            li      t0, 100
            divu    s1, s0, t0
            li      t1, 10
            remu    a0, s1, t1
            divu    s1, s1, t1

            # get 7 segment code for HEX2
            jal     seg7_code
            la      t0, HEX_code
            sb      a0, 2(t0)

            # get 7 segment code for HEX3
            mv      a0, s1
            jal     seg7_code
            la      t0, HEX_code
            sb      a0, 3(t0)

            lw      ra, (sp)
            lw      s0, 4(sp)
            lw      s1, 8(sp)
            addi    sp, sp, 12
            ret

# Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
# Parameters: a0 = the decimal digit to be displayed
# Returns: a0 = bit pattern to be written to the HEX display
seg7_code:  la      t0, bit_codes       # starting address of the bit codes
            add     t0, t0, a0          # index into the bit codes
            lb      a0, (t0)            # load the bit code
            ret

time:       .word   0                   # the time value
HEX_code:   .word   0                   # the display codes
# 7-segment codes for digits 0, 1, ..., 9
bit_codes:  .byte   0x3f, 0x06, 0x5b, 0x4f, 0x66
            .byte   0x6d, 0x7d, 0x07, 0x7f, 0x67
