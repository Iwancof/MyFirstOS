ctrl_alt_end:
	push	ebp
	mov	ebp, esp

	mov	eax, [ebp + 8]
	btr	eax, 7		; press : 0*******, pull : 1*******
	jc	.10F
	bts	[.key_state], eax	; set
	jmp	.10E
.10F:
	btc	[.key_state], eax	; clear
.10E:
	; key press check
	mov	eax, 0x1D		; ctrl
	bt	[.key_state], eax
	jnc	.20E			; not press

	mov	eax, 0x38
	bt	[.key_state], eax
	jnc	.20E

	mov	eax, 0x4F
	bt	[.key_state], eax
	jnc	.20E

	mov	eax, -1			; success
.20E:
	sar	eax, 8

	mov	esp, ebp
	pop	ebp

	ret


.key_state:	times	32	db	0
