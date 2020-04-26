VECT_BASE		equ	0x0010_0000
KERNEL_LOAD		equ	0x0010_1000
STACK_BASE		equ	0x0010_3000
CR3_BASE		equ	0x0010_5000

RUST_LOAD		equ	0x0000_1000
RUST_MAIN		equ	0x0020_0000
RUST_SIZE		equ	0x0002_0000
RUST_SECT		equ	RUST_SIZE / SECT_SIZE
RUST_END		equ	RUST_LOAD + RUST_SIZE

HEAP_START		equ	RUST_MAIN + RUST_SIZE
HEAP_SIZE		equ	0x0010_0000
HEAP_END		equ	HEAP_START + HEAP_SIZE

BOOT_LOAD		equ	0x7c00
BOOT_SIZE		equ	(1024 * 8)
BOOT_SECT		equ	(BOOT_SIZE / SECT_SIZE)
BOOT_END		equ	BOOT_LOAD + BOOT_SIZE

SECT_SIZE		equ	(512)

E820_RECORD_SIZE	equ	20

KERNEL_SIZE		equ	(1024 * 8)
KERNEL_SECT		equ	(KERNEL_SIZE / SECT_SIZE)
KERNEL_END		equ	KERNEL_LOAD + KERNEL_SIZE
; KERNEL_END : 0x0010_3000


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

STACK_SIZE		equ	1024

SP_TASK_0		equ	STACK_BASE + (STACK_SIZE * 1)
SP_TASK_1		equ	STACK_BASE + (STACK_SIZE * 2)
SP_TASK_2		equ	STACK_BASE + (STACK_SIZE * 3)
SP_TASK_3		equ	STACK_BASE + (STACK_SIZE * 4)
SP_TASK_4		equ	STACK_BASE + (STACK_SIZE * 5)
SP_TASK_5		equ	STACK_BASE + (STACK_SIZE * 6)
SP_TASK_6		equ	STACK_BASE + (STACK_SIZE * 7)
SP_TASK_T		equ	STACK_BASE + (STACK_SIZE * 8)

PARAM_TASK_4		equ	0x0010_8000
PARAM_TASK_5		equ	0x0010_9000
PARAM_TASK_6		equ	0x0010_A000

CR3_TASK_4		equ	0x0020_0000
CR3_TASK_5		equ	0x0020_2000
CR3_TASK_6		equ	0x0020_4000
CR3_TASK_T		equ	0x0020_6000

FAT_SIZE equ (1024 * 128)
ROOT_SIZE equ (1024 * 16)

; not for rust
FAT1_START equ HEAP_END
FAT2_START equ (FAT1_START + FAT_SIZE)
ROOT_START equ (FAT2_START + FAT_SIZE)
FILE_START equ (ROOT_START + ROOT_SIZE)

ATTR_VOLUME_ID equ 0x08
ATTR_ARCHIVE equ 0x20

