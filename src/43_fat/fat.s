
	times	(FAT1_START) - ($ - $$)	db	0x00

FAT1:
	db	0xFF, 0xFF
	dw	0xFFFF
	dw	0xFFFF

	times	(FAT2_START) - ($ - $$)	db	0x00

FAT2:
	db	0xFF, 0xFF
	dw	0xFFFF
	dw	0xFFFF


	times	(ROOT_START) - ($ - $$)	db	0x00

FAT_ROOT:
	db	'BOOTABLE', 'DSK'
	db	ATTR_ARCHIVE | ATTR_VOLUME_ID
	db	0x00
	db	0x00
	dw	( 0 << 11) | (0 << 5) | (0 / 2)	; 1980/1/1
	dw	( 0 <<  9) | (0 << 5) | ( 1)
	dw	( 0 <<  9) | (0 << 5) | ( 1)
	dw	0x0000
	dw	( 0 << 11) | (0 << 5) | (0 / 2)
	dw	( 0 <<  9) | (0 << 5) | ( 1)
	dw	0
	dd	0

	db	'SPECIAL', 'TXT'
	db	ATTR_ARCHIVE
	db	0x00
	db	0x00
	dw	( 0 << 11) | (0 << 5) | (0 / 2)	; 1980/1/1
	dw	( 0 <<  9) | (1 << 5) | ( 1)
	dw	( 0 <<  9) | (1 << 5) | ( 1)
	dw	0x0000
	dw	( 0 << 11) | (0 << 5) | (0 / 2)
	dw	( 0 <<  9) | (1 << 5) | ( 1)
	dw	2				; 2 is top cluster
	dd	FILE.end - FILE

	times	FILE_START - ($ - $$)	db	0x00

FILE:	db	'Hello, FAT!'
.end:	db	0

ALIGN	512,	db	0x00
	
	times	(512 * 63)	db	0x00

