draw_rect:	; draw_rect(x0,y0,x1,y1,color)
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi

	mov	eax, [ebp + 8]	; x0
	mov	ebx, [ebp +12]	; y0
	mov	ecx, [ebp +16]	; x1
	mov	edx, [ebp +20]	; y1
	mov	esi, [ebp +24]	; color

	; make "eax(x0) <= ebx(x1)" and
	;      "ecx(y0) <= edx(y1)"
	
	cmp	eax, ecx
	jl	.10E		; OK
	xchg	eax, ecx
.10E:
	cmp	ebx, edx
	jl	.20E		; OK
	xchg	ebx, edx
.20E:
	; (EAX,EBX) -------- (ECX,EBX)
	;     |			 |
	;     |			 |
	;     |			 |
	;     |			 |
	; (EAX,EDX) -------- (ECX,EDX)

	cdecl	draw_line, eax, ebx, ecx, ebx, esi
	cdecl	draw_line, eax, ebx, eax, edx, esi

	dec	edx
	cdecl	draw_line, eax, edx, ecx, edx, esi
	inc	edx

	dec	ecx
	cdecl	draw_line, ecx, ebx, ecx, edx, esi

	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

