%include "../include/cdecl.s"
%include "../include/drive.s"
%include "../include/define.s"
%include "../include/outp.s"

BOOT_LOAD	equ	0x7c00
ORG		BOOT_LOAD

entry:
	jmp	ipl
	times 	3 - ($ - $$) db 0x90
	db	'OEM-NAME'
	
	dw	512
	db	1
	dw	32
	db	2
	dw	512
	dw	0xFFF0
	db	0xF8
	dw	256
	dw	0x10
	dw	2
	dd	0

	dd	0
	db	0x80
	db	0
	db	0x29
	dd	0xBEEF
	db	'BOOTABLE   '
	db	'FAT16   '


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

FONT:				; BOOT_LOAD + SECT_SIZE. use in kernel.s
.seg:	dw	0
.off:	dw	0
ACPI_DATA:
.adr:	dd	0
.len:	dd	0


%include	"../modules/real/itoa.s"
%include	"../modules/real/get_drive_param.s"
%include	"../modules/real/get_font_adr.s"
%include	"../modules/real/get_mem_info.s"
;%include	"../modules/real/get_mem_info_test.s"
%include	"../modules/real/kbc.s"
%include	"../modules/real/lba_chs.s"
%include	"../modules/real/read_lba.s"
%include	"../modules/real/memcpy.s"
%include	"../modules/real/memcmp.s"

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

	cdecl	get_mem_info
	mov	eax, [ACPI_DATA.adr]
	cmp	eax, 0
	je	.10E

	cdecl	itoa, ax, .p4, 4, 16, 0b0100
	shr	eax, 16
	cdecl	itoa, ax, .p3, 4, 16, 0b0100
	cdecl	puts, .s2
.10E:

	jmp	stage_4

.s0:	db	"3rd stage...",0x0A,0x0D,0

.key:	dw	0

.s1	db	" Font Address="
.p1	db	"ZZZZ:"			; segment
.p2	db	"ZZZZ", 0x0A, 0x0D, 0	; offset
	db	0x0A,0x0D,0

.s2	db	" ACPI data="
.p3	db	"ZZZZ"
.p4	db	"ZZZZ",0x0A,0x0D,0

.t0	db	"--------",0x0A,0x0D,0


stage_4:

	cdecl	puts, .s0


	
	cli
	cdecl	KBC_Cmd_Write,	0xAD
	cdecl	KBC_Cmd_Write,	0xD0
	cdecl	KBC_Data_Read,	.key
	
	mov	bl, [.key]
	or	bl, 0x02

	cdecl	KBC_Cmd_Write, 0xD1
	cdecl	KBC_Data_Read, bx

	cdecl	KBC_Cmd_Write, 0xAE

	sti

	cdecl	puts, .s1

	cdecl	puts, .s2

	mov	bx, 0
.10L:
	mov	ah,0x00		; wait key
	int	0x16

	cmp	al,'1'
	jb	.10E		; al < '1'
	cmp	al,'3'
	ja	.10E		; '3' < al

	mov	cl, al
	dec	cl
	and	cl, 0x03
	mov	ax, 0x0001
	shl	ax, cl		; ax = 2 ^ cl
	xor	bx, ax		; bx initialization is out of loop

	cli

	cdecl	KBC_Cmd_Write, 0xAD
	cdecl	KBC_Data_Write, 0xED	; LED command
	cdecl	KBC_Data_Read, .key

	cmp	[.key], byte 0xFA	; 0xFA is ACK
	jne	.11F			; not ACK

	cdecl	KBC_Data_Write, bx
	jmp	.11E
.11F:
	cdecl	itoa, word [.key], .e1, 2, 16, 0b0100
	cdecl	puts, .e0
.11E:
	cdecl	KBC_Cmd_Write, 0xAE

	sti

	jmp	.10L
.10E:
	cdecl	puts, .s3

	jmp	stage_5

.s0:	db	"4th stage...",0x0A,0x0D,0
.s1:	db	"A20 Gate enabled.",0x0A,0x0D,0
.s2:	db	" Keyboard LED test...",0
.s3:	db	" (done)",0x0A,0x0D,0
.e0:	db	"["
.e1:	db	"ZZ]", 0

.key:	dw	00

stage_5:
	cdecl	puts, .s0

	cdecl	read_lba, BOOT, BOOT_SECT, KERNEL_SECT,BOOT_END	; read kernel and put end of BOOT
	cmp	ax, KERNEL_SECT
	jz	.10E		; Seccess
	cdecl	puts, .e0
	call	reboot
.10E:
	
	jmp	stage_6

.s0:	db	"5th stage...",0x0A,0x0D,0
.e0:	db	" Failure load kernel...",0x0A,0x0D,0


stage_6:
	cdecl	puts, .s0

.10L:
	mov	ah, 0
	int	0x16
	cmp	al, ' '
	jnz	.10L

	mov	ax,0x0012
	int	0x10

	jmp	stage_7

.s0:	db	"6th stage...",0x0A,0x0D,0x0A,0x0D
	db	" Push SPACE key to protect mode...",0x0A,0x0D,00


