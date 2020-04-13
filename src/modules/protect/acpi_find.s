acpi_find:
	push	ebp
	mov	ebp, esp
	
	push	eax
	push	ecx
	push	edi

	mov	edi, [ebp + 8]	; address
	mov	ecx, [ebp +12]	; length
	mov	eax, [ebp +16]	; search string

	cld
.10L:
	repne	scasb		; compare only 1 byte(AL)

	cmp	ecx, 0
	jnz	.11E
	mov	eax, 0
	jmp	.10E		; failed
.11E:
	cmp	eax, [es:edi - 1]	; compare 4 bytes(name)
	jne	.10L
	
	dec	edi
	mov	eax, edi
.10E:
	
	pop	edi
	pop	ecx
	pop	ebx

	mov	esp, ebp
	pop	ebp

	ret

