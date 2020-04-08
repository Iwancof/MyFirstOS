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

	jmp	$

ALIGN	2,db 0
BOOT:
.DRIVE:
	dw 0

	times	510 - ($ - $$) db 0x00
	db	0x55,0xAA
