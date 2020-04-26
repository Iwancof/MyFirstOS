COM1	equ	0x3F8
COM2	equ	0x2F8
COM3	equ	0x3E8
COM4	equ	0x2E8

PORT	equ	COM1

init_serial:
	push	ebp
	mov	ebp, esp

	pusha

	moutb	PORT + 1, 0x00	; Disable all interrupts
   	moutb	PORT + 3, 0x80	; Enable DLAB (set baud rate divisor)
   	moutb	PORT + 0, 0x03	; Set divisor to 3 (lo byte) 38400 baud
   	moutb	PORT + 1, 0x00	;                  (hi byte)
   	moutb	PORT + 3, 0x03	; 8 bits, no parity, one stop bit
   	moutb	PORT + 2, 0xC7	; Enable FIFO, clear them, with 14-byte threshold
   	moutb	PORT + 4, 0x0B	; IRQs enabled, RTS/DSR set
	popa

	mov	esp, ebp
	pop	ebp

	ret

test_serial:
	push	ebp
	mov	ebp, esp

	pusha

	mov	cx, 0
.10L:
	; wait
	mov	dx, PORT + 5
	in	al, dx
	and	al, 0x20
	cmp	al, 0
	je	.10L

	moutb	PORT, cl
	;mov	dx, PORT
	;in	al, dx
		
	inc	cx
	cmp	cx, 0xFF
	jnz	.10L

	;cdecl	itoa, eax, .t0, 8, 16, 0b0100
	;cdecl	draw_str, 0, 10, 0x010F, .t0

	popa

	mov	esp, ebp
	pop	ebp

	ret

.t0:	db	"--------", 0
