draw_pixel:	; draw_pixel(X,Y,color)
; X,Y is PIXEL data
	push	ebp
	mov	ebp, esp

	push	edi
	push	ebx
	push	ecx

	mov	edi, [ebp +12]
	shl	edi, 4
	lea	edi, [edi * 4 + edi + 0x000A_0000]

	mov	ebx, [ebp + 8]	
	mov	ecx, ebx
	shr	ebx, 3
	add	edi, ebx

	and	ecx, 0x07
	mov	ebx, 0b1000_0000
	; for examle. ecx = 1
	; ebx = 0b0100_0000
	shr	ebx, cl
	
	mov	ecx, [ebp +16]	; color

	cdecl	vga_set_read_plane, 0x03
	cdecl	vga_set_write_plane, 0x08
	cdecl	vram_bit_copy, ebx, edi, 0x08, ecx
	; vram_bit_copy
	; bit_pattarn, address, plane, color

	cdecl	vga_set_read_plane, 0x02
	cdecl	vga_set_write_plane, 0x04
	cdecl	vram_bit_copy, ebx, edi, 0x04, ecx
	
	cdecl	vga_set_read_plane, 0x01
	cdecl	vga_set_write_plane, 0x02
	cdecl	vram_bit_copy, ebx, edi, 0x02, ecx
	
	cdecl	vga_set_read_plane, 0x00
	cdecl	vga_set_write_plane, 0x01
	cdecl	vram_bit_copy, ebx, edi, 0x01, ecx

	pop	ecx
	pop	ebx
	pop	edi

	mov	esp, ebp
	pop	ebp

	ret

