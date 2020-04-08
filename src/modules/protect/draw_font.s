draw_font:
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx

	mov	ecx, 0
.10L:
	cmp	ecx,256
	jae	.10E

	mov	eax, ecx
	and	eax, 0b00001111
	add	eax, [ebp + 8]

	mov	ebx, ecx
	shr	ebx, 4
	add	ebx, [ebp +12]

	cdecl	draw_char, eax, ebx, 0x07, ecx
	
	inc	ecx
	jmp	.10L

.10E:

	pop	ecx
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret



