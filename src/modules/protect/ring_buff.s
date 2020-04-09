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
	

draw_key:	
	push	ebp
	mov	ebp, esp

	pusha
	; easy

	mov	edx, [ebp + 8]	; x offset
	mov	edi, [ebp +12]	; y offset
	mov	esi, [ebp +16]	; ring buff address

	mov	ebx, [esi + ring_buff.wp]	; seeing point
	lea	esi, [esi + ring_buff.item]	; item start address
	mov	ecx, RING_ITEM_SIZE
.10L:
	dec	ebx
	; 3 -> 2, 0 -> FF
	and	ebx, RING_INDEX_MASK
	mov	al, [esi + ebx]

	cdecl	itoa, eax, .tmp, 2, 0x10, 0b0100
	cdecl	draw_str, edx, edi, 0x02, .tmp

	add	edx, 3
	; string is 2, so space is 1

	loop	.10L

	popa

	mov	esp, ebp
	pop	ebp

	ret

.tmp:	db	"--",0
