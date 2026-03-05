.define LED_ADDRESS 0x10
.define SW_ADDRESS 0x30

	mvt r4, #LED_ADDRESS
	mvt r5, #SW_ADDRESS
	and r0, r0
MAIN:	st r0, [r4]
	add r0, #1
	ld r1, [r5]
	and r1, r1
	beq MAIN
OUTER:	mvt r2, #0xF
INNER:	sub r2, #1
	bne INNER
	sub r1, #1
	bne OUTER
	b MAIN