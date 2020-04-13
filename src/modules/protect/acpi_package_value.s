acpi_package_value:
	push	ebp
	mov	ebp, esp
	
	push	esi

	mov	esi, [ebp + 8]

	inc	esi
	inc	esi
	inc	esi

	; see 343p
	mov	al, [esi]
	cmp	al, 0x0B
	je	.C0B
	cmp	al, 0x0C
	je	.C0C
	cmp	al, 0x0E
	je	.C0E
	jmp	.C0A
.C0B:
.C0C:
.C0E:
	mov	al, [esi + 1]
	mov	ah, [esi + 2]
	jmp	.10E
.C0A:
	cmp	al, 0x0A
	jne	.11E
	mov	al, [esi + 1]
	inc	esi
.11E:
	inc	esi

	mov	ah, [esi]
	cmp	ah, 0x0A
	jne	.12E
	mov	ah, [esi + 1]
.12E:
.10E:
	pop	esi

	mov	esp, ebp
	pop	ebp

	ret
	

