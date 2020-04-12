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

%define			RING_ITEM_SIZE	(1 << 4)
%define			RING_INDEX_MASK	(RING_ITEM_SIZE - 1)

struc			ring_buff		; for keyboard
				.rp	resd	1
				.wp	resd	1
				.item	resb	RING_ITEM_SIZE
endstruc

struc			rose
				.x0		resd	1
				.y0		resd	1
				.x1		resd	1
				.y1		resd	1

				.n		resd	1
				.d		resd	1

				.color_x	resd	1
				.color_y	resd	1
				.color_z	resd	1
				.color_s	resd	1
				.color_f	resd	1
				.color_b	resd	1
				
				.title		resb	16
endstruc

;struc ring_buff
;    .rp resd 1                  ; RP:書き込み位置
;    .wp resd 1                  ; WP:読み込み位置
;    .item resb RING_ITEM_SIZE   ; バッファ
;endstruc

STACK_BASE		equ	0x0010_3000
STACK_SIZE		equ	1024

SP_TASK_0		equ	STACK_BASE + (STACK_SIZE * 1)
SP_TASK_1		equ	STACK_BASE + (STACK_SIZE * 2)
SP_TASK_2		equ	STACK_BASE + (STACK_SIZE * 3)
SP_TASK_3		equ	STACK_BASE + (STACK_SIZE * 4)
