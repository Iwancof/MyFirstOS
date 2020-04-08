%include "../include/cdecl.s"

BOOT_LOAD	equ	0x7c00
ORG		BOOT_LOAD

entry:
	jmp	ipl
	times 	90 - ($ - $$) db 0x90

ipl:
	cli

	mov	ax,0x0000
	mov	ds,ax
	mov	es,ax
	mov	ss,ax
	mov	sp,BOOT_LOAD

	sti
	mov	[BOOT.DRIVE], dl

	mov	ah,0x02
	mov	al,0x01
	mov	cx,0b0000000000_000010
	mov	dh,0x00
	mov	dl,[BOOT.DRIVE]
	mov	bx,0x7C00 + 512
	int	0x13
.10Q	jnc	.10E
	cdecl	puts,.e0
	call	reboot
.10E:

	jmp	stage_2

	jmp	$

.e0	db	"[Error] Could not read sector",0

ALIGN	2,db 0
BOOT:
.DRIVE:
	dw 0

%include	"../modules/real/puts.s"
%include	"../modules/real/reboot.s"

	times	510 - ($ - $$) db 0x00
	db	0x55,0xAA


stage_2:
	cdecl	puts,	.s0

	jmp	$

.s0	db	"2nd stage...",0x0A,0x0D,0






