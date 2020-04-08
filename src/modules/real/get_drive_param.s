get_drive_param:
	
	push	bp
	mov	bp,sp
	
	push	dx
	push	si
	push	cx
	push	bx
	push	di
	push	es

	mov	si,[bp + 4]

	mov	ax,0
	mov	es,ax
	mov	di,ax
	
	mov	dl,[si + drive.no]
	mov	ah,0x08
	mov	cx,0
	int	0x13	; get drive param
	jc	.10F	; error

	mov	ax,cx
	and	ax,0b00111111
	mov	[si + drive.sect],ax	; sector

	shr	cl,6
	ror	cx,8			;CH,CL = CL,CH
	add	cx,1
	mov	[si + drive.cyln],cx	; cylnder

	mov	bx,dx
	shr	bx,8
	add	bx,1
	mov	[si + drive.head],bx

	mov	ax,1				; seccess
	
	jmp	.10E
.10F:
	mov	ax,0
.10E:

	pop	es
	pop	di
	pop	bx
	pop	cx
	pop	si
	pop	dx

	mov	sp,bp
	pop	bp

	ret
