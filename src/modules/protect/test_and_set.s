test_and_set:
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx

	mov	eax, 0		; set bit
	mov	ebx, [ebp + 8]	; global variable

.10L:
	lock	bts [ebx], eax
	jnc	.10E		; we can use registers
.12L:
	bt	[ebx], eax
	jc	.12L		; we can not use

	jmp	.10L
.10E:
	
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

