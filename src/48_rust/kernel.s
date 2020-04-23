%define		USE_SYSTEM_CALL
%define		USE_TEST_AND_SET

%include	"../include/define.s"
%include	"../include/cdecl.s"
%include	"../include/drive.s"
%include	"../include/set_vect.s"
%include	"../include/outp.s"
%include	"../include/set_desc.s"
%include	"../include/set_gate.s"
;%include	"../../../../testOS/src/include/macro.s"

ORG	KERNEL_LOAD

ALIGN	4
IDTR:	dw	8 * 256 - 1	; size
	dd	VECT_BASE


[BITS 32]


kernel:
	cli

	mov	esi, BOOT_LOAD + SECT_SIZE
	movzx	eax, word [esi + 0]
	movzx	ebx, word [esi + 2]
	shl	eax, 4
	add	eax, ebx		; Emulate real mode addressing
	mov	[FONT_ADR], eax
	
	set_desc	GDT.ldt, LDT, word LDT_LIMIT
	set_desc	GDT.tss_0, TSS_0
	set_desc	GDT.tss_1, TSS_1
	set_desc	GDT.tss_2, TSS_2
	set_desc	GDT.tss_3, TSS_3
	set_desc	GDT.tss_4, TSS_4
	set_desc	GDT.tss_5, TSS_5
	set_desc	GDT.tss_6, TSS_6
	lgdt		[GDTR]

	mov	esp, SP_TASK_0
	mov	ax, SS_TASK_0	; set tss0
	ltr	ax
	; say "this process is task 0" to CPU


	cdecl	init_int
	cdecl	init_pic

	set_vect	0x00, int_zero_div
	; set_vect	0x06, ope_exce
	set_vect	0x0E, int_pf
	set_vect	0x07, int_nm
	set_vect	0x20, int_timer
	set_vect	0x21, int_keyboard
	set_vect	0x28, int_rtc
	set_vect	0x81, trap_gate_81, word 0xEF00	; type = trap
	set_vect	0x82, trap_gate_82, word 0xEF00
	set_vect	0xFF, panic

	cdecl	init_page

	;mov	eax, CR3_BASE
	;mov	cr3, eax
	
	;mov	eax, cr0
	;or	eax, (1 << 31)
	;mov	cr0, eax
	;jmp	$ + 2

	;mov	eax, 0xffff00
	;mov	[eax], dword 1
	;cdecl	itoa, dword [eax], .t1, 16, 16, 0b0100
	;cdecl	draw_str, 0, 10, 0x010F, .t1

	set_gate	GDT.call_gate, call_gate
	
	cdecl	rtc_int_en, 0x10	; interrupt per udpate
	cdecl	int_en_timer
	
	outp	0x21, 0b1111_1000	; slave
	outp	0xA1, 0b1111_1110	; rtc
	
	sti
	
	cdecl	draw_font, 63, 13
	cdecl	draw_color_bar, 63, 4

        cdecl	draw_str, 25, 14, 0x010F, .s0
	
	;jmp	SS_TASK_1:10000
	pusha

	mov	eax, 0		; eax is sector
	mov	ecx, 0
.80L:	
	mov	ebx, [BOOT_LOAD + BOOT_SIZE - 16 + 8]
	mov	[ebx], eax

	call	[BOOT_LOAD + BOOT_SIZE - 16 + 4]
	lea	edi, [ecx * 4 + ecx]
	shl	edi, 12
	add	edi, RUST_MAIN
	
	; cdecl	draw_num, edi, 0, ecx

	cdecl	memcpy, edi , 0x1000, 40 * 512

	inc	ecx
	;cdecl	draw_num, ecx, 0, 0

	add	eax, 40
	cmp	eax, RUST_SECT

	jna	.80L
	
	popa

	mov	eax, dword [RUST_MAIN + 0x18]
	;mov	eax, dword [RUST_MAIN + 0x18]
	;add	eax, dword [RUST_MAIN + 0x38]

	; cdecl	draw_num, eax, 0, 0
	; jmp	$

	; cdecl	eax	; initialize function. eax = main_entry_point
	;call	0x2010c5
	call	eax
	mov	[RUST_ENTRY], eax
		

