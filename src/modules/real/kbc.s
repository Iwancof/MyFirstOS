KBC_Data_Write:	; KBC_Data_Write(data)
	push	bp
	mov	bp, sp

	push	cx

	mov	cx, 0		; max value(cx - 1 = 0xFFFF)
.10L:
	in	al, 0x64
	test	al, 0x02	; input buffer full. see 293p
	loopnz	.10L		; CX == 0 : timeout
				; ZF == 0 ; you can write data
	cmp	cx, 0
	jz	.20E		; timeout

	mov	al, [bp + 4]
	out	0x60, al

.20E:
	mov	ax, cx
	
	pop	cx

	mov	sp, bp
	pop	bp

	ret

KBC_Cmd_Write:	;KBC_Cmd_Write(data)
	push	bp
	mov	bp, sp

	push	cx

	mov	cx, 0		; max value(cx - 1 = 0xFFFF)
.10L:
	in	al, 0x64
	test	al, 0x02	; input buffer full. see 293p
	loopnz	.10L		; CX == 0 : timeout
				; ZF == 0 ; you can write data
	cmp	cx, 0
	jz	.20E		; timeout

	mov	al, [bp + 4]
	out	0x64, al

.20E:
	mov	ax, cx
	
	pop	cx

	mov	sp, bp
	pop	bp

	ret


KBC_Data_Read: ; KBC_Data_Read(adr)
	push	bp
	mov	bp,sp
	push	cx

	mov	cx, 0
.10L:
	in	al, 0x64
	test	al, 0x01
	loopz	.10L

	cmp	cx, 0		; timeout
	jz	.20E

	mov	ah, 0x00
	in	al, 0x60	; ax = return_value

	mov	di, [bp + 4]
	mov	[di + 0], ax

.20E:
	mov	ax, cx

	pop	cx
	mov	sp,bp
	pop	bp

	ret
