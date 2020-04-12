; system calls
trap_gate_81:	; system call 81, draw_char
%ifdef	USE_TEST_AND_SET
	cdecl	test_and_set, IN_USE_81
%endif
	cdecl	draw_char, ebx, ecx, edx, eax
%ifdef	USE_TEST_AND_SET
	mov	[IN_USE_81], dword 0
%endif
	iret

trap_gate_82:
%ifdef	USE_TEST_AND_SET
	cdecl	test_and_set, IN_USE_82
%endif
	cdecl	draw_pixel, ecx, edx, ebx
%ifdef	USE_TEST_AND_SET
	mov	[IN_USE_82], dword 0
%endif
	iret

ALIGN	4,		db	0
IN_USE_81:		dd	0
IN_USE_82:		dd	0
