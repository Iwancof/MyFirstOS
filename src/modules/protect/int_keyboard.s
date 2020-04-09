int_keyboard:
	pusha
	push	ds
	push	es

	mov	ax, 0x0010	; SEL_DATA. see 468p
	mov	ds, ax
	mov	es, ax

	in	al, 0x60
	; see 291p
	; when interrupted, data can be read

	cdecl	ring_wr, _KEY_BUFF, eax
	
	outp	0x20, 0x20
	; end of interrupt command to master only

	pop	es
	pop	ds
	popa

	iret

ALIGN	4,	db	0
_KEY_BUFF:	times	ring_buff_size	db	0
; ring buff
; ring_buff_size is struct "ring_buff"'s size created by nasm

	
