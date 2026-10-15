;program: External interrupt on GPIOA(PA0), LED toggle on GPIOC(PC13)
;author: jlbPacheco
;
;GPIO programming flow
; 1) enable GPIOs clocks
; 2) configure GPIOx_CRL/CRH set mode and speed
; 3) access data registers ODR/IDR/BSRR
;EXTI0 programming flow
; 1) enable AFIO clock
; 2) configure GPIOx as input with pull-up
; 3) 
;assembler directives
;--------------------
			area constants, data, readonly   ; define section for constants

;Base registers address (reference manual pag.50-51)
RCC_BASE    EQU 0x40021000	
GPIOC_BASE  EQU 0x40011000	
GPIOA_BASE  EQU 0x40010800	
AFIO_BASE   EQU 0x40010000	
EXTI_BASE   EQU 0x40010400	
;---------------------------------------------------

RCC_APB2ENR EQU RCC_BASE  + 0x18
	
GPIOA_CRL   EQU GPIOA_BASE + 0x00
GPIOA_IDR   EQU GPIOA_BASE + 0x08

GPIOC_CRH   EQU GPIOC_BASE + 0x04
GPIOC_ODR   EQU GPIOC_BASE + 0x0C

AFIO_EXTICR1 EQU AFIO_BASE  + 0x08

EXTI_IMR    EQU EXTI_BASE  + 0x00
EXTI_RTSR   EQU EXTI_BASE  + 0x08
EXTI_PR     EQU EXTI_BASE  + 0x14

NVIC_ISER0  EQU 0xE000E100      ; enables IRQ 6 (EXTI0)
NVIC_IPR0   EQU 0xE000E400      ; priority register for IRQ 6
;programa
	
	
;main program begin
;------------------
		area p_04, code, readonly
        thumb                           ; use thumb instruction set

        export __main
        export EXTI0_IRQHandler
			
__main 	
	;---- 1. Enable clocks: IOPC, IOPA, AFIO ----
        LDR     R0, =RCC_APB2ENR
        LDR     R1, [R0]
        ORR     R1, R1, #(1<<2 | 1<<4 | 1<<0)   ; IOPAEN | IOPCEN | AFIOEN
        STR     R1, [R0]
	;---- 2. PA0 as input floating (CNF=01, MODE=00) ----
        LDR     R0, =GPIOA_CRL
        LDR     R1, [R0]
        BIC     R1, R1, #0xF
        ORR     R1, R1, #0x4            ; floating input
        STR     R1, [R0]
    ;---- 3. PC13 as push-pull output 2MHz (CNF=00, MODE=10) ----
        LDR     R0, =GPIOC_CRH
        LDR     R1, [R0]
        BIC     R1, R1, #0x00F00000
        ORR     R1, R1, #0x00200000
        STR     R1, [R0]
	; PC13 starts OFF (ODR13 = 0)
        LDR     R0, =GPIOC_ODR
        MOV     R1, #0
        STR     R1, [R0]
	
	;---- 4. Route EXTI0 to PORT A (AFIO_EXTICR1[3:0] = 0000) ----
        LDR     R0, =AFIO_EXTICR1
        LDR     R1, [R0]
        BIC     R1, R1, #0xF
        STR     R1, [R0]
		
	;---- 5. EXTI0 rising edge trigger ----
        LDR     R0, =EXTI_RTSR
        LDR     R1, [R0]
        ORR     R1, R1, #1              ; TR0
        STR     R1, [R0]	
	; Unmask EXTI0
        LDR     R0, =EXTI_IMR
        LDR     R1, [R0]
        ORR     R1, R1, #1              ; MRx0
        STR     R1, [R0]
	;---- 6. NVIC: enable IRQ 6 (EXTI0), priority 0 ----
        LDR     R0, =NVIC_IPR0
        LDR     R1, [R0]
        BIC     R1, R1, #0xFF
        STR     R1, [R0]

        LDR     R0, =NVIC_ISER0
        MOV     R1, #(1<<6)
        STR     R1, [R0]	
Loop
        WFI                             ; wait for interrupt
        B       Loop	
		
;--------------------------------------------------------------
; EXTI0 Interrupt Service Routine (IRQ handler, name must match
; the vector table in startup_stm32f10x_md.s)
;--------------------------------------------------------------
EXTI0_IRQHandler 

; toggle PC13
	ldr     R0, =GPIOC_ODR
	ldr     R1, [R0]
	eor     R1, R1, #(1<<13)
	str     R1, [R0]

; clear pending bit (write 1 to clear)
	ldr     R0, =EXTI_PR
	mov     R1, #1
	str     R1, [R0]
	bx      LR
	end			