ALIGN	4,	db	0
GDT:	dq	0x00_0000_000000_0000	; NULL
.cs	dq	0x00_CF9A_000000_FFFF	; CODE 4G
.ds	dq	0x00_CF92_000000_FFFF	; DATA 4G
.gdt_end:

SEL_CODE		equ	GDT.cs - GDT
SEL_DATA		equ	GDT.ds - GDT

GDTR:	dw	GDT.gdt_end - GDT - 1	; (Size 1)'s limit is 0
	dd	GDT

IDTR:	dw	0
	dd	0


stage_7:
	cli
	lgdt	[GDTR]
	lidt	[IDTR]

	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	jmp	$ + 2			; pipe line instruction delete
	
[BITS 32]
	db	0x66			; override prefix
	jmp	SEL_CODE:CODE_32	; SEL_CODE is ""INDEX""

CODE_32:
	mov	ax,  SEL_DATA
	mov	ds, ax
	mov	es, ax
	mov	fs, ax
	mov	gs, ax
	mov	ss, ax

	mov	ecx, (KERNEL_SIZE) / 4	; "/ 4" byte
	mov	esi, BOOT_END		; from
	mov	edi, KERNEL_LOAD	; to
	cld
	rep	movsd

	jmp	KERNEL_LOAD



TO_REAL_MODE:
	push	ebp
	mov	ebp, esp

	pusha

	; cli

	mov	eax, cr0
	mov	[.cr0_saved], eax
	mov	[.esp_saved], esp
	sidt	[.idtr_save]
	lidt	[.idtr_real]
	
	jmp	0x0018:.bit16	; 16 bit segment selector(D/B bit)
[BITS 16]
.bit16:
	mov	ax, 0x0020
	mov	ds, ax
	mov	es, ax
	mov	ss, ax

	mov	eax, cr0
	and	eax, 0x7FFF_FFFE	; disable PG,PE
	mov	cr0, eax	; real mode
	jmp	$ + 2

	jmp	0:.real
.real:
	mov	ax, 0x0000
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0x7C00

	outp	0x20, 0x11
	outp	0x21, 0x08
	outp	0x21, 0x04
	outp	0x21, 0x01
	
	outp	0xA0, 0x11
	outp	0xA1, 0x10
	outp	0xA1, 0x02
	outp	0xA1, 0x01

	outp	0x21, 0b1011_1000	; FDD, Slave, KBC, Timer
	outp	0xA1, 0b1011_1111	; HDD

	sti
	cdecl	read_file
	cli

	outp	0x20, 0x11
	outp	0x21, 0x20
	outp	0x21, 0x04
	outp	0x21, 0x01

	outp	0xA0, 0x11
	outp	0xA1, 0x28
	outp	0xA1, 0x02
	outp	0xA1, 0x01

	outp	0x21, 0b1111_1000
	outp	0xA1, 0b1111_1110

	mov	eax, cr0
	or	eax, 1		; 16bit protect mode
	mov	cr0, eax

	jmp	$ + 2

	db	0x66
[BITS 32]
	jmp	0x0008:.bit32
.bit32:
	mov	ax, 0x0010
	mov	ds, ax
	mov	es, ax
	mov	ss, ax

	mov	esp, [.esp_saved]
	mov	eax, [.cr0_saved]
	mov	cr0, eax
	
	jmp	$ + 2

	lidt	[.idtr_save]

	sti
	popa
	mov	esp, ebp
	pop	ebp

	
	ret

.idtr_real:
	dw	0x3FF
	dd	0

.idtr_save:
	dw	0
	dd	0

.cr0_saved:
	dd	0

.esp_saved:
	dd	0


[BITS 16]
read_file:
; not use stack
	push	ax
	push	bx
	push	cx

	cdecl	memcpy, 0x7800, .s0, .s1 - .s0
	; initialize

	mov	bx, 32 + 256 + 256
	mov	cx, (512 * 32) / 512
.10L:

	cdecl	read_lba, BOOT, bx, 1, 0x7600
	cmp	ax, 0
	je	.10E		; fail
	
	cdecl	fat_find_file
	cmp	ax, 0
	je	.12E

	add	ax, 32 + 256 + 256 + 32 - 2
	cdecl	read_lba, BOOT, ax, 1, 0x7800

	jmp	.10E
.12E:
	inc	bx
	loop	.10L
.10E:
	pop	cx
	pop	bx
	pop	ax

	ret

.s0:	db	'File not found', 0
.s1:


fat_find_file:
	push	bx
	push	cx
	push	si

	cld
	mov	bx, 0
	mov	cx, 512 / 32
	mov	si, 0x7600
.10L:
	and	[si + 11], byte 0x18
	; offset 11 is attribute
	jnz	.12E	; continue

	cdecl	memcmp, si, .s0, 8 + 3
	; filename compare(name and extension)
	cmp	ax, 0
	jne	.12E	; continue

	mov	bx, word [si + 0x1A]	; get lba
	jmp	.10E
.12E:
	add	si, 32	; continue
	loop	.10L
.10E:
	mov	ax, bx

	pop	si
	pop	cx
	pop	bx

	ret

.s0:	db	'SPECIAL TXT', 0

	times BOOT_SIZE - ($ - $$) - 16	db	0

	dd	TO_REAL_MODE
	
	times BOOT_SIZE - ($ - $$)	db	0
