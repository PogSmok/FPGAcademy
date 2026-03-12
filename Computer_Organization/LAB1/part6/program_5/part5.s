# Program that reverses text strings

.global _start
_start:     la      s0, string0  # pointer to string
            mv      a0, s0       # pass pointer to subroutine
            jal     slen         # returns string length in a0
            add     a1, s0, a0   # a1 points to string end
            mv      a0, s0       # a0 points to string start
            jal     srev         # reverse the string

            la      s0, string1  # pointer to string
            mv      a0, s0       # pass pointer to subroutine
            jal     slen         # returns string length in a0
            add     a1, s0, a0   # a1 points to string end
            mv      a0, s0       # a0 points to string start
            jal     srev         # reverse the string

stop:       j       stop

# Subroutine that returns the length of a string
# parameter: a0 points to the string
# returns: in a0 the number of characters in the string
slen:       mv a2, a0         # save pointer to beginning of string
slen_loop:  lb a1, (a0)	
            beqz a1, slen_end # check if end of string
            addi a0, a0, 1
            j slen_loop
slen_end:   sub a0, a0, a2    # calculate size of string
            ret

# Subroutine that reverses a string
# parameters: a0 = string start, a1 = string end
srev:       addi a1, a1, -1 # point to last character instead of null character
srev_loop:  bge a0, a1, srev_end
            lb t0, (a0)
            lb t1, (a1)
            sb t0, (a1)
            sb t1, (a0)
            addi a0, a0, 1
            addi a1, a1, -1
            j srev_loop
srev_end:
            ret

string0:    .asciz  "gnirts a si siht"
string1:    .asciz  "esrever dna daer"