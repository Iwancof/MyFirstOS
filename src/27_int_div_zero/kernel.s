%include	"../include/define.s"
%include	"../include/cdecl.s"
%include	"../include/drive.s"
%include	"../include/set_vect.s"
;%include	"../../../../testOS/src/include/macro.s"

ORG	KERNEL_LOAD

ALIGN	4
IDTR:	dw	8 * 256 - 1	; size
	dd	VECT_BASE


[BITS 32]


kernel:
	
	mov	esi, BOOT_LOAD + SECT_SIZE
	movzx	eax, word [esi + 0]
	movzx	ebx, word [esi + 2]
	shl	eax, 4
	add	eax, ebx		; Emulate real mode addressing
	mov	[FONT_ADR], eax
	
	cdecl	init_int
	set_vect	0x00, int_zero_div


	cdecl	draw_font, 63, 13
	cdecl	draw_color_bar, 63, 4

        cdecl	draw_str, 25, 14, 0x010F, .s0
	
	int	0

	mov	al, 0
	div	al

	jmp	$
	
	
.s0:	db	" Hello, kernel! ", 0
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
%include	"modules/interrupt.s"
;%include	"../../../../testOS/src/27_int_div_zero/modules/interrupt.s"
;%include	"../../../../testOS/src/modules/protect/draw_rect.s"
;%include	"../../../../testOS/src/modules/protect/draw_color_bar.s"

	times	KERNEL_SIZE - ($ - $$)	db	0
