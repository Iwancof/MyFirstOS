outb:
; out byte. outb(port, byte_data)
; port is 16bit, byte_data is byte
	push	ebp
	mov	ebp, esp
	push	eax
	push	edx

	mov	dx, word [ebp +  8]
	mov	al, byte [ebp + 12]
	out	dx, al

	pop	edx
	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

inb:
; input byte. byte_data = inb(port)
; port is 16bit, byte_data is byte
	push	ebp
	mov	ebp, esp

	push	edx
	mov	dx, word [ebp + 8]
	in	al, dx
	pop	edx
	
	mov	esp, ebp
	pop	ebp

	ret
