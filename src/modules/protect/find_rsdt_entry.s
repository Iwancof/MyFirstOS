find_rsdt_entry:
	push	ebp
	mov	ebp, esp

	push	ebx
	push	ecx
	push	esi
	push	edi

	mov	esi, [ebp + 8]	; table address
	mov	ecx, [ebp +12]	; name

	mov	ebx, 0

	mov	edi, esi
	add	edi, [esi + 4]	; [esi + 4] is header length
	add	esi, 36
	
	; search from esi to edi
.10L:
	cmp	esi, edi
	jge	.10E

	lodsd			; eax = [esi]; esi++

	cmp	[eax], ecx
	jne	.10L
	mov	ebx, eax
.10E:
	mov	eax, ebx	

	pop	edi
	pop	esi
	pop	ecx
	pop	ebx

	mov	esp, ebp
	pop	ebp

	ret
