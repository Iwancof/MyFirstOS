%macro	set_desc	2-*
	push	eax
	push	edi

	mov	edi, %1
	mov	eax, %2

	%if %0 == 3
		mov	[edi + 0], %3
	%endif

	mov	[edi + 2], ax
	shr	eax, 16
	mov	[edi + 4], al
	mov	[edi + 7], ah

	pop	edi
	pop	eax
%endmacro
