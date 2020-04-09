%macro	set_vect 1-*.nolist	; vector_number, function_pointer
	push	eax
	push	edi

	mov	edi, VECT_BASE + (%1 * 8)	; number converts to address
	mov	eax, %2
	
	%if	%0 == 3
		mov	[edi + 4],%3
	%endif

	mov	[edi + 0], ax			; bottom
	shr	eax, 16
	mov	[edi + 6], ax			; tom


	pop	edi
	pop	eax
%endmacro
