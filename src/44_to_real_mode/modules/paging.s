page_set_4m:
	push	ebp
	mov	ebp, esp
	
	pusha

	cld
	mov	edi, [ebp + 8]
	mov	eax, 0x00000000		; null page directory
	mov	ecx, 1024		; 1024 directories
	rep	stosd

	mov	eax, edi		; we use memory after page directory
	and	eax, ~0x0000_0FFF
	or	eax, 0b0000_0111	; enable read write

	mov	[edi - (1024 * 4)], eax
	
	mov	eax, 0x0000_0007
	mov	ecx, 1024		; 1024 pages
.10L:
	stosd
	add	eax, 0x0000_1000
	loop	.10L

	popa

	mov	esp, ebp
	pop	ebp

	ret

.t0:	db	"----------------", 0

init_page:
	pusha
	cdecl	page_set_4m, CR3_BASE
	cdecl	page_set_4m, CR3_TASK_4
	cdecl	page_set_4m, CR3_TASK_5
	cdecl	page_set_4m, CR3_TASK_6
	mov [CR3_BASE + 0x1000 + 0x107 * 4], dword 0
	mov [CR3_TASK_4 + 0x1000 + 0x107 * 4], dword PARAM_TASK_4 + 7
	mov [CR3_TASK_5 + 0x1000 + 0x107 * 4], dword PARAM_TASK_5 + 7
	mov [CR3_TASK_6 + 0x1000 + 0x107 * 4], dword PARAM_TASK_6 + 7

	cdecl	memcpy, PARAM_TASK_4, DRAW_PARAM.t4, rose_size
	cdecl	memcpy, PARAM_TASK_5, DRAW_PARAM.t5, rose_size
	cdecl	memcpy, PARAM_TASK_6, DRAW_PARAM.t6, rose_size

	; [0x00000000] = 0x0
	popa

	ret

