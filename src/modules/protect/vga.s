vga_set_read_plane:	; cga_set_read_plane(plane)
; this function only selects read plane
	push	ebp
	mov	ebp, esp
	
	push	eax
	push	edx

	mov	ah, [ebp + 8]	; 32bit
	and	ah, 0x03
	mov	al, 0x04	; read map
	mov	dx, 0x03CE
	out	dx, ax

	pop	edx
	pop	eax

	mov	esp,ebp
	pop	ebp

	ret

vga_set_write_plane:
	push	ebp
	mov	ebp, esp

	push	eax
	push	edx

	mov	ah, [ebp + 8]
	and	ah, 0x0F
	mov	al, 0x02		; write select
	mov	dx, 0x03C4
	out	dx, ax

	pop	edx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

vram_font_copy: ; vram_font_copy(font,vram,plane,color)
; select plane, and same color
; so, this function must be called each plane
; COLOR FORMAT
; ----IRGB,---TIRGB
; BACK_COL,FORD_COL
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	mov	esi, [ebp + 8]		; font address
	mov	edi, [ebp +12]		; vram address
	movzx	eax, byte [ebp +16]	; abs expand
	movzx	ebx, word [ebp +20]	; abs expand. color

	; DX is mask value
	test	bh, al			; BACK
	setz	dh			; DH = ZF ? 0x01 : 0x00
	dec	dh			; DH = ZF ? 0x00 : 0xFF

	test	bl, al			; FORWARD
	setz	dl
	dec	dl

	cld	; Direction PLUS

	mov	ecx, 16			; 16 dot
.10L:
	lodsb				; AX = [ESI],ESI++
	mov	ah, al			; AL is font data
	not	ah			; AH is anti font data

	and	al, dl			; FORWARD font data

	test	ebx, 0b00010000		; I bit
	jz	.11F
	and	ah, [edi]
	jmp	.11E
.11F:
	and	ah, dh			; normal
.11E:
	or	al,ah
	mov	[edi],al

	add	edi,80			; next
	loop	.10L
.10E:

	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

	


