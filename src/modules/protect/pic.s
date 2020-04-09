init_pic:	; () -> ()
; see p298
; ICW -- Initializion command words
	push	eax

	outp	0x20, 0x11	; ICW1, ICW4 enable
	outp	0x21, 0x20	; ICW2, base address is 0x20
	outp	0x21, 0x04	; ICW3, slave position, 0b0000_0100. on third
	outp	0x21, 0x05	; ICW4, ???
	outp	0x21, 0xFF	; mask

	outp	0xA0, 0x11	; ICW1, ICW4 enable
	outp	0xA1, 0x28	; ICW2, base address is 0x28(0x20 + 8(master))
	outp	0xA1, 0x02	; slave ID is 0x02
	outp	0xA1, 0x01	; normal end of interrupt
	outp	0xA1, 0xFF	; mask

	pop	eax

	ret
