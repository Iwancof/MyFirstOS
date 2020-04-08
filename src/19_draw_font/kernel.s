%include	"../include/define.s"
%include	"../include/cdecl.s"
%include	"../include/drive.s"

ORG	KERNEL_LOAD

[BITS 32]

kernel:
	
	mov	esi, BOOT_LOAD + SECT_SIZE
	movzx	eax, word [esi + 0]
	movzx	ebx, word [esi + 2]
	shl	eax, 4
	add	eax, ebx		; Emulate real mode addressing
	mov	[FONT_ADR], eax

	;mov	al, 0x02
	;mov	dx, 0x3C4

	;mov	ah, 0x04
	;out	dx, ax

	;mov	[0x000A_0000 + 0], byte 0xFF
	
	;mov	ah, 0x02
	;out	dx, ax

	;mov	[0x000A_0000 + 2], byte 0xFF

	;mov	ah, 0x01
	;out	dx, ax

	;mov	[0x000A_0000 + 1], byte 0xFF

	;mov	ah, 0x02 | 0b1000	; Green
	;out	dx, ax

	;lea	edi, [0x000A_0000 + 80]	; edi = 0x000A_0050
	;mov	ecx, 80
	;mov	al, 0xFF
	;rep	stosb

	;mov	edi, 1
	;shl	edi, 8
	;lea	edi, [edi * 4 + edi + 0x000A_0000]

	;mov	[edi + (80 * 0)], word 0xFF
	;mov	[edi + (80 * 1)], word 0xFF
	;mov	[edi + (80 * 2)], word 0xFF
	;mov	[edi + (80 * 3)], word 0xFF
	;mov	[edi + (80 * 4)], word 0xFF
	;mov	[edi + (80 * 5)], word 0xFF
	;mov	[edi + (80 * 6)], word 0xFF
	;mov	[edi + (80 * 7)], word 0xFF

	;mov	esi, 'A'
	;shl	esi, 4
	;add	esi, [FONT_ADR]

	;mov	edi, 2
	;shl	edi, 8
	;lea	edi, [edi * 4 + edi + 0x000A_0000]

	;mov	ecx, 16
;.10L:
	;movsb
	;add	edi, 80 - 1
	;loop	.10L

	;cdecl	draw_char, 0, 0, 0x010F, 'A'
	;cdecl	draw_char, 1, 0, 0x010F, 'B'
	;cdecl	draw_char, 2, 0, 0x010F, 'C'

	;cdecl	draw_char, 0, 0, 0x0402, '0'
	;cdecl	draw_char, 1, 0, 0x0212, '1'
	;cdecl	draw_char, 2, 0, 0x0212, '-'

	cdecl	draw_font, 63, 13

	jmp	$

ALIGN	4,	db	0
FONT_ADR:	dd	0

%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"

	times	KERNEL_SIZE - ($$ - $)	db	0
