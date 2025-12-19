;* ------------------------------------------------------------------
;* --  _____       ______  _____                                    -
;* -- |_   _|     |  ____|/ ____|                                   -
;* --   | |  _ __ | |__  | (___    Institute of Embedded Systems    -
;* --   | | | '_ \|  __|  \___ \   Zurich University of             -
;* --  _| |_| | | | |____ ____) |  Applied Sciences                 -
;* -- |_____|_| |_|______|_____/   8401 Winterthur, Switzerland     -
;* ------------------------------------------------------------------
;* --
;* -- Project     : CT1 - Lab 10
;* -- Description : Search Max
;* -- 
;* -- $Id: search_max.s 879 2014-10-24 09:00:00Z muln $
;* ------------------------------------------------------------------


; -------------------------------------------------------------------
; -- Constants
; -------------------------------------------------------------------
                AREA myCode, CODE, READONLY
                THUMB
                    
; STUDENTS: To be programmed




; END: To be programmed
; -------------------------------------------------------------------                    
; Searchmax
; - table address in R0
; - table length in R1
; - result returned in R0
; -------------------------------------------------------------------   
search_max      PROC
                EXPORT search_max

                ; STUDENTS: To be programmed
                
                ; Save working registers R4–R7 if they are used
                PUSH        {R4, R5}
                
                ; Guard: if length is 0 -> return 0x80000000
                CMP         R1, #0
                BNE         not_zero_length
                
                ; Length is 0 here
                LDR         R0, =0x80000000
                B           finish

not_zero_length
                MOVS        R4, R0                  ; copy of table address
                
                ; max = tab[0]
                LDR         R5, [R4]                ; R5 = first entry as max 
                ADDS        R4, R4, #4              ; move to next entry: base address + index * size (1 * 4 bytes for 32-bit values)
                SUBS        R1, R1, #1              ; reduce table length since this counts how many values remain to be checked
              
loop_start
                CMP         R1, #0                  ; if length = 0 (no more elements), exit loop
                BEQ         loop_end
                
                ; still elements left
                LDR         R2, [R4]                ; R2 = current value
                
                ; if (value > max)
                CMP         R2, R5
                BLE         skip_update             ; R2 is smaller, no update
                
                ; Here, R2 is greater than R5
                MOVS        R5, R2                  ; R5 = R2 -> max = current value
                
skip_update     
                ADDS        R4, R4, #4              ; next element
                SUBS        R1, R1, #1              ; counter--
                B           loop_start
                
loop_end
                MOVS        R0, R5                  ; result = max
                
finish          
                POP         {R4, R5}
                BX          LR
                

                ; END: To be programmed
                ALIGN
                ENDP
; -------------------------------------------------------------------
; -- End of file
; -------------------------------------------------------------------                      
                END
