get_mem_info:
	
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	si
	push	di
	push	bp
	;push	es

	cdecl	puts, .s0

	mov	bp, 0
	mov	ebx, 0
.10L:
	mov	eax, 0x0000E820
	mov	ecx, E820_RECORD_SIZE
	mov	edx, 'PAMS'
	mov	di, .record
	int	0x15

	cmp	eax, 'PAMS'	; can use 32bit register(0x66)
	je	.12E		; can use
	jmp	.10E		; can not use
.12E:
	jnc	.14E		; not occure error
	jmp	.10E		; occure error
.14E:				; start
	
	cdecl	put_mem_info, di

	mov	eax, [di + 16]	; record type. see p332
	cmp	eax, 3
	jne	.15E
	
	mov	eax, [di + 0]	; base address(1byte data)
	mov	[ACPI_DATA.adr], eax
	mov	eax, [di + 8]	; length(1byte data)
	mov	[ACPI_DATA.len], eax
.15E:
	cmp	ebx, 0		; ebx equal 0 if last data
	jz	.16E		; last data

	inc	bp		; bp is line_counter
	and	bp,0x07		; bp %= 8
	jnz	.16E

	cdecl	puts, .s2
	mov	ah,0x10
	int	0x16
	cdecl	puts, .s3

.16E:
	cmp	ebx,0
	jne	.10L		; not last data --> continue
.10E:

	cdecl	puts, .s1

	;pop	es
	pop	bp
	pop	di
	pop	si
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	ret

ALIGN 	4,	db 	0
.record: times E820_RECORD_SIZE	db	00
.s0:	db " E820 Memory Map:", 0x0A, 0x0D
	db " Base_____________ Length___________ Type____", 0x0A, 0x0D, 0
.s1:	db " ----------------- ----------------- --------", 0x0A, 0x0D, 0
.s2:	db	" <more...>", 0
.s3:	db	0x0D, "           ",0x0D,0


put_mem_info:
	
	push	bp
	mov	bp,sp

	push	bx
	push	si

	mov	si, [bp + 4]	; si is address to mem_info
	cdecl	itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100
	cdecl	itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100

	cdecl	itoa, word [si +14], .p4 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si +12], .p4 + 4, 4, 16, 0b0100
	cdecl	itoa, word [si +10], .p5 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si + 8], .p5 + 4, 4, 16, 0b0100

	cdecl	itoa, word [si +18], .p6 + 0, 4, 16, 0b0100
	cdecl	itoa, word [si +16], .p6 + 4, 4, 16, 0b0100

	cdecl	puts, .s1

	mov	bx, [si +16]
	and	bx, 0x07
	shl	bx, 1		; per 2 byte
	add	bx, .t0
	cdecl	puts, word[bx]

	pop	si
	pop	bx

	mov	sp,bp
	pop	bp

	;cdecl	itoa, bp, .t1,4,10,0b0100
	;cdecl	puts, .t1

	ret

.s1:	db	" "
.p2:	db	"ZZZZZZZZ_"
.p3:	db	"ZZZZZZZZ "
.p4:	db	"ZZZZZZZZ_"
.p5:	db	"ZZZZZZZZ "
.p6:	db	"ZZZZZZZZ",0

.s4:	db	" (Unknown)",0x0A,0x0D,0
.s5:	db	" (Usable)",0x0A,0x0D,0
.s6:	db	" (Reserved)",0x0A,0x0D,0
.s7:	db	" (ACPI data)",0x0A,0x0D,0
.s8:	db	" (ACPI NVS)",0x0A,0x0D,0
.s9:	db	" (Bad memory)",0x0A,0x0D,0

.t0:	dw	.s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4

.t1:	db	"      ",0
