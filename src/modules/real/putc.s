putc:
	push	bp
	mov	bp,sp

	push	ax
	push	bx

	mov	al,[bp + 4]
	mov	ah,0x0E
	mov	bx,0x0000
	int	0x10

	pop	bx
	pop	ax

	mov	sp,bp
	pop	bp

	ret
