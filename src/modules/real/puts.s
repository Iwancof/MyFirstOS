puts:
	push	bp
	mov	bp,sp

	push	ax
	push	bx
	push	si

	mov	si,[bp + 4] ;si : Dist
	
	mov	ah,0x0E
	mov	bx,0x0000
	cld
.10L:
	lodsb	;al = *si;si++

	cmp 	al,0
	je	.10E ; exit

	int	0x10
	jmp	.10L ; loop
.10E:

	pop 	si
	pop	bx
	pop	ax

	mov	sp,bp
	pop	bp

	ret
