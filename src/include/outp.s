%macro	outp	2
	mov	al, %2
	out	%1, al
%endmacro
%macro	moutb	2
	push	eax
	push	edx
	mov	dx, %1	; port
	mov	al, %2	; data
	out	dx, al
	pop	edx
	pop	eax
%endmacro
