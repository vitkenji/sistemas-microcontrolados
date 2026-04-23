; main.s
; Controle simples de nivel de tanque com displays, LEDs e interrupcao

        THUMB

TEMPO_500MS    EQU     83

; -------------------------------------------------------------------------------
; Area de Dados - Declaracoes de variaveis
        AREA    MAIN_DATA, DATA, READWRITE, ALIGN=2

NivelAtual      SPACE   1
        EXPORT  Setpoint [DATA,SIZE=1]
Setpoint        SPACE   1
ContadorTempo   SPACE   1

; -------------------------------------------------------------------------------
; Area de Codigo
        AREA    |.text|, CODE, READONLY, ALIGN=2

        EXPORT  Start

        IMPORT  GPIO_Init
        IMPORT  Display_Init
        IMPORT  Display_SetDigit
        IMPORT  Display_SetLeds
        IMPORT  Display_Refresh
        IMPORT  PortN_Output

Start
        BL      GPIO_Init
        BL      Display_Init

        ; Inicializa as variaveis do sistema
        LDR     R0, =NivelAtual
        MOV     R1, #10
        STRB    R1, [R0]

        LDR     R0, =Setpoint
        MOV     R1, #50
        STRB    R1, [R0]

        LDR     R0, =ContadorTempo
        MOV     R1, #TEMPO_500MS
        STRB    R1, [R0]

MainLoop
        BL      AtualizaDisplayNivel
        BL      AtualizaDisplaySetpoint
        BL      AtualizaLedEK
        BL      Display_Refresh

        ; Usa o refresh como base para aproximar 0,5 segundo
        LDR     R0, =ContadorTempo
        LDRB    R1, [R0]
        SUBS    R1, R1, #1
        BNE     SalvaContador

        MOV     R1, #TEMPO_500MS
        STRB    R1, [R0]
        BL      AjustaNivelAtual
        B       MainLoop

SalvaContador
        STRB    R1, [R0]
        B       MainLoop

; -------------------------------------------------------------------------------
; Rotina AtualizaDisplayNivel
; Converte o nivel atual em dezena e unidade e grava nos displays
AtualizaDisplayNivel
        PUSH    {R4-R7, LR}

        LDR     R4, =NivelAtual
        LDRB    R5, [R4]
        MOV     R6, #10
        UDIV    R7, R5, R6                  ; R7 = dezena
        MLS     R6, R7, R6, R5              ; R6 = unidade

        MOV     R0, #2                      ; Slot 2 = DS1 = dezena
        MOV     R1, R7
        BL      Display_SetDigit

        MOV     R0, #1                      ; Slot 1 = DS2 = unidade
        MOV     R1, R6
        BL      Display_SetDigit

        POP     {R4-R7, LR}
        BX      LR

; -------------------------------------------------------------------------------
; Rotina AtualizaDisplaySetpoint
; Envia o setpoint em binario para os LEDs da PAT
AtualizaDisplaySetpoint
        PUSH    {LR}

        LDR     R1, =Setpoint
        LDRB    R0, [R1]
        BL      Display_SetLeds

        POP     {LR}
        BX      LR

; -------------------------------------------------------------------------------
; Rotina AtualizaLedEK
; Atualiza PN1 e PN0 de acordo com o estado do sistema
AtualizaLedEK
        PUSH    {R4-R5, LR}

        LDR     R4, =NivelAtual
        LDRB    R4, [R4]
        LDR     R5, =Setpoint
        LDRB    R5, [R5]

        CMP     R4, R5
        BEQ     EstadoEstavel
        BLO     EstadoEnchendo

EstadoEsvaziando
        MOV     R0, #2_00000010             ; PN1
        BL      PortN_Output
        POP     {R4-R5, LR}
        BX      LR

EstadoEnchendo
        MOV     R0, #2_00000001             ; PN0
        BL      PortN_Output
        POP     {R4-R5, LR}
        BX      LR

EstadoEstavel
        MOV     R0, #2_00000011             ; PN1 e PN0
        BL      PortN_Output
        POP     {R4-R5, LR}
        BX      LR

; -------------------------------------------------------------------------------
; Rotina AjustaNivelAtual
; Move o nivel atual em 1 unidade na direcao do setpoint
AjustaNivelAtual
        PUSH    {R4-R5, LR}

        LDR     R4, =NivelAtual
        LDRB    R0, [R4]
        LDR     R5, =Setpoint
        LDRB    R1, [R5]

        CMP     R0, R1
        BEQ     AjustaNivelFim
        BLO     IncrementaNivel

        SUBS    R0, R0, #1
        STRB    R0, [R4]
        B       AjustaNivelFim

IncrementaNivel
        ADDS    R0, R0, #1
        STRB    R0, [R4]

AjustaNivelFim
        POP     {R4-R5, LR}
        BX      LR

        END