.90L:
	cdecl	[RUST_ENTRY]
	;push	eax
	;pop	eax
	;cdecl	draw_num, eax, 0, 1

	; jmp	.90L

	; cdecl	draw_num, _KEY_BUFF, 0, 0

	jmp	.90L

	; jmp	$


.10L:

	cdecl	draw_rotation_bar

	cdecl	ring_rd, _KEY_BUFF, .int_key
	cmp	eax, 0
	je	.10L

	cdecl	draw_key, 2, 29, _KEY_BUFF

	mov	al, [.int_key]
	cmp	al, 0x02
	jne	.14L

	call	[BOOT_LOAD + BOOT_SIZE - 16]
	mov	esi, 0x7800
	mov	[esi + 32], byte 0
	cdecl	draw_str, 0, 0, 0x0F04, esi

.14L:
	mov	al, [.int_key]
	cdecl	ctrl_alt_end, eax
	cmp	eax, 0
	je	.10L

	mov	eax, 0
	bts	[.once], eax
	jc	.10L
	cdecl	power_off

	jmp	.10L
	
	
.s0:	db	" Hello, kernel! ", 0
.t0:	db	"----",0
.t1:	db	"----------------",0
.int_key:	dd	0
.once:		dd	0

ALIGN	4,	db	0
FONT_ADR:	dd	0
RTC_TIME:	dd	0

RUST_ENTRY:	dd	0

ope_exce:
	cdecl	draw_num, 0x1234, 0, 2
	jmp	$


%include	"../modules/protect/vga.s"
%include	"../modules/protect/memcpy.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"
%include	"../modules/protect/draw_color_bar.s"
%include	"../modules/protect/draw_pixel.s"
%include	"../modules/protect/draw_line.s"
%include	"../modules/protect/draw_rect.s"
%include	"../modules/protect/itoa.s"
%include	"../modules/protect/draw_time.s"
%include	"../modules/protect/rtc.s"
%include	"../modules/protect/int_rtc.s"
%include	"../modules/protect/pic.s"
%include	"../modules/protect/interrupt.s"
%include	"../modules/protect/int_keyboard.s"
;%include	"../../../../testOS/src/modules/protect/int_keyboard.s"
%include	"../modules/protect/ring_buff.s"
%include	"../modules/protect/call_gate.s"
%include	"../modules/protect/trap_gate.s"
%include	"../modules/protect/test_and_set.s"
%include	"../modules/protect/int_nm.s"
%include	"../modules/protect/wait_tick.s"
%include	"../modules/protect/ctrl_alt_end.s"
%include	"../modules/protect/power_off.s"
%include	"../modules/protect/acpi_find.s"
%include	"../modules/protect/find_rsdt_entry.s"
%include	"../modules/protect/acpi_package_value.s"
%include	"../modules/protect/draw_num.s"
%include	"../modules/protect/panic_handler.s"
;%include	"../modules/protect/int_pf.s"
%include	"modules/paging.s"
%include	"modules/int_pf.s"
;%include	"../modules/protect/int_timer.s"
%include	"modules/my_int_timer.s"
%include	"../modules/protect/draw_rotation_bar.s"
%include	"descriptor.s"
%include	"task/task_1.s"
%include	"task/task_2.s"
%include	"task/task_3.s"
;%include	"../../../../testOS/src/39_rose/tasks/task_3.s"

;%include	"../../../../testOS/src/modules/protect/ring_buff.s"
;%include	"../../../../testOS/src/modules/protect/some.s"
test_func:
	cdecl	draw_str, 0, 20, 0x010F, .t0
	ret
.t0:	db	"Test message", 0

RUSTTIMERADDRESS:		dd	0

panic_message:	times	0xff	db	0

	times	KERNEL_SIZE - ($ - $$) - 0x100	db	1

funcs:	dd	draw_num
	dd	test_func
	dd	draw_str
	dd	wait_tick
	dd	draw_pixel
	dd	RING_ITEM_SIZE
	dd	_KEY_BUFF
	dd	panic_handler
	dd	ring_rd
	dd	draw_char
	dd	power_off
	dd	panic_message
	dd	HEAP_START
	dd	RUSTTIMERADDRESS

	times	KERNEL_SIZE - ($ - $$)	db	1

; KERNEL_END:

