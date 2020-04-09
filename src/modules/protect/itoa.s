itoa:	;itoa(num,buf,size,radix,flag);
	push 	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi


	;init
	movzx	ebx, word [ebp + 24]	; bx = flag
	mov	ecx, [ebp + 16]	; cx = size
	mov	esi, [ebp + 12]	; si = dist

	mov	edi, esi

	;cmp	cx,0
	;jg	.10A
	;jmp	.40A		; no buffer

.10A:				; start

	mov	al,' '
	test	ebx, 0b0100
	je	.42E
	mov	al,'0'
.42E:
	cld
	rep	stosb

	mov	eax, [ebp + 8]	; ax = num	
	mov	ecx, [ebp + 16]	; cx = size
	mov	edi, esi
	add	edi, ecx		; di is tail of buffer
	dec	edi

	test	ebx, 0b0001	; tmp flag.is_signed
.10Q:	jz	.10E		; if tmp == unsigned 
  	cmp	eax, 0		; check(ax - 0)
.12Q:	jge	.12E		; if 0 <= ax goto .12E
	or	ebx, 0b0010	; flag |= print_sign
.12E:
.10E:
	

	test	ebx, 0b0010	; if flag.print_size
.20Q:	je	.20E		; not print sign
	cmp 	eax,0		; check(ax - 0)
	jge	.22F		; if 0 <= ax got .22F
	neg	eax		; ax *= -1
	mov	[esi], byte '-'
	jmp	.22E
.22F:	mov	[esi], byte '+'
.22E:	dec	ecx		; finaly
.20E:

	mov	ebx,[ebp + 20]	; bx = radix
.30L:
	
	mov	edx, 0
	div	ebx		; DX = AX % radix
				; AX = AX / radix

	mov	esi, edx
	mov	dl, byte [.ascii + esi]	; DL = ASCII[DX]

	mov	[edi],dl		; start writing in tail of buffer
	dec	edi

	cmp	eax,0
	loopnz	.30L

.40A:

	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

.ascii	db	"0123456789ABCDEF"

	
	
	
