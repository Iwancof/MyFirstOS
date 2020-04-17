tetris:
.10L:
	cmp	byte [TETR_STAB], 0
	je	.10E


.10E:
	cdecl	move_down, tetr, field
	
	cdecl	draw_field, field, 1
	cdecl	draw_field, tetr, 1
	cdecl	wait_tick, 100
	jmp	.10L


TETR_STAB:	db	0

move_down:	; move_down(move_field_address, touch_field_address)
	push	ebp
	mov	ebp, esp
	pusha

	mov	esi, [ebp + 8]
	mov	edi, [ebp +12]

	mov	ebx, 0	; x
.10L:
	mov	ecx, 21	; y
.20L:
	cdecl	get_field_at, esi, ebx, ecx	; eax = field[x,y]
	cmp	eax, 0
	je	.30E

	cdecl	set_field_at, esi, ebx, ecx, 0
	inc	ecx
	cdecl	set_field_at, esi, ebx, ecx, 1
	dec	ecx
.30E:
	dec	ecx
	cmp	ecx, 0
	jne	.20L

	cdecl	set_field_at, ebx, ecx, 0
.20E:
	inc	ebx
	cmp	ebx, 12
	jne	.10L
.10E:
	

	popa

	mov	esp, ebp
	pop	ebp

	ret

draw_field:	; draw_field(field_address, overwrite_flag) overwrite_flag is 0, not overwrite
	push	ebp
	mov	ebp, esp
	pusha

	mov	esi, [ebp + 8]
	mov	edi, [ebp +12]

	mov	ebx, 0
.10L:
	mov	ecx, 0
.20L:
	cdecl	get_field_at, esi, ebx, ecx
	add	eax, edi
	cmp	eax, 0
	je	.30E
	
	sub	eax, edi
	cdecl	draw_num_pixel, eax, ebx, ecx

.30E:
	inc	ecx
	cmp	ecx, 22
	jne	.20L
.20E:
	inc	ebx
	cmp	ebx, 12
	jne	.10L
.10E:
	popa
	mov	esp, ebp
	pop	ebp

	ret


get_field_at:	; eax = get_field_at(field_address, x, y)
	push	ebp
	mov	ebp, esp
	
	push	esi
	push	ebx

	mov	esi, [ebp + 8]
	mov	eax, [ebp +12]
	mov	ebx, [ebp +16]

	mov	esi, dword [esi + eax * 4]
	movzx	eax, byte [esi + ebx]

	pop	ebx
	pop	esi

	mov	esp, ebp
	pop	ebp

	ret

set_field_at:	; set_field_at(field_address, x, y, d)
	push	ebp
	mov	ebp, esp
	pusha

	mov	esi, [ebp + 8]
	mov	eax, [ebp +12]
	mov	ebx, [ebp +16]
	mov	cl, byte [ebp +20]

	shl	eax, 2
	add	eax, esi
	add	ebx, dword [eax]

	mov	byte [ebx], cl

	popa

	mov	esp, ebp
	pop	ebp

	ret


field:	dd	.x0,.x1,.x2,.x3,.x4,.x5,.x6,.x7,.x8,.x9,.xa,.xb

.x0:	db	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
.x1:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.x2:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.x3:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.x4:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.x5:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.x6:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.x7:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.x8:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.x9:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.xa:	db	1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
.xb:	db	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

tetr:	dd	.x0,.x1,.x2,.x3,.x4,.x5,.x6,.x7,.x8,.x9,.xa,.xb

.x0:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.x1:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.x2:	db	0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.x3:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.x4:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.x5:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.x6:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.x7:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.x8:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.x9:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.xa:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.xb:	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

