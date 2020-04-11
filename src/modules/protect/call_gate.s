call_gate:
	;retf	4 * 4
; if SS_GATE_0 called
	push	ebp
	mov	ebp, esp

	pusha
	push	ds
	push	es

	mov	ax, 0x0010
	mov	ds, ax
	mov	es, ax

	;str	ax
	;cmp	ax, SS_TASK_1
	;je	.11L

	;cdecl	draw_str, 0, 0, 0x010F, .t0
	;jmp	.10E
.11L:
	;cdecl	draw_str, 0, 0, 0x010F, .t1
.10E:
		
	;cdecl	itoa, esp, .t2, 8, 16, 0b0100
	;cdecl	draw_str, 0, 1, 0x010F, .t2

	;cdecl	itoa, dword [ESP_COUNTER], .t3, 8, 16, 0b0100
	;cdecl	draw_str, 0, 2, 0x010F, .t3
	


	; ebp + 0 -- EBP
	; ebp + 4 -- EIP
	; ebp + 8 -- CS
	mov	eax, dword[ebp +12]
	mov	ebx, dword[ebp +16]
	mov	ecx, dword[ebp +20]
	mov	edx, dword[ebp +24]
	cdecl	draw_str, eax, ebx, ecx, edx
	; wrapper

	pop	es
	pop	ds
	popa

	mov	esp, ebp
	pop	ebp

	retf	4 * 4	; 4 DWORDs


.t0:	db	"task_0",0
.t1:	db	"task_1",0
.t2:	db	"--------", 0
.t3:	db	"--------", 0
