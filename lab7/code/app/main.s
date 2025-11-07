;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 7
;* -- Description : Control structures
;* -- 
;* -- $Id: main.s 3748 2016-10-31 13:26:44Z kesr $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
    
                AREA myCode, CODE, READONLY
                    
                THUMB

ADDR_LED_15_0           EQU     0x60000100
ADDR_LED_31_16          EQU     0x60000102
ADDR_7_SEG_BIN_DS1_0    EQU     0x60000114
ADDR_DIP_SWITCH_15_0    EQU     0x60000200
ADDR_HEX_SWITCH         EQU     0x60000211

NR_CASES                EQU     0xB
	
BITMASK					EQU		0xFF
LOWER_BITMASK			EQU		0x0F

jump_table      ; ordered table containing the labels of all cases
                ; STUDENTS: To be programmed 
				DCD	case_dark
				DCD case_add
				DCD case_sub
				DCD case_mul
				DCD case_and
				DCD case_or
				DCD case_xor
				DCD case_not
				DCD case_nand
				DCD case_nor
				DCD case_xnor
				DCD case_default
				


                ; END: To be programmed
    

; -------------------------------------------------------------------
; -- Main
; -------------------------------------------------------------------   
                        
main            PROC
                EXPORT main
                
read_dipsw      ; Read operands into R0 and R1 and display on LEDs
                ; STUDENTS: To be programmed
				LDR R7, =ADDR_DIP_SWITCH_15_0
				LDR R0, [R7]					; R0 = DIP15..0
				LDR R6, =ADDR_LED_15_0
				STR R0, [R6]					; Display DIP on LED15..0
				
				LSRS R0, R0, #8					; Remove Lower bits (R0 = Higher bits)
				
				LDR R1, [R7]					; R1 = DIP15..0
				LDR R5, =BITMASK				; R5 = 0xFF
				ANDS R1, R1, R5					; R1 = Lower bits
				


                ; END: To be programmed
                    
read_hexsw      ; Read operation into R2 and display on 7seg.
                ; STUDENTS: To be programmed
				LDR R3, =ADDR_HEX_SWITCH
				LDR R2, [R3]					; R2 = hex switch value
				MOVS R4, #LOWER_BITMASK			; R2 = 0x0F
				ANDS R2, R2, R4					; Only grab first Byte
				
				LDR R3, =ADDR_7_SEG_BIN_DS1_0
				STR R2, [R3]					; Display hex switch
				

                ; END: To be programmed
                
case_switch     ; Implement switch statement as shown on lecture slide
                ; STUDENTS: To be programmed
				CMP    R2, #NR_CASES			; R2 < 11?
				BHS    case_default				; If not do default
				LSLS  R2, #2					; *4 (to jump each case)
				LDR    R7, =jump_table			; R7 = jump table address
				LDR   R7, [R7, R2]				; R7 += Case address
				BX    R7						; Go to Case

                ; END: To be programmed


; Add the code for the individual cases below
; - operand 1 in R0
; - operand 2 in R1
; - result in R0

case_dark       
                LDR  R0, =0
                B    display_result  

case_add        
                ADDS R0, R0, R1
                B    display_result
				
case_sub       
                SUBS R0, R0, R1
                B    display_result
				
case_mul        
                MULS R0, R1, R0
                B    display_result
						
case_and        
                ANDS R0, R0, R1
                B    display_result
						
case_or        
                ORRS R0, R0, R1
                B    display_result
						
case_xor        
                EORS R0, R0, R1
                B    display_result
						
case_not        
                MVNS R0, R0
                B    display_result
						
case_nand        
                ANDS R0, R0, R1
				B case_not
                B    display_result
						
case_nor       
                ORRS R0, R0, R1
				B case_not
                B    display_result
						
case_xnor        
                EORS R0, R0, R1
				B case_not
                B    display_result
				
case_default
				LDR  R0, =0xFFFF
                B    display_result

; STUDENTS: To be programmed


; END: To be programmed


display_result  ; Display result on LEDs
                ; STUDENTS: To be programmed
				LDR R5, =ADDR_LED_31_16
				STR R0, [R5]				; Display result of R0

                ; END: To be programmed

                B    read_dipsw
                
                ALIGN
                ENDP

; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END

