get_tss_base:
	; eax : return value
	; ebx : segment selector

	mov	eax, [GDT + ebx + 2]
	shl	eax, 8
	mov	al, [GDT + ebx + 7]
	ror	eax, 8

	ret

save_fpu_context:
	; eax : tss address
	fnsave	[eax + 104]
	mov	[eax + 104 + 108], dword 1	; store flag or present flag(?)
	
	ret

load_fpu_context:
	cmp	[eax + 104 + 108], dword 0
	jne	.10F
	finit					; not initialized yet
	jmp	.10E
.10F:
	frstor	[eax + 104]
.10E:
	ret

int_nm:
	pusha
	push	es
	push	ds

	mov	ax, DS_KERNEL
	mov	es, ax
	mov	ds, ax

	clts

	mov	edi, [.last_tss]
	str	esi
	and	esi, ~0x0007	; exclude TI,RPL bits

	cmp	edi, 0
	je	.10F

	cmp	esi, edi
	je	.12E

	cli

	mov	ebx, edi
	call	get_tss_base	; eax is address to tss
	call	save_fpu_context; eax used here

	mov	ebx, esi
	call	get_tss_base
	call	load_fpu_context

	sti
.12E:
	jmp	.10E
.10F:
	cli

	mov	ebx, esi
	call	get_tss_base
	call	load_fpu_context

	sti
.10E:

	mov	[.last_tss], esi

	pop	ds
	pop	es
	popa

	iret

ALIGN	4,	db	0
.last_tss:	dd	0
