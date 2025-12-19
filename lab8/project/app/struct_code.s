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
; -- CT1 P08 "Strukturierte Codierung" mit Assembler
; --
; -- $Id: struct_code.s 3787 2016-11-17 09:41:48Z kesr $
; ------------------------------------------------------------------
;Directives
        PRESERVE8
        THUMB

; ------------------------------------------------------------------
; -- Address-Defines
; ------------------------------------------------------------------
; input
ADDR_DIP_SWITCH_7_0       EQU        0x60000200
ADDR_BUTTONS              EQU        0x60000210

; output
ADDR_LED_31_0             EQU        0x60000100
ADDR_7_SEG_BIN_DS3_0      EQU        0x60000114
ADDR_LCD_COLOUR           EQU        0x60000340
ADDR_LCD_ASCII            EQU        0x60000300
ADDR_LCD_ASCII_BIT_POS    EQU        0x60000302
ADDR_LCD_ASCII_2ND_LINE   EQU        0x60000314

; ------------------------------------------------------------------
; -- Program-Defines
; ------------------------------------------------------------------
; value for clearing lcd
ASCII_DIGIT_CLEAR        EQU         0x00000000
LCD_LAST_OFFSET          EQU         0x00000028

; offset for showing the digit in the lcd
ASCII_DIGIT_OFFSET        EQU        0x00000030

; lcd background colors to be written
DISPLAY_COLOUR_RED        EQU        0
DISPLAY_COLOUR_GREEN      EQU        2
DISPLAY_COLOUR_BLUE       EQU        4

COLOUR_ON                 EQU        0xFFFF
COLOUR_OFF                EQU        0x0000

; ------------------------------------------------------------------
; -- myConstants
; ------------------------------------------------------------------
        AREA myConstants, DATA, READONLY
; display defines for hex / dec
DISPLAY_BIT               DCB        "Bit "
DISPLAY_2_BIT             DCB        "2"
DISPLAY_4_BIT             DCB        "4"
DISPLAY_8_BIT             DCB        "8"
        ALIGN

; ------------------------------------------------------------------
; -- myCode
; ------------------------------------------------------------------
        AREA myCode, CODE, READONLY
        ENTRY

        ; imports for calls
        import adc_init
        import adc_get_value

main    PROC
        export main
        ; 8 bit resolution, cont. sampling
        BL         adc_init
        BL         clear_lcd

main_loop
; STUDENTS: To be programmed

        ; Read ADC value (0..255) and store it
        BL         adc_get_value                ; R0 = ADC (0-255)
        MOVS       R4, R0                       ; R4 = ADC
        MOVS       R3, #0xFF
        ANDS       R4, R4, R3                   ; keep only low 8-bit

        ; Read T0 Value
        LDR        R7, =ADDR_BUTTONS            ; R7 = Buttons
        LDRB       R7, [R7]                     ; R7 = Values of buttons
        MOVS       R0, #1                       ; R0 = 1 (mask for T0)
        TST        R7, R0                       ; T0 == 1 (Z = 0)
        BNE        green                        ; If (R7 & 1) != 0  -> case green
        B          skip                         ; else              -> case not pressed

green
        ; --- Case green (T0 pressed) ---
        ; Display ADC on DS3..0 (7-seg binary interface)
        LDR        R1, =ADDR_7_SEG_BIN_DS3_0
        STR        R4, [R1]

        ; LCD background = green (red/blue off)
        LDR        R6, =ADDR_LCD_COLOUR

        ; Red -> Off
        MOVS       R3, #DISPLAY_COLOUR_RED
        ADDS       R3, R3, R6
        LDR        R2, =COLOUR_OFF
        STRH       R2, [R3]

        ; Blue -> Off
        MOVS       R3, #DISPLAY_COLOUR_BLUE
        ADDS       R3, R3, R6
        STRH       R2, [R3]

        ; Green -> On
        MOVS       R3, #DISPLAY_COLOUR_GREEN
        ADDS       R3, R3, R6
        LDR        R2, =COLOUR_ON
        STRH       R2, [R3]

        ; LED-bar on LED31..0 depending on ADC-value
        ; scale with division by 8 (shift right) and use a loop
        MOVS       R0, R4                       ; R0 = ADC
        LSRS       R0, R0, #3                   ; R0 = ADC / 8  (0..31)

        ; clear LEDs
        LDR        R1, =ADDR_LED_31_0
        MOVS       R2, #0
        STR        R2, [R1]

        MOVS       R3, #1                       ; bit mask
        MOVS       R5, #0                       ; counter

green_led_loop
        CMP        R5, R0
        BGT        green_led_done               ; while(counter <= scaled)

        LDR        R2, [R1]                     ; current LEDs
        ORRS       R2, R2, R3                   ; set next LED bit
        STR        R2, [R1]

        LSLS       R3, R3, #1                   ; mask <<= 1
        ADDS       R5, R5, #1                   ; counter++
        B          green_led_loop

green_led_done
        B          main_loop

