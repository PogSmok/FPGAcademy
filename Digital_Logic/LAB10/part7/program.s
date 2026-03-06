.define HEX_ADDRESS 0x20
.define SW_ADDRESS 0x30

	mvt r0, #0
	mvt r6, #SW_ADDRESS
DISPLAY:
	mvt r2, #HEX_ADDRESS
	mv r3, r0
DIV10:
	mv r1, #DATA
	mv r4, #0
DLOOP:	mv r5, #9
	sub r5, r3
	bcc DONE_DIV
INC: 	add r4, #1
	sub r3, #10
	b DLOOP
DONE_DIV:
	add r1, r3
	ld r5, [r1]
	st r5, [r2]
	mvt r5, #HEX_ADDRESS
	add r5, #5
	sub r5, r2
	beq DONE_DISPLAY
	add r2, #1
	mv r3, r4
	b DIV10
DONE_DISPLAY:
	add r0, #1
	ld r1, [r6]
	and r1, r1
	beq DISPLAY
OUTER:  mvt r2, #0xF
INNER:	sub r2, #1
	bne INNER
	sub r1, #1
	bne OUTER
	b DISPLAY
DATA:
    .word 0b00111111 // '0'
    .word 0b00000110 // '1'
    .word 0b01011011 // '2'
    .word 0b01001111 // '3'
    .word 0b01100110 // '4'
    .word 0b01101101 // '5'
    .word 0b01111101 // '6'
    .word 0b00000111 // '7'
    .word 0b01111111 // '8'
    .word 0b01101111 // '9'