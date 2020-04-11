task_1:
	; cdecl	draw_str, 63, 0, 0x07, .s0
	; cdecl	itoa, esp, .t0, 8, 16, 0b0100
	; cdecl	draw_str, 0, 2, 0x010F, .s0
	;mov	[ESP_COUNTER], esp
	; task_1 dose not have level 0
	cdecl	SS_GATE_0:0, 63, 0, 0x07, .s0
.10L:
	;cdecl	itoa, esp, .t0, 8, 16, 0b0100	
	;cdecl	SS_GATE_0:0, 63, 0, 0x07, .t0
	;mov	[ESP_COUNTER], esp
	
	;cdecl	SS_GATE_0:0, 63, 0, 0x07, .s0
	
	;mov	eax, [RTC_TIME]
	;cdecl	draw_time, 72, 0, 0x0700, eax

	; jmp	SS_TASK_0:0	

	jmp	.10L



.s0	db	"Task-1", 0
