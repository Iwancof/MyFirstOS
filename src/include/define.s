BOOT_LOAD		equ	0x7c00
BOOT_END		equ	BOOT_LOAD + BOOT_SIZE

BOOT_SIZE		equ	(1024 * 8)
SECT_SIZE		equ	(512)
BOOT_SECT		equ	(BOOT_SIZE / SECT_SIZE)

E820_RECORD_SIZE	equ	20

KERNEL_LOAD		equ	0x0010_1000
KERNEL_SIZE		equ	(1024 * 8)
KERNEL_SECT		equ	(KERNEL_SIZE / SECT_SIZE)

VECT_BASE		equ	0x0010_0000

%define			RING_ITEN_SIZE	(1 << 4)
%define			RING_INDEX_MASK	(RING_ITEN_SIZE - 1)

struc			ring_buff		; for keyboard
				.rp	resd	1
				.wp	resd	1
				.item	resb	RING_ITEM_SIZE
endstruc
