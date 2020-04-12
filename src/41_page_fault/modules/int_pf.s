int_pf:
	push	ebp
	mov	ebp, esp
	
	pusha
	push	es
	push	ds

	; mov	ax, DS_KERNEL
	; mov	es, ax
	; mov	ds, ax

	mov	eax, cr2	; interrupt address
	and	eax, ~0x0FFF
	cmp	eax, 0x0010_7000
	jne	.10F
	
	mov	[0x00106000 + 0x107 * 4], dword 0x0010_7007
	; 0x00107007 means 0x00107000 can use as read and write
	cdecl	memcpy, 0x0010_7000, DRAM_PARAM, rose_size

	jmp	.10E
.10F:
	add	esp, 4
	add	esp, 4
	popa
	pop	ebp

	pushf
	push	cs
	push	int_stop

	mov	eax, .s0
	iret			; kernel stop
.10E:
	pop	ds
	pop	es
	popa

	mov	esp, ebp
	pop	ebp
	
	add	esp, 4	; error code clear
	iret
	
.s0	db	" < PAGE FAULT > ", 0

