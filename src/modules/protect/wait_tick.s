wait_tick:
	push	ebp
	mov	ebp, esp

	push	eax
	push	ecx

	mov	ecx, [ebp + 8]
	mov	eax, [TIMER_COUNT]
.10L:
	cmp	[TIMER_COUNT], eax
	je	.10L
	inc	eax		; per 10ms
	loop	.10L		; 10ms * ecx]

	pop	ecx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

