panic_handler : 
	int	0xFF
	ret

panic:
	pusha
	push	ds
	push	es

	mov	ax, 0x0010
	mov	ds, ax
	mov	es, ax

	cdecl	draw_str, 25, 10, 0x000c, .t0
	cdecl	draw_str, 25, 11, 0x000c, panic_message

	pop	es
	pop	ds

	popa

	jmp	$

	iret

.t0:	db	"RUST Panic!!",0


