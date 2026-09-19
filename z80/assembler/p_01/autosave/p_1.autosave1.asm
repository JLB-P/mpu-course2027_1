;Author:jlb
;display text of any lenght

;code segment starts here
	.org 0000h
	;program port
	;Port A-> output, PortB-> output, Port C<- input
	ld a,89h
	out (CW),a
	;init stack
	ld SP,ffffh
	;-----------
	ld hl,text1	;point to text to display
	call desp_text
	call lee_KEYB
	halt
;subroutines

desp_text:	;--init
	ld a,(hl)
	cp '&'
	jp z,fin
	out (lcd),a
	inc hl
	jp desp_text
fin:
	ret	;--end

lee_KEYB:
	in a,(KEYB)
	cp '1'
	call z,leds_izq
	cp '2'
	call z,leds_der
	ret
	
leds_izq:
	ld a,0ffh
otra:
	out (LEDs),a
	sla a
	jp nz,otra
	ret

leds_der:
	ld a,0ffh
otra:
	out (LEDs),a
	sla a
	jp nz,otra
	ret
	
;data segment
	.org f800h
text1:	.db "ingresa opcion (1:LEDs 2:LCD): &"

;constants
LCD:	.equ 20h
LEDs:	.equ 21h
KEYB:	.equ 22h
CW	.equ 23h

;program ends
	.end