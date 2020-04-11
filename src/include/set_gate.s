%macro	set_gate 2-*
	push	eax
	push	edi

	mov	edi, %1
	mov	eax, %2

	mov	[edi + 0], ax
	shr	eax, 16
	mov	[edi + 6], ax
	
	pop	edi
	pop	eax
%endmacro
