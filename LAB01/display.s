; display.s
; Driver simples para multiplexacao da PAT DAELN

        THUMB

        AREA    DISPLAY_DATA, DATA, READWRITE, ALIGN=2

Display_Leds            SPACE   1   ; valor binario bruto para os LEDs da PAT
Display_Unidade         SPACE   1   ; digito bruto do display de unidade
Display_Dezena          SPACE   1   ; digito bruto do display de dezena

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
        MOV     R1, #0
        LDR     R0, =Display_Leds
        STRB    R1, [R0]
        MOV     R1, #0xFF
        LDR     R0, =Display_Unidade
        STRB    R1, [R0]
        LDR     R0, =Display_Dezena
        STRB    R1, [R0]
        BX      LR

; R0 = posicao (1 = DS2 unidade, 2 = DS1 dezena)
; R1 = digito (0 a 9)
; Grava o digito bruto na variavel do display escolhido
Display_SetDigit
        PUSH    {R4, LR}

        CMP     R0, #1
        BLO     Display_SetDigit_End
        CMP     R0, #2
        BHI     Display_SetDigit_End
        CMP     R1, #9
        BHI     Display_SetDigit_End

        CMP     R0, #1
        BEQ     Salva_Unidade

Salva_Dezena
        LDR     R4, =Display_Dezena
        STRB    R1, [R4]
        B       Display_SetDigit_End

Salva_Unidade
        LDR     R4, =Display_Unidade
        STRB    R1, [R4]

Display_SetDigit_End
        POP     {R4, LR}
        BX      LR

; R0 = valor do setpoint em binario para os LEDs da PAT
Display_SetLeds
        PUSH    {R1, LR}

        LDR     R1, =Display_Leds
        STRB    R0, [R1]

        POP     {R1, LR}
        BX      LR

; R0 = digito (0 a 9, outros valores apagam o display)
; Retorna:
;   R0 = bits para Port A
;   R1 = bits para Port Q
Display_EncodeDigit
        CMP     R0, #9
        BHI     Digito_Vazio
        CMP     R0, #0
        BEQ     Digito_0
        CMP     R0, #1
        BEQ     Digito_1
        CMP     R0, #2
        BEQ     Digito_2
        CMP     R0, #3
        BEQ     Digito_3
        CMP     R0, #4
        BEQ     Digito_4
        CMP     R0, #5
        BEQ     Digito_5
        CMP     R0, #6
        BEQ     Digito_6
        CMP     R0, #7
        BEQ     Digito_7
        CMP     R0, #8
        BEQ     Digito_8

Digito_9
        MOV     R0, #2_01100000
        MOV     R1, #2_00001111
        BX      LR

Digito_0
        MOV     R0, #2_00110000
        MOV     R1, #2_00001111
        BX      LR

Digito_1
        MOV     R0, #2_00000000
        MOV     R1, #2_00000110
        BX      LR

Digito_2
        MOV     R0, #2_01010000
        MOV     R1, #2_00001011
        BX      LR

Digito_3
        MOV     R0, #2_01000000
        MOV     R1, #2_00001111
        BX      LR

Digito_4
        MOV     R0, #2_01100000
        MOV     R1, #2_00000110
        BX      LR

Digito_5
        MOV     R0, #2_01100000
        MOV     R1, #2_00001101
        BX      LR

Digito_6
        MOV     R0, #2_01110000
        MOV     R1, #2_00001101
        BX      LR

Digito_7
        MOV     R0, #2_00000000
        MOV     R1, #2_00000111
        BX      LR

Digito_8
        MOV     R0, #2_01110000
        MOV     R1, #2_00001111
        BX      LR

Digito_Vazio
        MOV     R0, #0
        MOV     R1, #0
        BX      LR

Display_Refresh
        PUSH    {R4, LR}

        ; Desliga todos os transistores antes de trocar os segmentos
        MOV     R0, #0
        BL      PortB_Output
        BL      PortP_Output

        ; Mostra a dezena no DS1 (PB4)
        LDR     R1, =Display_Dezena
        LDRB    R0, [R1]
        BL      Display_EncodeDigit
        MOV     R4, R1
        BL      PortA_Output

        MOV     R0, R4
        BL      PortQ_Output

        MOV     R0, #2_00010000
        BL      PortB_Output
        BL      Delay_1ms
        MOV     R0, #0
        BL      PortB_Output
        BL      Delay_1ms

        ; Mostra a unidade no DS2 (PB5)
        LDR     R1, =Display_Unidade
        LDRB    R0, [R1]
        BL      Display_EncodeDigit
        MOV     R4, R1
        BL      PortA_Output

        MOV     R0, R4
        BL      PortQ_Output

        MOV     R0, #2_00100000
        BL      PortB_Output
        BL      Delay_1ms
        MOV     R0, #0
        BL      PortB_Output
        BL      Delay_1ms

        ; Mostra o setpoint em binario nos LEDs da PAT (PP5)
        LDR     R1, =Display_Leds
        LDRB    R0, [R1]
        MOV     R4, R0
        AND     R0, R0, #0xF0
        BL      PortA_Output

        AND     R0, R4, #0x0F
        BL      PortQ_Output

        MOV     R0, #2_00100000
        BL      PortP_Output
        BL      Delay_1ms
        MOV     R0, #0
        BL      PortP_Output
        BL      Delay_1ms

        POP     {R4, LR}
        BX      LR

        ALIGN
        END
