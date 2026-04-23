; display.s
; Driver simples para multiplexacao da PAT DAELN

        THUMB

        AREA    DISPLAY_DATA, DATA, READWRITE, ALIGN=2

Display_PortA_Buffer   SPACE   3   ; slot 0 = LEDs, slot 1 = unidade, slot 2 = dezena
Display_PortQ_Buffer   SPACE   3   ; slot 0 = LEDs, slot 1 = unidade, slot 2 = dezena

        AREA    |.text|, CODE, READONLY, ALIGN=2

        EXPORT  Display_Init
        EXPORT  Display_Clear
        EXPORT  Display_SetDigit
        EXPORT  Display_SetLeds
        EXPORT  Display_Refresh

        IMPORT  PortA_Output
        IMPORT  PortQ_Output
        IMPORT  PortB_Output
        IMPORT  PortP_Output
        IMPORT  Delay_1ms

Display_Init
        PUSH    {LR}
        BL      Display_Clear
        POP     {LR}
        BX      LR

Display_Clear
        LDR     R0, =Display_PortA_Buffer
        MOV     R1, #0
        STRB    R1, [R0]
        STRB    R1, [R0, #1]
        STRB    R1, [R0, #2]

        LDR     R0, =Display_PortQ_Buffer
        STRB    R1, [R0]
        STRB    R1, [R0, #1]
        STRB    R1, [R0, #2]
        BX      LR

; R0 = posicao (1 = DS2 unidade, 2 = DS1 dezena)
; R1 = digito (0 a 9)
; Converte o digito e grava diretamente os segmentos na RAM
Display_SetDigit
        PUSH    {R4-R6, LR}

        CMP     R0, #2
        BHI     Display_SetDigit_End
        CMP     R1, #9
        BHI     Display_SetDigit_End

        MOV     R4, R0

        CMP     R1, #0
        BEQ     Digito_0
        CMP     R1, #1
        BEQ     Digito_1
        CMP     R1, #2
        BEQ     Digito_2
        CMP     R1, #3
        BEQ     Digito_3
        CMP     R1, #4
        BEQ     Digito_4
        CMP     R1, #5
        BEQ     Digito_5
        CMP     R1, #6
        BEQ     Digito_6
        CMP     R1, #7
        BEQ     Digito_7
        CMP     R1, #8
        BEQ     Digito_8
        B       Digito_9

Digito_0
        MOV     R5, #0x30
        MOV     R6, #0x0F
        B       Salva_Digito

Digito_1
        MOV     R5, #0x00
        MOV     R6, #0x06
        B       Salva_Digito

Digito_2
        MOV     R5, #0x50
        MOV     R6, #0x0B
        B       Salva_Digito

Digito_3
        MOV     R5, #0x40
        MOV     R6, #0x0F
        B       Salva_Digito

Digito_4
        MOV     R5, #0x60
        MOV     R6, #0x06
        B       Salva_Digito

Digito_5
        MOV     R5, #0x60
        MOV     R6, #0x0D
        B       Salva_Digito

Digito_6
        MOV     R5, #0x70
        MOV     R6, #0x0D
        B       Salva_Digito

Digito_7
        MOV     R5, #0x00
        MOV     R6, #0x07
        B       Salva_Digito

Digito_8
        MOV     R5, #0x70
        MOV     R6, #0x0F
        B       Salva_Digito

Digito_9
        MOV     R5, #0x60
        MOV     R6, #0x0F

Salva_Digito
        LDR     R0, =Display_PortA_Buffer
        STRB    R5, [R0, R4]

        LDR     R0, =Display_PortQ_Buffer
        STRB    R6, [R0, R4]

Display_SetDigit_End
        POP     {R4-R6, LR}
        BX      LR

; R0 = valor do setpoint em binario para os LEDs da PAT
Display_SetLeds
        PUSH    {R1-R2, LR}

        MOV     R1, R0
        AND     R2, R1, #0xF0
        LDR     R0, =Display_PortA_Buffer
        STRB    R2, [R0]

        AND     R2, R1, #0x0F
        LDR     R0, =Display_PortQ_Buffer
        STRB    R2, [R0]

        POP     {R1-R2, LR}
        BX      LR

Display_Refresh
        PUSH    {LR}

        ; Desliga todos os transistores antes de trocar os segmentos
        MOV     R0, #0
        BL      PortB_Output
        BL      PortP_Output

        ; Mostra a dezena no DS1 (PB4)
        LDR     R1, =Display_PortA_Buffer
        LDRB    R0, [R1, #2]
        BL      PortA_Output

        LDR     R1, =Display_PortQ_Buffer
        LDRB    R0, [R1, #2]
        BL      PortQ_Output

        MOV     R0, #2_00010000
        BL      PortB_Output
        BL      Delay_1ms
        MOV     R0, #0
        BL      PortB_Output
        BL      Delay_1ms

        ; Mostra a unidade no DS2 (PB5)
        LDR     R1, =Display_PortA_Buffer
        LDRB    R0, [R1, #1]
        BL      PortA_Output

        LDR     R1, =Display_PortQ_Buffer
        LDRB    R0, [R1, #1]
        BL      PortQ_Output

        MOV     R0, #2_00100000
        BL      PortB_Output
        BL      Delay_1ms
        MOV     R0, #0
        BL      PortB_Output
        BL      Delay_1ms

        ; Mostra o setpoint em binario nos LEDs da PAT (PP5)
        LDR     R1, =Display_PortA_Buffer
        LDRB    R0, [R1]
        BL      PortA_Output

        LDR     R1, =Display_PortQ_Buffer
        LDRB    R0, [R1]
        BL      PortQ_Output

        MOV     R0, #2_00100000
        BL      PortP_Output
        BL      Delay_1ms
        MOV     R0, #0
        BL      PortP_Output
        BL      Delay_1ms

        POP     {LR}
        BX      LR

        ALIGN
        END
