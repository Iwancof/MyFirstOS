draw_line:	; draw_line(X0,Y0,X1,Y0,color)
	push	ebp
	mov	ebp, esp

	push	dword 0	; SUM: - 4
	push	dword 0	; x0 : - 8
	push	dword 0	; wid: -12
	push	dword 0	; inx: -16
	push	dword 0	; y0 : -20
	push	dword 0	; hei: -24
	push	dword 0	; iny: -28

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	mov	eax, [ebp + 8]
	mov	ebx, [ebp +16]
	sub	ebx, eax	; X1 - X0
	jge	.10F
	
	neg	ebx
	mov	esi, -1
	jmp	.10E
.10F:
	mov	esi, 1
.10E:
	
	mov	ecx, [ebp +12]
	mov	edx, [ebp +20]
	sub	edx, ecx
	jge	.20F

	neg	edx
	mov	edi, -1
	jmp	.20E
.20F:
	mov	edi, 1
.20E:
	
	mov	[ebp - 8], eax	; start.x
	mov	[ebp -12], ebx	; width
	mov	[ebp -16], esi	; inc_x

	mov	[ebp -20], ecx	; start.y
	mov	[ebp -24], edx	; hegiht
	mov	[ebp -28], edi	; inc_y

	cmp	ebx, edx
	jg	.22F		; determin abs axis

	lea	esi, [ebp -20]
	lea	edi, [ebp - 8]
	
	jmp	.22E
.22F:
	lea	esi, [ebp - 8]
	lea	edi, [ebp -20]
.22E:
	; ESI, EDI is "ADDRESS"

	mov	ecx, [esi - 4]	; Abs axis
	cmp	ecx, 0
	jnz	.30E
	mov	ecx, 1		; not have length
.30E:
	
.50L:
	;cdecl	draw_pixel,	dword [ebp - 8], \	; x0
	;			dword [ebp -20], \	; y0
	;			dword [ebp +24]		; color
        cdecl draw_pixel, dword [ebp - 8], dword [ebp - 20], dword [ebp + 24]
	
	; update coordinate
	mov	eax, [esi - 8] 	; abs axis -1 or 0 or -1
	add	[esi - 0], eax	; abs coordinate

	mov	eax, [ebp - 4]
	add	eax, [edi - 4]
	mov	ebx, [esi - 4]

	cmp	eax, ebx
	jl	.52E
	sub	eax, ebx	; sum -= wid
	; sum can only add -1 or 1
	; so. not be  "dif * 2 < sum" 

	mov	ebx, [edi - 8]	; ebx = inc
	add	[edi - 0], ebx
.52E:
	mov	[ebp - 4], eax	; sum = eax

	loop	.50L
.50E:


	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret


