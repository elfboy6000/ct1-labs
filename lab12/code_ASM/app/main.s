;* ----------------------------------------------------------------------------
;* --  _____       ______  _____
;* -- |_   _|     |  ____|/ ____|
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems
;* --   | | | '_ \|  __|  \___ \   Zurich University of
;* --  _| |_| | | | |____ ____) |  Applied Sciences
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland
;* ----------------------------------------------------------------------------
;*
;* -- Project     : CT1 - Lab 12
;* -- Description : Reading the user button as an interrupt source
;* -- $Id: main.s 5082 2020-05-14 13:56:07Z akdi $
;*
;* ----------------------------------------------------------------------------

                IMPORT  init_measurement
                IMPORT  clear_IRQ_EXTI0
                IMPORT  clear_IRQ_TIM2

; -----------------------------------------------------------------------------
; -- Constants
; -----------------------------------------------------------------------------

                AREA    myCode, CODE, READONLY
                THUMB

REG_GPIOA_IDR       EQU  0x40020010
LED_15_0            EQU  0x60000100
LED_16_31           EQU  0x60000102
REG_CT_7SEG         EQU  0x60000114
REG_SETENA0         EQU  0xe000e100

; -----------------------------------------------------------------------------
; -- Main
; -----------------------------------------------------------------------------

main            PROC
                EXPORT  main

                BL      init_measurement

                ; Configure NVIC (enable interrupt channels)
                LDR     R0, =REG_SETENA0     ; NVIC_ISER0
                MOVS    R1, #1
                LSLS    R1, R1, #6           ; R1 = 1 << 6  (EXTI0: IRQ 6)
                MOVS    R2, #1
                LSLS    R2, R2, #28          ; R2 = 1 << 28 (TIM2: IRQ 28)
                ORRS    R1, R1, R2           ; set both bits
                STR     R1, [R0]

				; Initialize variables
                LDR     R0, =counter
                MOVS    R1, #0
                STR     R1, [R0]

                LDR     R0, =buffer
                STR     R1, [R0]

loop
				; Output counter on 7-seg
                LDR     R0, =buffer
                LDR     R1, [R0]
                LDR     R0, =REG_CT_7SEG
                STR     R1, [R0]
                B       loop
                ENDP

; -----------------------------------------------------------------------------
; -- Handler for EXTI0 interrupt
; -----------------------------------------------------------------------------

EXTI0_IRQHandler PROC
                EXPORT  EXTI0_IRQHandler

                PUSH    {LR}

                ; Increment counter variable
                LDR     R0, =counter
                LDR     R1, [R0]
                ADDS    R1, R1, #1
                STR     R1, [R0]

                ; Clear EXTI0 interrupt request
                BL      clear_IRQ_EXTI0

                POP     {PC}
                ENDP

; -----------------------------------------------------------------------------
; -- Handler for TIM2 interrupt
; -----------------------------------------------------------------------------

TIM2_IRQHandler PROC
                EXPORT  TIM2_IRQHandler

                PUSH    {LR}

                LDR     R0, =LED_15_0
                LDR     R1, [R0]
                MVNS    R1, R1               ; invert LED pattern
                STR     R1, [R0]

                ; Copy counter value into buffer
                LDR     R0, =counter
                LDR     R2, [R0]             ; R2 = current count
                LDR     R3, =buffer
                STR     R2, [R3]             ; store in buffer

                ; Reset counter
                MOVS    R2, #0
                STR     R2, [R0]

                ; Clear timer interrupt request
                BL      clear_IRQ_TIM2

                POP     {PC}
                ENDP

                ALIGN

; -----------------------------------------------------------------------------
; -- Variables
; -----------------------------------------------------------------------------

                AREA    myVars, DATA, READWRITE

counter         DCD     0       ; Counter incremented by EXTI0 handler
buffer          DCD     0       ; Buffered value written by TIM2 handler

; -----------------------------------------------------------------------------
; -- End of file
; -----------------------------------------------------------------------------

                END
