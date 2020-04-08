lba_chs:	; lba_chs(drive_param,drive_adr,lba)
	push	bp
	mov	bp,sp
	
	push	si
	push	ax
	push	dx
	push	bx
	push	di

	mov	si, [bp + 4]
	mov	di, [bp + 6]

	mov	al, [si + drive.head]
	mul	byte [si + drive.sect]	; ax *= drive_param.sect
	mov	bx, ax			; bx is sectors per cylynder

	mov	dx, 0
	mov	ax, [bp + 8]		; DIV --> DX:AX
	div	bx			; DX = DX:AX % BX
					; AX = DX:AX / BX
	
	mov	[di + drive.cyln], ax
	
	mov	ax,dx			
	div	byte [si + drive.sect]	; DIV(byte) --> AX  (not use DX:AX)
					; AH = AX % sects
					; AL = AX / sects

	movzx	dx, ah
	inc	dx

	mov	ah, 0x00		; because, We want to access AX,DX

	mov	[di + drive.head], ax	; ah = 0 so AX = AL
	mov	[di + drive.sect], dx
	
	pop	di
	pop	bx
	pop	dx
	pop	ax
	pop	si

	mov	sp,bp
	pop	bp

	ret
