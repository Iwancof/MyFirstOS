itoa:	;itoa(num,buf,size,radix,flag);
	push 	bp
	mov	bp,sp

	
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di


	;init
	mov	bx, word [bp + 12]	; bx = flag
	mov	cx,	 [bp + 8]	; cx = size
	mov	si,	 [bp + 6]	; si = dist

	mov	di,si

	;cmp	cx,0
	;jg	.10A
	;jmp	.40A		; no buffer

.10A:				; start

	mov	al,' '
	test	bx, 0b0100
	je	.42E
	mov	al,'0'
.42E:


	cld
	rep	stosb

	mov	ax,[bp + 4]	; ax = num	
	mov	cx,[bp + 8]	; cx = size
	mov	di,si
	add	di,cx		; di is tail of buffer
	dec	di

	test	bx,0b0001	; tmp flag.is_signed
.10Q:	jz	.10E		; if tmp == unsigned 
  	cmp	ax,0		; check(ax - 0)
.12Q:	jge	.12E		; if 0 <= ax goto .12E
	or	bx,0b0010	; flag |= print_sign
.12E:
.10E:
	

	test	bx,0b0010	; if flag.print_size
.20Q:	je	.20E		; not print sign
	cmp 	ax,0		; check(ax - 0)
	jge	.22F		; if 0 <= ax got .22F
	neg	ax		; ax *= -1
	mov	[si],byte '-'
	jmp	.22E
.22F:	mov	[si],byte '+'
.22E:	dec	cx		; finaly
.20E:

	mov	bx,[bp + 10]	; bx = radix
.30L:
	
	mov	dx, 0
	div	bx		; DX = AX % radix
				; AX = AX / radix

	mov	si,dx
	mov	dl,byte[.ascii + si]	; DL = ASCII[DX]

	mov	[di],dl		; start writing in tail of buffer
	dec	di

	cmp	ax,0
	loopnz	.30L

.40A:

	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	mov	sp,bp
	pop	bp

	ret

.ascii	db	"0123456789ABCDEF"

	
	
	
