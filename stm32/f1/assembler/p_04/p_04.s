;program: external interrupt
;author: jlbPacheco
;GPIO programming flow
; 1) enable GPIO port clock
; 2) configure GPIOx_CRL/CRH set mode and speed
; 3) access data registers ODR/IDR/BSRR

;assembler directives
;--------------------
			area constants, data, readonly 		;constants readonly area
RCC_APB2ENR equ	0x40021018						;Clock enable register addres (0x4002 1000 + 0x18)
GPIOC_CRL	equ	0x40011000						;GPIO port C low (0x4001 1000 + 0x00)
GPIOC_CRH	equ	0x40011004						;GPIO port C high (0x4001 1000 + 0x04)
GPIOC_ODR	equ 0x4001100C						;Port output register (0x4001 1000 + 0x0C)
	
;programa
			area p_04, code, readonly 	;code readonly
			export __main				;export to startup_stm32f10x_md.s
;main program begin
;------------------
__main
	;enable GPIO_C port clock
	;------------------------
	ldr r0, =0x00000010		;word (bit4=1)to enable port C clock (Reference Manual pag.113)
	ldr r1, =RCC_APB2ENR	;load register address
	str r0, [r1]			;write word to register
	
	;reset register CRL
	ldr r0,=0x44444444		;word to reset the port
	ldr r1,=GPIOC_CRL		
	str r0,[r1]				;reset 
	
	;set mode and speed GPIO_C pin 13
	;--------------------------------
	ldr r0,=0x44244444		;word (bit23=0,bit22=0,bit21=1,bit20=0) to set:
							;General purpose output push-pull, max speed 2 MHz
							;(Reference Manual pag.172)
	ldr r1,=GPIOC_CRH
	str r0,[r1]				;set
	
loop
	;access to ODR
	;-------------
	ldr r0,=0x00002000		;word (ODR13=1)to write "1" in pin 13(Reference Manual pag.173)
	ldr r1,=GPIOC_ODR
	str r0,[r1]				;write
	
	ldr r0,=0x00000000		;word (ODR13=0)to write "0" in pin 13(Reference Manual pag.173)
	ldr r1,=GPIOC_ODR
	str r0,[r1]				;write
	
	b loop	; infinite loop
;end of program
;--------------
	end	