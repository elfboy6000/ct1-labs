; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- table.s
; --
; -- CT1 P04 Ein- und Ausgabe von Tabellenwerten
; --
; -- $Id: table.s 800 2014-10-06 13:19:25Z ruan $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB
; ------------------------------------------------------------------
; -- Symbolic Literals
; ------------------------------------------------------------------
ADDR_DIP_SWITCH_7_0         EQU     0x60000200
ADDR_DIP_SWITCH_15_8        EQU     0x60000201
ADDR_DIP_SWITCH_31_24       EQU     0x60000203
ADDR_LED_7_0                EQU     0x60000100
ADDR_LED_15_8               EQU     0x60000101
ADDR_LED_23_16              EQU     0x60000102
ADDR_LED_31_24              EQU     0x60000103
ADDR_BUTTONS                EQU     0x60000210

BITMASK_KEY_T0              EQU     0x01
BITMASK_LOWER_NIBBLE        EQU     0x0F

; ------------------------------------------------------------------
; -- Variables
; ------------------------------------------------------------------
        AREA MyAsmVar, DATA, READWRITE
; STUDENTS: To be programmed

table_16x8                  SPACE   16          ; 16-byte table in RAM (indexes 0..15)

; END: To be programmed
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

main    PROC
        EXPORT main

readInput
        BL    waitForKey                    ; wait for key to be pressed and released
; STUDENTS: To be programmed
	
	        ; R4..R7 will hold peripheral addresses, R3 = base of table
        LDR     R4, =ADDR_DIP_SWITCH_7_0    ; S7..S0 (8-bit value)
        LDR     R5, =ADDR_DIP_SWITCH_15_8   ; S15..S8 (index is S11..S8 -> low nibble)
        LDR     R6, =ADDR_LED_7_0           ; LED7..0 (show value)
        LDR     R7, =ADDR_LED_15_8          ; LED15..8 (show index on LED11..8)
        LDR     R3, =table_16x8             ; base address of table
		LDR     R2, =BITMASK_LOWER_NIBBLE   ; mask for S11..S8 (lower nibble)

        ; Read value and index
        LDRB    R0, [R4]                    ; R0 = value (S7..S0)
        LDRB    R1, [R5]                    ; R1 = DIP15..8
		
		; R1 currently has DIP15..8
        ANDS    R1, R1, R2                 ; R1 = R1 & 0x0F

        ; Store value into table[index]
        ADDS     R2, R3, R1                 ; R2 = &table[index]
        STRB    R0, [R2]                    ; table[index] = value

        ; Debug outputs:
        STRB    R0, [R6]                    ; show value on LED7..0
        STRB    R1, [R7]                    ; show index nibble on LED11..8 (upper nibble off)

		; LDR

; END: To be programmed
        B       readInput
        ALIGN

; ------------------------------------------------------------------
; Subroutines
; ------------------------------------------------------------------

; wait for key to be pressed and released
waitForKey
        PUSH    {R0, R1, R2}
        LDR     R1, =ADDR_BUTTONS           ; laod base address of keys
        LDR     R2, =BITMASK_KEY_T0         ; load key mask T0

waitForPress
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is pressed
        BEQ     waitForPress

waitForRelease
        LDRB    R0, [R1]                    ; load key values
        TST     R0, R2                      ; check, if key T0 is released
        BNE     waitForRelease
                
        POP     {R0, R1, R2}
        BX      LR
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        ENDP
        END