skip
        ; --- Case T0 not pressed ---
        ; Clear LED-bar (only required in green case)
        LDR        R1, =ADDR_LED_31_0
        MOVS       R2, #0
        STR        R2, [R1]

        ; Read DIP switches S7..S0
        LDR        R1, =ADDR_DIP_SWITCH_7_0
        LDRB       R2, [R1]                     ; R2 = DIP (0..255)

        ; diff = DIP - ADC
        SUBS       R5, R2, R4                   ; R5 = diff (signed)

        ; If diff >= 0 -> blue, else -> red
        BPL        blue

red
        ; --- Case red (diff < 0) ---
        BL         clear_lcd

        ; LCD background = red (green/blue off)
        LDR        R6, =ADDR_LCD_COLOUR

        ; Red -> On
        MOVS       R3, #DISPLAY_COLOUR_RED
        ADDS       R3, R3, R6
        LDR        R2, =COLOUR_ON
        STRH       R2, [R3]

        ; Green -> Off
        MOVS       R3, #DISPLAY_COLOUR_GREEN
        ADDS       R3, R3, R6
        LDR        R2, =COLOUR_OFF
        STRH       R2, [R3]

        ; Blue -> Off
        MOVS       R3, #DISPLAY_COLOUR_BLUE
        ADDS       R3, R3, R6
        STRH       R2, [R3]

        ; Count number of binary zeros in diff (8-bit)
        MOVS       R6, R5                       ; R6 = diff copy
        MOVS       R7, #0                       ; R7 = countZeros
        MOVS       R0, #8                       ; 8 bits

count_zero_loop
        MOVS       R2, #1                       ; mask
        ANDS       R2, R6, R2                   ; test LSB
        BNE        skip_inc                     ; if bit is 1 -> skip inc

        ADDS       R7, R7, #1                   ; bit was 0 -> count++

skip_inc
        LSRS       R6, R6, #1                   ; next bit
        SUBS       R0, R0, #1
        BNE        count_zero_loop

        ; Output count on second line of LCD (single digit 0..8)
        MOVS       R1, R7
        MOVS       R2, #ASCII_DIGIT_OFFSET
        ADDS       R1, R1, R2                   ; ASCII('0' + count)

        LDR        R3, =ADDR_LCD_ASCII_2ND_LINE
        STR        R1, [R3]

        B          show_diff

blue
        ; --- Case blue (diff >= 0) ---
        BL         clear_lcd

        ; LCD background = blue (red/green off)
        LDR        R6, =ADDR_LCD_COLOUR

        ; Red -> Off
        MOVS       R3, #DISPLAY_COLOUR_RED
        ADDS       R3, R3, R6
        LDR        R2, =COLOUR_OFF
        STRH       R2, [R3]

        ; Green -> Off
        MOVS       R3, #DISPLAY_COLOUR_GREEN
        ADDS       R3, R3, R6
        STRH       R2, [R3]

        ; Blue -> On
        MOVS       R3, #DISPLAY_COLOUR_BLUE
        ADDS       R3, R3, R6
        LDR        R2, =COLOUR_ON
        STRH       R2, [R3]

        ; Evaluate diff: 2 bit (<4), 4 bit (<16), else 8 bit
        CMP        R5, #4
        BLT        case_2bit

        CMP        R5, #16
        BLT        case_4bit

        ; default 8 bit
case_8bit
        MOVS       R0, #8
        B          write_digit_and_bit

case_4bit
        MOVS       R0, #4
        B          write_digit_and_bit

case_2bit
        MOVS       R0, #2

write_digit_and_bit
        ; Write digit ('2'/'4'/'8') on LCD first position
        MOVS       R1, R0
        MOVS       R2, #ASCII_DIGIT_OFFSET
        ADDS       R1, R1, R2

        LDR        R3, =ADDR_LCD_ASCII
        STR        R1, [R3]

        ; Write "Bit " using given function
        BL         write_bit_ascii

show_diff
        ; Display diff on DS3..0 (use low 8-bit)
        MOVS       R3, #0xFF
        ANDS       R5, R5, R3

        LDR        R1, =ADDR_7_SEG_BIN_DS3_0
        STR        R5, [R1]

; END: To be programmed
        B          main_loop

clear_lcd
        PUSH       {R0, R1, R2}
        LDR        R2, =0x0
clear_lcd_loop
        LDR        R0, =ADDR_LCD_ASCII
        ADDS       R0, R0, R2                       ; add index to lcd offset
        LDR        R1, =ASCII_DIGIT_CLEAR
        STR        R1, [R0]
        ADDS       R2, R2, #4                       ; increas index by 4 (word step)
        CMP        R2, #LCD_LAST_OFFSET             ; until index reached last lcd point
        BMI        clear_lcd_loop
        POP        {R0, R1, R2}
        BX         LR

write_bit_ascii
        PUSH       {R0, R1}
        LDR        R0, =ADDR_LCD_ASCII_BIT_POS
        LDR        R1, =DISPLAY_BIT
        LDR        R1, [R1]
        STR        R1, [R0]
        POP        {R0, R1}
        BX         LR

        ENDP
        ALIGN

; ------------------------------------------------------------------
; End of code
; ------------------------------------------------------------------
        END
