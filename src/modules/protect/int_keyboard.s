int_keyboard:
	pusha
	push	ds
	push	es

	mov	ax, 0x0010	; SEL_DATA. see 468p
	mov	ds, ax
	mov	es, ax
