draw_rotation_bar:
	push	ebp
	mov	ebp, esp
	
	push	eax

	mov	eax, [TIMER_COUNT]
	shr	eax, 8
	cmp	eax, [.index]	; per 10ms * 16
	je	.10E

	mov	[.index], eax
	and	eax, 0x03

	mov	al, [.table + eax]
	cdecl	draw_char, 0, 29, 0x000F, eax
.10E:
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

ALIGN	4,	db	0
.index:		dd	0
.table:		dd	"|/-\"
