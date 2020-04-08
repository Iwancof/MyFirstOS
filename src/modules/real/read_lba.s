read_lba:	; read_lba(drive_param, lba, sect, dst)
	  	; lba : start addres, sect : how many
	push	bp
	mov	bp,sp
	push	si
	; not push ax. ax is return value

	mov	si, [bp + 4]
	mov	ax, [bp + 6]
	

	cdecl	lba_chs, word si, .chs, word ax

	mov	al, [si + drive.no]
	mov	[.chs + drive.no], al

	cdecl	read_chs, .chs, word [bp + 8], word [bp + 10]

	pop	si
	mov	sp, bp
	pop	bp

	ret
ALIGN 2
.chs:	times	drive_size	db	0
