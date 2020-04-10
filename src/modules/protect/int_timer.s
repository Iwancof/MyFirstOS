int_timer:
	pushad
	push	es
	push	ds

	mov	ax, 0x10
	mov	ds, ax
	mov	es, ax

	inc	dword[TIMER_COUNT]

	outp	0x20, 0x20

	pop	ds
	pop	es
	popad

	iret

ALIGN	4,	db	0
TIMER_COUNT:	dq	0


int_en_timer:
	push	ebp
	mov	ebp, esp
	
	push	eax

	outp	0x43, 0b00_11_010_0
	; counter 0
	; access mode, bottom -> top
	; mode, 2
	; bcd

	outp	0x40, 0x9C
	outp	0x40, 0x2E
	; 2E9C(16) = 11932(10) = (1193182 / 100)

	pop	eax

	mov 	esp, ebp
	pop	ebp

	ret


