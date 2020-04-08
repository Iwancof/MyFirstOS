%include "../include/cdecl.s"
%include "../include/drive.s"
%include "../include/define.s"

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
	mov	[BOOT + drive.no], dl
	
	cdecl	puts,.s0
	mov	bx, BOOT_SECT - 1 		; -1 indicate this sector
	mov	cx, BOOT_LOAD + SECT_SIZE * 1	; load next
	cdecl	read_chs, BOOT, bx, cx

	cmp	ax, bx
.10Q:	jz	.10E
.10T:	cdecl	puts, .e0	; Error
	call	reboot
.10E:	jmp	stage_2

.s0	db	"Booting...",0,0x0D,
.e0	db	"[Error] sector",0

ALIGN	2,db 0
BOOT:
	istruc drive
		at drive.no,	dw	0
		at drive.cyln,	dw	0
		at drive.head,	dw	0
		at drive.sect,	dw	2
	iend

%include	"../modules/real/puts.s"
%include	"../modules/real/reboot.s"
%include	"../modules/real/read_chs.s"

	times	510 - ($ - $$) db 0x00
	db	0x55,0xAA	; end of sector

FONT:
.seg:	dw	0
.off:	dw	0


%include	"../modules/real/itoa.s"
%include	"../modules/real/get_drive_param.s"
%include	"../modules/real/get_font_adr.s"

stage_2:

	cdecl	puts,.s0

	cdecl	get_drive_param, BOOT
	cmp	ax,0
	jne	.10E
	cdecl	puts,.e0
	call	reboot
.10E:

	mov	ax,[BOOT + drive.no]
	cdecl	itoa, ax, .p1, 2, 16, 0b0100
	mov	ax,[BOOT + drive.cyln]
	cdecl	itoa, ax, .p2, 4, 16, 0b0100
	mov	ax,[BOOT + drive.head]
	cdecl	itoa, ax, .p3, 2, 16, 0b0100
	mov	ax,[BOOT + drive.sect]
	cdecl	itoa, ax, .p4, 2, 16, 0b0100

	cdecl	puts,.s1

	jmp	stage_3


.s0	db	"2nd stage...",0x0A,0x0D,0

.s1	db	" Drive::0x"
.p1	db	"--,C:0x"
.p2	db	"----,H:0x"
.p3	db	"--,S:0x"
.p4	db	"--",0x0A,0x0D,0

.e0	db	"Can't get drive parameter.",0

stage_3:

	cdecl	puts,.s0
	cdecl	get_font_adr,FONT
	cdecl	itoa, word [FONT.seg], .p1, 4, 16, 0b0100
	cdecl	itoa, word [FONT.off], .p2, 4, 16, 0b0100

	cdecl	puts,.s1

	jmp	$

.s0	db	"3rd stage...",0x0A,0x0D,0

.s1	db	" Font Address="
.p1	db	"ZZZZ:"			; segment
.p2	db	"ZZZZ", 0x0A, 0x0D, 0	; offset
	db	0x0A,0x0D,0
.t0	db	"--------",0x0A,0x0D,0

	times BOOT_SIZE - ($ - $$)	db	0



