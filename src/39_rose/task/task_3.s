task_3:
	; push	ebp
	mov	ebp, esp

	push	dword 0	; origin x
	push	dword 0	; origin y
	push	dword 0	; 
	push	dword 0
	push	dword 0


	mov	esi, DRAM_PARAM

	mov	eax, [esi + rose.x0]
	mov	ebx, [esi + rose.y0]

	shr	eax, 3		; eax is x
	shr	ebx, 4		; ebx is y
	dec	ebx
	mov	ecx, [esi + rose.color_s]
	lea	edx, [esi + rose.title]

	cdecl	draw_str, eax, ebx, ecx, edx	; draw title

	mov	eax, [esi + rose.x0]
	mov	ebx, [esi + rose.x1]
	sub	ebx, eax
	shr	ebx, 1			; half of size
	add	ebx, eax		; origin x
	mov	[ebp - 4], ebx

	mov	eax, [esi + rose.y0]
	mov	ebx, [esi + rose.y1]
	sub	ebx, eax
	shr	ebx, 1
	add	ebx, eax
	mov	[ebp - 8], ebx

	mov	eax, [esi + rose.x0]	; x start
	mov	ebx, [ebp - 8]		; y
	mov	ecx, [esi + rose.x1]	; x end

	cdecl	draw_line, eax, ebx, ecx, ebx, dword [esi + rose.color_x]	; x axis

	mov	eax, [esi + rose.y0]	; y start
	mov	ebx, [ebp - 4]		; x
	mov	ecx, [esi + rose.y1]	; y end

	cdecl	draw_line, ebx, eax, ebx, ecx, dword [esi + rose.color_y]

	mov	eax, [esi + rose.x0]
	mov	ebx, [esi + rose.y0]
	mov	ecx, [esi + rose.x1]
	mov	edx, [esi + rose.y1]

	cdecl	draw_rect, eax, ebx, ecx, edx, dword [esi + rose.color_z]

	mov	eax, [esi + rose.x1]
	sub	eax, [esi + rose.x0]
	shr	eax, 1
	mov	ebx, eax
	shr	ebx, 4
	sub	eax, ebx
	; eax -= eax / 16

	cdecl	fpu_rose_init, eax, dword [esi + rose.n], dword [esi + rose.d]
.10L:

	lea	ebx, [ebp - 12]	; x position address
	lea	ecx, [ebp - 16]	; y position address
	mov	eax, [ebp - 20]	; t

	cdecl	fpu_rose_update, ebx, ecx, eax

	mov	edx, 0
	inc	eax
	mov	ebx, 360 * 100
	div	ebx
	; EDX:EAX div ebx. EAX : /, EDX : %.
	mov	[ebp -20], edx

	mov	ecx, [ebp -12]	; x = 0
	mov	edx, [ebp -16]	; y = 0

	add	ecx, [ebp - 4]	; x += X
	add	edx, [ebp - 8]	; t += Y

	mov	ebx, [esi + rose.color_f]
	int	0x82		; draw_pixel at (ecx, edx). color is ebx

	cdecl	wait_tick, 2

	mov	ebx, [esi + rose.color_b]
	int	0x82
	
	jmp	.10L

ALIGN	4,	db	0

DRAM_PARAM:
	istruc	rose
		at	rose.x0,	dd	16
		at	rose.y0,	dd	32
		at	rose.x1,	dd	416
		at	rose.y1,	dd	432

		at	rose.n,		dd	2
		at	rose.d,		dd	1

		at	rose.color_x,	dd	0x0007
		at	rose.color_y,	dd	0x0007
		at	rose.color_z,	dd	0x000F
		at	rose.color_s,	dd	0x030F
		at	rose.color_f,	dd	0x000F
		at	rose.color_b,	dd	0x0003

		at	rose.title,	db	"Task-3", 0
	iend


fpu_rose_init:	;	fpu_rose_init(A,n,d)
	push	ebp
	mov	ebp, esp

	push	dword 180

	fldpi
	fidiv	dword [ebp - 4]	; 180
	fild	dword [ebp +12]	; n
	fidiv	dword [ebp +16]	; n / d
	fild	dword [ebp + 8]	; A

	mov	esp, ebp
	pop	ebp

	ret

fpu_rose_update:	;	fpu_rose_update(px, py, t)
; px,py is address. t is angle
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx

	mov	eax, [ebp + 8]
	mov	ebx, [ebp +12]

	fild	dword [ebp +16]
	fmul	st0, st3		; st0 is degree, st3 is radian / degree. st0 is radian
	fld	st0

	fsincos
	fxch	st2			; change st0, st2
	fmul	st0, st4		; st0 = kƒÆ
	fsin				; st0 = sin(kƒÆ)
	fmul	st0, st3		; st0 = Asin(kƒÆ)

	fxch	st2
	fmul	st0, st2
	fistp	dword [eax]		; store x pos

	fmulp	st1, st0
	fchs				; convert to display coordinate
	fistp	dword [ebx]		; store y pos

	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret


	


