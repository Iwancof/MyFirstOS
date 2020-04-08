read_chs: ;read_chs(drive_address,sectors,dst)
	
	push	bp
	mov	bp,sp

	push	3	; number of trying
	push	0	; sectors

	push	bx
	push	cx
	push	dx
	push	es
	push	si

	mov	si,[bp + 4]	; this is address.

	mov	ch,[si + drive.cyln + 0]
	mov	cl,[si + drive.cyln + 1]
	shl	cl,6		; xxxxxxxx xx______
	or	cl,[si + drive.sect]

	mov	dh,[si + drive.head]
	mov	dl,[si + drive.no]
	mov	ax,0x0000
	mov	es,ax
	mov	bx,[bp + 8]	; bx = dst
.10L:
	mov	ah,0x02
	mov	al,[bp + 6]	; al = sectors

	int	0x13
	jnc	.11E		

	mov	al,0
	jmp	.10E
.11E:	
	cmp	al,0
	jne	.10E

	mov	ax,0
	dec	word [bp - 2]	; dec trying number
	jnz	.10L
.10E:				; exit
	mov	ah,0

	;cdecl	itoa, word[bp - 2],.s1,8,10,0b0000
	;cdecl	puts, .s1

	pop si
	pop es
	pop dx
	pop cx
	pop bx

	mov	sp,bp
	pop	bp

	ret

.s1	db	"--------"


