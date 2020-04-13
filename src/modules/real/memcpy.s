memcpy:	;memcpy(void* dest,void* src,size_t size);
	push	bp
	mov	bp,sp

	push	di
	push	si
	push	cx

	cld
	mov	di,[bp + 4]
	mov	si,[bp + 6]
	mov	cx,[bp + 8]

	rep	movsb

	pop	cx
	pop	si
	pop	di

	mov	sp,bp
	pop	bp

	ret
