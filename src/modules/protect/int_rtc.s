int_rtc:
	pusha		; all registers in stack
	push	ds
	push	es

	; select second segment
	mov	ax, 0x0010	; 8 * 2
	mov	ds, ax
	mov	es, ax

	cdecl	rtc_get_time, RTC_TIME

	outp	0x70, 0x0C
	in	al, 0x71

	mov	al, 0x20	; End of interrupt command
	out	0x20, al
	out	0xA0, al

	pop	es
	pop	ds
	popa

	iret

rtc_int_en:
	push	ebp
	mov	ebp, esp

	push	eax

	outp	0x70, 0x0B

	in	al, 0x71
	or	al, [ebp + 8]

	out	0x71, al

	pop	eax

	mov	esp, ebp
	pop	ebp

	ret

