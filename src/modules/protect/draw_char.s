draw_char:
; draw_char(row,col,color,ch)
	push	ebp
	mov	ebp, esp

	push	esi
	push	edi
	push	eax
	push	ebx
	push	ecx
	push	edx

	movzx	esi, byte [ebp + 20]	; esi = ch
	shl	esi, 4
	add	esi, [FONT_ADR]

	mov	edi, [ebp +12]
	shl	edi, 8
	lea	edi, [edi * 4 + edi + 0x000A_0000]
	add	edi, [ebp + 8]

	movzx	ebx, word [ebp +16]

	cdecl	vga_set_read_plane, 0x03
	cdecl	vga_set_write_plane, 0x08
	cdecl	vram_font_copy, esi, edi, 0x08, ebx

	cdecl	vga_set_read_plane, 0x02
	cdecl	vga_set_write_plane, 0x04
	cdecl	vram_font_copy, esi, edi, 0x04, ebx

	cdecl	vga_set_read_plane, 0x01
	cdecl	vga_set_write_plane, 0x02
	cdecl	vram_font_copy, esi, edi, 0x02, ebx
	
	cdecl	vga_set_read_plane, 0x00
	cdecl	vga_set_write_plane, 0x01
	cdecl	vram_font_copy, esi, edi, 0x01, ebx

	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	pop	edi
	pop	esi

	mov	esp, ebp
	pop	ebp

	ret

	
