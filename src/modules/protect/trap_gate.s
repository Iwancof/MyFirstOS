; system calls
trap_gate_81:	; system call 81, draw_char
	cdecl	draw_char, ebx, ecx, edx, eax
	iret

trap_gate_82:
	cdecl	draw_pixel, ecx, edx, ebx
	iret
