.equ LED_BASE, 0xFF200000
.equ KEY_BASE, 0xFF200050
.equ MTIME_BASE, 0xFF202100
.equ MTIMECMP_BASE, 0xFF202108

.global _start
_start:     # set up stack location
            li      sp, 0x20000

            jal     set_timer           # initialize the timer
            jal     setup_KEY           # configure the KEY port
     
            # enable interrupts for Machine Timer and KEY port
            la      t0, handler
            csrw    mtvec, t0           # set trap address
            li      t0, 0x40080
            csrs    mie, t0             # enable machine timer interrupt (0x80) and key interrupt (0x40000)
            csrsi   mstatus, 0b1000     # enable Nios V interrupts

            la      s0, counter         # pointer to counter
            li      s1, LED_BASE        # pointer to red lights
loop:       wfi
            lw      a0, (s0)            # load the counter value
            sw      a0, (s1)            # write to the lights
            j       loop

# Trap handler
handler:    addi    sp, sp, -12
            sw      t0, 0(sp)
            sw      t1, 4(sp)
            sw      t2, 8(sp)
            csrr    t0, mcause
            li      t1, 0x80000007      # machine timer interrupt
            beq     t0, t1, timer_irq
            li      t1, 0x80000012      # key interrupt
            beq     t0, t1, key_irq
stay:       j       stay                # unexpected cause of trap

key_irq:    la      t0, run
            lw      t1, (t0)
            xori    t1, t1, 1           # swap run state
            sw      t1, (t0)
            li      t0, KEY_BASE
            lw      t1, 12(t0)
            sw      t1, 12(t0)          # clear interrupt mask
            j       irq_ret

timer_irq:  la      t0, run             # increment counter by run
            lw      t0, (t0)
            la      t1, counter
            lw      t2, (t1)
            add     t0, t2, t0
            sw      t0, (t1)
	    la      t0, MTIME_BASE      # reset mtime to 0
            sw      x0, (t0)
            sw      x0, 4(t0)
irq_ret:
            lw      t0, 0(sp)
            lw      t1, 4(sp)
            lw      t2, 8(sp)
            addi    sp, sp, 12
            mret

# Set Machine Timer for 1/4 second timeout
set_timer:
            li      t0, 0x017D7840      # 25_000_000             
            la      t1, MTIMECMP_BASE
            sw      t0, (t1)
	    sw      x0, 4(t1)
            la      t2, MTIME_BASE
            sw      x0, (t2)
            sw      x0, 4(t2)
            ret

# Enable interrupts in the KEY port
setup_KEY:
            li      t0, KEY_BASE
            li      t1, 0b1111
            sw      t1, 8(t0)
            ret  

counter:    .word   0                   # the counter to be displayed
run:        .word   1                   # the amount to be added
