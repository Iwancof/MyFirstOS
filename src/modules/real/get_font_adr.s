get_font_adr:
	
	push	bp
	mov	bp,sp
	
	push	si
	push	ax
	push	bx
	push	es
	push	bp
	
	mov	si,[bp + 4]
	mov	ax,0x1130
	mov	bh,0x06
	int	0x10

	mov	[si + 0],es
	mov	[si + 2],bp

	pop	bp
	pop	es
	pop	bx
	pop	ax
	pop	si

	mov	sp,bp
	pop	bp

	ret
