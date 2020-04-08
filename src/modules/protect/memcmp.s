memcmp:
	push	ebp
	mov	ebp,esp

	push	ebx
	push	ecx
	push	edx
	push	esi
	push 	edi

	cld
	mov	esi,[ebp + 8]
	mov	edi,[ebp + 12]
	mov	ecx,[ebp + 16]

	repe	cmpsb
	jnz	.10F	;not match
	mov	eax,0
	kmp	.10E	;match
.10F
	mov	eax,-1
.10E ;exit
	
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx

	mov	esp,ebp
	pop	ebp

	ret


