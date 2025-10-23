; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- sumdiff.s
; --
; -- CT1 P05 Summe und Differenz
; --
; -- $Id: sumdiff.s 705 2014-09-16 11:44:22Z muln $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_LED_7_0            EQU     0x60000100
ADDR_LED_15_8           EQU     0x60000101
ADDR_LED_23_16          EQU     0x60000102
ADDR_LED_31_24          EQU     0x60000103

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA MyCode, CODE, READONLY

main    PROC
        EXPORT main

user_prog
        ; STUDENTS: To be programmed
        LDR     R4, =ADDR_DIP_SWITCH_15_8
        LDRB    R1, [R4]            ; R1 = S15..S8
        LDR     R5, =ADDR_DIP_SWITCH_7_0
        LDRB    R0, [R5]            ; R0 = S7..S0
		
		; Expand to 32-bit by shifting left 24
        LSLS    R1, R1, #24         ; R1 <<= 24
        LSLS    R0, R0, #24         ; R0 <<= 24

		; SUM
		MOV 	R2, R1				; R2 = S15..S8 (no flags)
		ADDS 	R2, R2, R0 			; R2 = R2 + R1
		MRS     R7, APSR            ; read flags (NZCV at bits 31..28)
		
		LSRS 	R3, R2, #24	  		; R3 = MSB(SUM)	
		LDR 	R6, =ADDR_LED_7_0
		STRB 	R3, [R6]			; LED7..0 <- R3
		
		MOV 	R6, R7
		LSRS    R6, R6, #24         ; move flags to bits 7..4
        LDR     R3, =ADDR_LED_15_8
        STRB    R6, [R3]            ; LEDs 15..12 show NZCV
		
		; SUB
		MOV 	R2, R1				; R2 = S15..S8 (no flags)
		SUBS 	R2, R2, R0 			; R2 = R2 - R1
		MRS     R7, APSR            ; read flags (NZCV at bits 31..28)
        		
		LSRS 	R3, R2, #24	  		; R3 = MSB(SUM)	
		LDR 	R6, =ADDR_LED_23_16
		STRB 	R3, [R6]			; LED23..16 <- R3

		MOV 	R6, R7
        LSRS    R6, R6, #24         ; move flags to bits 7..4
        LDR     R3, =ADDR_LED_31_24
        STRB    R6, [R3]            ; LEDs 31..28 show NZCV
		

        ; END: To be programmed
        B       user_prog
        ALIGN
; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
