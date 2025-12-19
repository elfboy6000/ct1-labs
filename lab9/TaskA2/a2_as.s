            AREA myCode, CODE, READONLY
            THUMB    
        
            EXPORT out_word             ;make the function global
out_word    PROC
            ; out_word(addr, value)
            ; R0 = addr, R1 = value
            STR     R1, [R0]            ;R0 adress out_adress r1= ourvalue
            BX      LR          
			ENDP                        ;End of this procedure
                
            
            EXPORT in_word
in_word     PROC
            ; in_word(addr) -> return in R0
            ; R0 = addr
            LDR     R0, [R0]             ;R0 has the content that was previously in R0 address
            BX      LR
            ENDP
                
            END                         ;End of the assembler file
                