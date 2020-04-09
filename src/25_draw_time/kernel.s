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

	cdecl	draw_rect, 100, 100, 200, 200, 0x03
	cdecl	draw_rect, 400, 250, 150, 150, 0x05
	cdecl	draw_rect, 350, 400, 300, 100, 0x06

	
.10L:
	cdecl	rtc_get_time, RTC_TIME
	cdecl	draw_time, 72, 0, 0x0700, dword [RTC_TIME]

	jmp	.10L
	
.s0:	db	"welcome to kernel!", 0
.t0:	db	"----",0

ALIGN	4,	db	0
FONT_ADR:	dd	0
RTC_TIME:	dd	0


%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"
%include	"../modules/protect/draw_color_bar.s"
%include	"../modules/protect/draw_pixel.s"
%include	"../modules/protect/draw_line.s"
;%include	"../../../../testOS/src/modules/protect/draw_line.s"
%include	"../modules/protect/draw_rect.s"
%include	"../modules/protect/itoa.s"
%include	"../modules/protect/draw_time.s"
%include	"../modules/protect/rtc.s"
;%include	"../../../../testOS/src/modules/protect/draw_rect.s"
;%include	"../../../../testOS/src/modules/protect/draw_color_bar.s"

	times	KERNEL_SIZE - ($ - $$)	db	0
