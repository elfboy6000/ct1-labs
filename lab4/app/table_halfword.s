; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- table_halfword.s
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

ADDR_SEG7_1_0               EQU     0x60000114    ; DS1..DS0 (value / low byte)
ADDR_SEG7_3_2               EQU     0x60000115    ; DS3..DS2 (index / high byte)

BITMASK_KEY_T0              EQU     0x01
BITMASK_LOWER_NIBBLE        EQU     0x0F

; ------------------------------------------------------------------
; -- Variables
; ------------------------------------------------------------------
        AREA MyAsmVar, DATA, READWRITE

        ALIGN   2                               ; half-word alignment
table                  SPACE   32          ; 16 half-words (index<<1 addressing)

        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

main    PROC
        EXPORT main

readInput
        BL    waitForKey                    ; wait for key to be pressed and released

        ; R4..R7 will hold peripheral addresses, R3 = base of table, R2 = bitmask
        LDR     R4, =ADDR_DIP_SWITCH_7_0    ; S7..S0 (8-bit value)
        LDR     R5, =ADDR_DIP_SWITCH_15_8   ; S15..S8 (index is S11..S8 -> low nibble)
        LDR     R6, =ADDR_LED_7_0           ; LED7..0 (show value)
        LDR     R7, =ADDR_LED_15_8          ; LED15..8 (show index on LED11..8)
        LDR     R3, =table             		; base address of (half-word) table
        LDR     R2, =BITMASK_LOWER_NIBBLE   ; mask for S11..S8 (lower nibble)

        ; Read value and index
        LDRB    R0, [R4]                    ; R0 = value (S7..S0)
        LDRB    R1, [R5]                    ; R1 = DIP15..8
        ANDS    R1, R1, R2                  ; R1 = R1 & 0x0F (index 0..15)

        ; Show raw inputs
        STRB    R0, [R6]                    ; LED7..0  <- value
        STRB    R1, [R7]                    ; LED11..8 <- index (upper nibble off)

        ;  Store half-word: [MSB=index | LSB=value]
        ; Build 16-bit word in R6 = (index<<8) + value
        MOV     R4, R1                      ; keep index copy in R4
        LSLS    R6, R1, #8                  ; R6 = index << 8  (high byte)
        ADDS    R6, R6, R0                  ; R6 = (index<<8) | value

        ; Address = base + (index * 2)
        LSLS    R4, R4, #1                  ; R4 = index * 2
        ADDS    R3, R3, R4                  ; R3 = &table[index]

        STRH    R6, [R3]                    ; store half-word

        ; Output index S27-24 to LED27-24 
        LDR     R0, =ADDR_DIP_SWITCH_31_24
        LDRB    R4, [R0]
        ANDS    R4, R4, R2

        LDR     R0, =ADDR_LED_31_24
        STRB    R4, [R0]

        ; Read half-word at output index & display value
        ; Compute address = base + (outIdx * 2)
        LDR     R0, =table
        LSLS    R4, R4, #1                  ; outIdx * 2
        ADDS    R0, R0, R4
        LDRH    R6, [R0]                    ; R6 = [MSB=index | LSB=value]

        ; LED23..16 should show the VALUE (low byte)
        LDR     R0, =ADDR_LED_23_16
        STRB    R6, [R0]                    ; only low byte is written

        ; Also show on 7-seg: DS3..DS2 = index, DS1..DS0 = value
        ; Low byte (value) -> SEG7_1_0
        LDR     R1, =ADDR_SEG7_1_0
        LDR     R5, =0xFF
        MOV     R7, R6
        ANDS    R7, R7, R5                   ; R7 = value (low byte)
        STRB    R7, [R1]

        ; High byte (index) -> SEG7_3_2
        LDR     R2, =ADDR_SEG7_3_2
        LSRS    R7, R6, #8                   ; R7 = index (high byte)
        STRB    R7, [R2]

        ; --------------------------------------------------------------------------
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
