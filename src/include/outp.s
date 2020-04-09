%macro	outp	2
	mov	al, %2
	out	%1, al
%endmacro
