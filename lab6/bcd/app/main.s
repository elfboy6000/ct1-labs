; ------------------------------------------------------------------
; --  _____       ______  _____                                    -
; -- |_   _|     |  ____|/ ____|                                   -
; --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
; --   | | | '_ \|  __|  \___ \   Zurich University of             -
; --  _| |_| | | | |____ ____) |  Applied Sciences                 -
; -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
; ------------------------------------------------------------------
; --
; -- main.s
; --
; -- CT1 P06 "ALU und Sprungbefehle" mit MUL
; --
; -- $Id: main.s 4857 2019-09-10 17:30:17Z akdi $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address Defines
; ------------------------------------------------------------------

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_DIP_SWITCH_7_0     EQU     0x60000200
ADDR_DIP_SWITCH_15_8    EQU     0x60000201
ADDR_7_SEG_BIN_DS3_0    EQU     0x60000114
ADDR_BUTTONS            EQU     0x60000210

ADDR_LCD_RED            EQU     0x60000340
ADDR_LCD_GREEN          EQU     0x60000342
ADDR_LCD_BLUE           EQU     0x60000344
LCD_BACKLIGHT_FULL      EQU     0xffff
LCD_BACKLIGHT_OFF       EQU     0x0000

BITMASK_LOWER_NIBBLE    EQU     0x0F
BITMASK_KEY_T0          EQU     0x01
	
; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY

        ENTRY

main    PROC
        export main
            
; STUDENTS: To be programmed
		; Get BCD Tens
		LDR R4, =ADDR_DIP_SWITCH_15_8
		LDRB R0, [R4]						; R0 = BCD Tens
		MOVS R2, #BITMASK_LOWER_NIBBLE		
		ANDS R0, R0, R2						; R0 = R0 & 0x0F
		
		; Get BCD Ones
		LDR R5, =ADDR_DIP_SWITCH_7_0
		LDRB R1, [R5]						; R1 = BCD Ones
		ANDS R1, R1, R2						; R1 = R1 & 0x0F
		
		; Display BCD Values
		MOVS R3, R0							; R3 = BCD Tens
		LSLS R3, R3, #4						; Shift values to LED7..4
		ADDS R3, R3, R1						; R3 = BCD Tens + Ones
		LDR R6, =ADDR_LED_15_0
		LDR R7, =ADDR_7_SEG_BIN_DS3_0
		STRB  R3, [R6]						; Display to LED7..0
		STRB  R3, [R7]						; Display to DS1..0
		

		; Check if T0 Pressed
		LDR R5, =ADDR_BUTTONS				; Buttons
		LDRB R5, [R5]						; Load Values of Buttons
		MOVS R2, #BITMASK_KEY_T0			; T0 On
		TST R5, R2							; T0 == On ? (Z = 0)
		BNE red								; If Z == 0	
		
blue
		; Display Binary Values with Multiplication
		MOVS R2, R0							; R2 = BCD Tens
		MOVS R3, #10
		MULS R2, R3, R2					    ; R2 = 10 * R2
		
		ADDS R2, R2, R1						; R2 = R2 + BCD Ones
		ADDS R6, R6, #1						; Add 1 Byte to shift to LED15..8
		ADDS R7, R7, #1						; Add 1 Byte to shift to DS3..2
		STRB R2, [R6]						; Display to LED15..8	
		STRB R2, [R7]						; Display to DS3..2


		; Blue LCD
		LDR R4, =ADDR_LCD_BLUE
		LDR R0, =LCD_BACKLIGHT_FULL
		STRH R0, [R4]						; Turn Blue to Full
		LDR R4, =ADDR_LCD_RED
		LDR R0, =LCD_BACKLIGHT_OFF
		STRH R0, [R4]						; Turn Red to Off
		B end_color
		
red 
		; Display Binary Values with Shifts and Additions
		MOVS R2, #0							; R2 = 0
		LSLS R0, R0, #1						; Shift to 2
		ADDS R2, R2, R0						; R2 = R2 + R0 * 2
		LSLS R0, R0, #2						; Shift to 8
		ADDS R2, R2, R0						; R2 = R2 + R0 * 8
		
		ADDS R2, R2, R1						; R2 = R2 + BCD Ones
		ADDS R6, R6, #1						; Add 1 Byte to shift to LED15..8
		ADDS R7, R7, #1						; Add 1 Byte to shift to DS3..2
		STRB R2, [R6]						; Display to LED15..8	
		STRB R2, [R7]						; Display to DS3..2

		; Red LCD
		LDR R4, =ADDR_LCD_RED
		LDR R0, =LCD_BACKLIGHT_FULL
		STRH R0, [R4]						; Turn Red to Full
		LDR R4, =ADDR_LCD_BLUE
		LDR R0, =LCD_BACKLIGHT_OFF
		STRH R0, [R4]						; Turn Blue to Off
		
end_color
; END: To be programmed

        B       main
        ENDP
            
;----------------------------------------------------
; Subroutines
;----------------------------------------------------

;----------------------------------------------------
; pause for disco_lights
pause           PROC
        PUSH    {R0, R1}
        LDR     R1, =1
        LDR     R0, =0x000FFFFF
        
loop        
        SUBS    R0, R0, R1
        BCS     loop
    
        POP     {R0, R1}
        BX      LR
        ALIGN
        ENDP

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
