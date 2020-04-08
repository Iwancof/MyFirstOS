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


	cdecl	draw_font, 63, 13
	cdecl	draw_color_bar, 63, 4

        cdecl	draw_str, 25, 14, 0x010F, .s0

	cdecl	draw_pixel,  8,  4 ,0x01
	cdecl	draw_pixel,  9,  5 ,0x01
	cdecl	draw_pixel, 10,  6 ,0x02
	cdecl	draw_pixel, 11,  7 ,0x02
	cdecl	draw_pixel, 12,  8 ,0x03
	cdecl	draw_pixel, 13,  9 ,0x03
	cdecl	draw_pixel, 14, 10 ,0x04
	cdecl	draw_pixel, 15, 11 ,0x04

	cdecl	draw_pixel, 15,  4 ,0x03
	cdecl	draw_pixel, 14,  5 ,0x03
	cdecl	draw_pixel, 13,  6 ,0x04
	cdecl	draw_pixel, 12,  7 ,0x04
	cdecl	draw_pixel, 11,  8 ,0x01
	cdecl	draw_pixel, 10,  9 ,0x01
	cdecl	draw_pixel,  9, 10 ,0x02
	cdecl	draw_pixel,  8, 11 ,0x02


	jmp	$
	
.s0:	db	"welcome to kernel!", 0

ALIGN	4,	db	0
FONT_ADR:	dd	0


%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"
%include	"../modules/protect/draw_color_bar.s"
%include	"../modules/protect/draw_pixel.s"
;%include	"../../../../testOS/src/modules/protect/draw_color_bar.s"

	times	KERNEL_SIZE - ($ - $$)	db	0
