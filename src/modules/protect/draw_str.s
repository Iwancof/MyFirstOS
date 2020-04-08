draw_str:	; draw_str(row,col,color,str)
	push	ebp
	mov	ebp, esp
	
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi

	mov	ebx, [ebp + 8]
	mov	ecx, [ebp +12]
	movzx	edx, word [ebp +16]
	mov	esi, [ebp +20]
	
	cld
.10L:
	;mov	eax, 0
	lodsb
	cmp	al, 0
	je	.10E
	cdecl	draw_char, ebx, ecx, edx, eax
	inc	ebx
	cmp	ebx, 80
	jl	.10L
	mov	ebx, 0
	inc	ecx
	cmp	ecx, 30
	jl	.10L
	mov	ecx, 0
	
	jmp	.10L
.10E:

	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret
