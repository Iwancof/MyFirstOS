ring_rd:	; ring_rd(ring_address, dest_address)
		; return eax
	push	ebp
	mov	ebp, esp

	push	esi
	push	edi
	push	ebx

	mov	esi, [ebp + 8]
	mov	edi, [ebp +12]

	mov	eax, 0
	mov	ebx, [esi + ring_buff.rp]
	cmp	ebx, [esi + ring_buff.wp]
	je	.10E					; no data. eax = 0

	mov	al, [esi + ring_buff.item + ebx]	; read point
	
	mov	[edi], al
	
	inc	ebx
	and	ebx, RING_INDEX_MASK			; % 8
	mov	[esi + ring_buff.rp], ebx

	mov	eax, 1					; read something

.10E:
	pop	ebx
	pop	edi
	pop	esi

	mov	esp, ebp
	pop	ebp

	ret

ring_wr:	; ring_wr(ring_address, src) src is not address. 
	push	ebp
	mov	ebp, esp

	push	esi
	push	ebx
	push	ecx

	mov	esi, [ebp + 8]

	mov	ebx, [esi + ring_buff.wp]
	mov	ecx, ebx
	inc	ecx
	and	ecx, RING_INDEX_MASK
	; ebx is write point
	; ecx is next point

	cmp	ecx, [esi + ring_buff.rp]
	je	.10E

	; can write
	mov	al, [ebp +12]
	mov	[esi + ring_buff.item + ebx], al	; ebx is index
	mov	[esi + ring_buff.wp], ecx		; next point

	mov	eax, 1					; OK
.10E:
	pop	ecx
	pop	ebx
	pop	esi

	mov	esp, ebp
	pop	ebp

	ret
	


