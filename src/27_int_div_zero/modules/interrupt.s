int_stop:
	cdecl	draw_str, 25, 15, 0x060F, eax

	mov	eax, [esp + 0]
	cdecl	itoa, eax, .p1, 8, 16, 0b0100
	
	mov	eax, [esp + 4]
	cdecl	itoa, eax, .p2, 8, 16, 0b0100
	
	mov	eax, [esp + 8]
	cdecl	itoa, eax, .p3, 8, 16, 0b0100
	
	mov	eax, [esp +12]
	cdecl	itoa, eax, .p4, 8, 16, 0b0100

	cdecl	draw_str, 25, 16, 0x0F04, .s1
	cdecl	draw_str, 25, 17, 0x0F04, .s2
	cdecl	draw_str, 25, 18, 0x0F04, .s3
	cdecl	draw_str, 25, 19, 0x0F04, .s4

	jmp	$

.s1:	db	"ESP+ 0:"
.p1:	db	"-------- ", 0
.s2:	db	"   + 4:"
.p2:	db	"-------- ", 0
.s3:	db	"   + 8:"
.p3:	db	"-------- ", 0
.s4:	db	"   +12:"
.p4:	db	"-------- ", 0
	

int_default:
	pushf
	push	cs
	push	int_stop

	mov	eax, .s0
	iret

.s0:	db	" <    STOP    > ", 0

init_int:
	push	ebp
	mov	ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edi

	lea	eax, [int_default]
	mov	ebx, 0x0008_8E00
	xchg	ax, bx

	; eax -> int_default[32:16]::8E00
	; ebx -> 0x0008		   ::int_default[15:0]
	; [eax:ebx] is interrupt disc



	mov	ecx, 256
	mov	edi, VECT_BASE
.10L:
	mov	[edi + 0], ebx	; bottom
	mov	[edi + 4], eax	; top
	add	edi, 8
	loop	.10L

	lidt	[IDTR]

	pop	edi
	pop	ecx
	pop	ebx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

int_zero_div:
	pushf
	push	cs
	push	int_stop

	mov	eax, .s0
	iret


.s0:	db	" <  ZERO_DIV  > ", 0
