; system calls
trap_gate_81:	; system call 81, draw_char
%ifdef	USE_TEST_AND_SET
	cdecl	test_and_set, IN_USE
%endif
	cdecl	draw_char, ebx, ecx, edx, eax
%ifdef	USE_TEST_AND_SET
	mov	[IN_USE], dword 0
%endif
	iret

trap_gate_82:
	cdecl	draw_pixel, ecx, edx, ebx
	iret

ALIGN	4,	db	0
IN_USE:		dd	0
