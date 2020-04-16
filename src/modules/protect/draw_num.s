draw_num:	; draw_num(num, x, y)
	push	ebp
	mov	ebp, esp

	cdecl	itoa, dword [ebp + 8], .t1, 16, 16, 0b0100
	cdecl	draw_str, dword [ebp +12], dword [ebp +16], 0x0F01, .t0

	mov	esp, ebp
	pop	ebp
	
	ret

.t0:	db	"0x"
.t1:	db	"----------------", 0

draw_num_pixel:	; draw_num_pixel(num, x, y)
	push	ebp
	mov	ebp, esp

	cdecl	itoa, dword[ebp + 8], .t0, 1, 16, 0b0100
	cdecl	draw_str, dword[ebp +12], dword[ebp +16], 0x0F01, .t0

	mov	esp, ebp
	pop	ebp

	ret

.t0:	db	"-", 0
