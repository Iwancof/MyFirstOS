int_timer:
	pushad
	push	es
	push	ds

	mov	ax, 0x10
	mov	ds, ax
	mov	es, ax

	inc	dword[TIMER_COUNT]

	outp	0x20, 0x20

	str	ax

	cmp	ax, SS_TASK_0
	je	.91T		; 0 -> 1

	cmp	ax, SS_TASK_1
	je	.92T

	cmp	byte [DRAW_ROSE], 0
	je	.20S		; not draw
	jmp	.25S		; draw

.20S:
	cmp	byte [PLAY_TETR], 0
	je	.30S		; not play
	jmp	.35S
.30S:
	jmp	.90T
.35S:	; play tetris
	cmp	ax, SS_TASK_2
	je	.97T

	jmp	.90T
.25S:
	cmp	ax, SS_TASK_2
	je	.93T
	cmp	ax, SS_TASK_3
	je	.94T
	cmp	ax, SS_TASK_4
	je	.95T
	cmp	ax, SS_TASK_5
	je	.96T

	jmp	.90T

.90T:	; task0
	jmp	SS_TASK_0:0
	jmp	.10E
.91T:
	jmp	SS_TASK_1:0
	jmp	.10E
.92T:
	jmp	SS_TASK_2:0
	jmp	.10E
.93T:
	jmp	SS_TASK_3:0
	jmp	.10E
.94T:
	jmp	SS_TASK_4:0
	jmp	.10E
.95T:
	jmp	SS_TASK_5:0
	jmp	.10E
.96T:
	jmp	SS_TASK_6:0
	jmp	.10E
.97T:
	jmp	SS_TASK_T:0
	jmp	.10E

.10E:	; exit
	pop	ds
	pop	es
	popad
	
	iret

.t0:	db	"TEST", 0

ALIGN	4,	db	0
TIMER_COUNT:	dq	0


int_en_timer:
	push	ebp
	mov	ebp, esp
	
	push	eax

	outp	0x43, 0b00_11_010_0
	; counter 0
	; access mode, bottom -> top
	; mode, 2
	; bcd

	outp	0x40, 0x9C
	outp	0x40, 0x2E
	; 2E9C(16) = 11932(10) = (1193182 / 100)

	pop	eax

	mov 	esp, ebp
	pop	ebp

	ret

