draw_time:	; draw_time(col, row, color, time)
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx

	mov	eax, [ebp +20]	; time
	movzx	ebx, al		; seconds
	cdecl	itoa, ebx, .sec, 2, 16, 0b0100

	mov	bl, ah
	cdecl	itoa, ebx, .min, 2, 16, 0b0100
	; buffer size is 2. so ignore bh

	shr	eax, 16
	cdecl	itoa, eax, .hour, 2, 16, 0b0100

	cdecl	draw_str, dword[ebp + 8], dword[ebp +12], dword[ebp +16], .hour

	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret


.hour:	db	"ZZ:"
.min:	db	"ZZ:"
.sec:	db	"ZZ", 0
