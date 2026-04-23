; gpio.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; 19/03/2018
; Adaptado para o LAB 1 com displays, LEDs e interrupcao em Port J

; -------------------------------------------------------------------------------
        THUMB

; -------------------------------------------------------------------------------
; Declaracoes EQU - Defines
; ========================
; Definicoes dos Registradores Gerais
SYSCTL_RCGCGPIO_R      EQU    0x400FE608
SYSCTL_PRGPIO_R        EQU    0x400FEA08

NVIC_EN1_R             EQU    0xE000E104
NVIC_EN1_GPIOJ         EQU    0x00080000

; ========================
; Definicoes dos Ports
; PORT J
GPIO_PORTJ_AHB_AMSEL_R EQU    0x40060528
GPIO_PORTJ_AHB_PCTL_R  EQU    0x4006052C
GPIO_PORTJ_AHB_DIR_R   EQU    0x40060400
GPIO_PORTJ_AHB_IS_R    EQU    0x40060404
GPIO_PORTJ_AHB_IBE_R   EQU    0x40060408
GPIO_PORTJ_AHB_IEV_R   EQU    0x4006040C
GPIO_PORTJ_AHB_IM_R    EQU    0x40060410
GPIO_PORTJ_AHB_MIS_R   EQU    0x40060418
GPIO_PORTJ_AHB_ICR_R   EQU    0x4006041C
GPIO_PORTJ_AHB_AFSEL_R EQU    0x40060420
GPIO_PORTJ_AHB_DEN_R   EQU    0x4006051C
GPIO_PORTJ_AHB_PUR_R   EQU    0x40060510
GPIO_PORTJ_AHB_DATA_R  EQU    0x400603FC
GPIO_PORTJ             EQU    2_0000000100000000

; PORT F
GPIO_PORTF_AHB_AMSEL_R EQU    0x4005D528
GPIO_PORTF_AHB_PCTL_R  EQU    0x4005D52C
GPIO_PORTF_AHB_DIR_R   EQU    0x4005D400
GPIO_PORTF_AHB_AFSEL_R EQU    0x4005D420
GPIO_PORTF_AHB_DEN_R   EQU    0x4005D51C
GPIO_PORTF_AHB_DATA_R  EQU    0x4005D3FC
GPIO_PORTF             EQU    2_0000000000100000

; PORT A
GPIO_PORTA_AHB_AMSEL_R EQU    0x40058528
GPIO_PORTA_AHB_PCTL_R  EQU    0x4005852C
GPIO_PORTA_AHB_DIR_R   EQU    0x40058400
GPIO_PORTA_AHB_AFSEL_R EQU    0x40058420
GPIO_PORTA_AHB_DEN_R   EQU    0x4005851C
GPIO_PORTA_AHB_DATA_R  EQU    0x400583FC
GPIO_PORTA             EQU    2_0000000000000001

; PORT Q
GPIO_PORTQ_AHB_AMSEL_R EQU    0x40066528
GPIO_PORTQ_AHB_PCTL_R  EQU    0x4006652C
GPIO_PORTQ_AHB_DIR_R   EQU    0x40066400
GPIO_PORTQ_AHB_AFSEL_R EQU    0x40066420
GPIO_PORTQ_AHB_DEN_R   EQU    0x4006651C
GPIO_PORTQ_AHB_DATA_R  EQU    0x400663FC
GPIO_PORTQ             EQU    2_0100000000000000

; PORT B
GPIO_PORTB_AHB_AMSEL_R EQU    0x40059528
GPIO_PORTB_AHB_PCTL_R  EQU    0x4005952C
GPIO_PORTB_AHB_DIR_R   EQU    0x40059400
GPIO_PORTB_AHB_AFSEL_R EQU    0x40059420
GPIO_PORTB_AHB_DEN_R   EQU    0x4005951C
GPIO_PORTB_AHB_DATA_R  EQU    0x400593FC
GPIO_PORTB             EQU    2_0000000000000010

; PORT P
GPIO_PORTP_AHB_AMSEL_R EQU    0x40065528
GPIO_PORTP_AHB_PCTL_R  EQU    0x4006552C
GPIO_PORTP_AHB_DIR_R   EQU    0x40065400
GPIO_PORTP_AHB_AFSEL_R EQU    0x40065420
GPIO_PORTP_AHB_DEN_R   EQU    0x4006551C
GPIO_PORTP_AHB_DATA_R  EQU    0x400653FC
GPIO_PORTP             EQU    2_0010000000000000

; -------------------------------------------------------------------------------
; Area de Codigo
        AREA    |.text|, CODE, READONLY, ALIGN=2

        EXPORT  GPIO_Init
        EXPORT  PortF_Output
        EXPORT  PortJ_Input
        EXPORT  PortA_Output
        EXPORT  PortQ_Output
        EXPORT  PortB_Output
        EXPORT  PortP_Output
        EXPORT  Delay_1ms
        EXPORT  GPIOPortJ_Handler

        IMPORT  Setpoint

;--------------------------------------------------------------------------------
; Funcao GPIO_Init
; Parametro de entrada: Nao tem
; Parametro de saida: Nao tem
GPIO_Init
;=====================
; 1. Ativar o clock para a porta setando o bit correspondente no registrador RCGCGPIO,
; apos isso verificar no PRGPIO se a porta esta pronta para uso.
            LDR     R0, =SYSCTL_RCGCGPIO_R
            MOV     R1, #GPIO_PORTF
            ORR     R1, R1, #GPIO_PORTJ
            ORR     R1, R1, #GPIO_PORTA
            ORR     R1, R1, #GPIO_PORTQ
            ORR     R1, R1, #GPIO_PORTB
            ORR     R1, R1, #GPIO_PORTP
            STR     R1, [R0]

            LDR     R0, =SYSCTL_PRGPIO_R
EsperaGPIO  LDR     R1, [R0]
            MOV     R2, #GPIO_PORTF
            ORR     R2, R2, #GPIO_PORTJ
            ORR     R2, R2, #GPIO_PORTA
            ORR     R2, R2, #GPIO_PORTQ
            ORR     R2, R2, #GPIO_PORTB
            ORR     R2, R2, #GPIO_PORTP
            TST     R1, R2
            BEQ     EsperaGPIO

; 2. Limpar o AMSEL para desabilitar a analogica
            MOV     R1, #0x00
            LDR     R0, =GPIO_PORTJ_AHB_AMSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTF_AHB_AMSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTA_AHB_AMSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTQ_AHB_AMSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTB_AHB_AMSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTP_AHB_AMSEL_R
            STR     R1, [R0]

; 3. Limpar o PCTL para selecionar GPIO
            MOV     R1, #0x00
            LDR     R0, =GPIO_PORTJ_AHB_PCTL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTF_AHB_PCTL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTA_AHB_PCTL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTQ_AHB_PCTL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTB_AHB_PCTL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTP_AHB_PCTL_R
            STR     R1, [R0]

; 4. DIR para 0 se for entrada, 1 se for saida
            LDR     R0, =GPIO_PORTF_AHB_DIR_R
            MOV     R1, #2_00010001
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTJ_AHB_DIR_R
            MOV     R1, #0x00
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTA_AHB_DIR_R
            MOV     R1, #2_11110000
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTQ_AHB_DIR_R
            MOV     R1, #2_00001111
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTB_AHB_DIR_R
            MOV     R1, #2_00110000
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTP_AHB_DIR_R
            MOV     R1, #2_00100000
            STR     R1, [R0]

; 5. Limpar os bits AFSEL para selecionar GPIO
            MOV     R1, #0x00
            LDR     R0, =GPIO_PORTF_AHB_AFSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTJ_AHB_AFSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTA_AHB_AFSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTQ_AHB_AFSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTB_AHB_AFSEL_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTP_AHB_AFSEL_R
            STR     R1, [R0]

; 6. Setar os bits de DEN para habilitar I/O digital
            LDR     R0, =GPIO_PORTF_AHB_DEN_R
            MOV     R1, #2_00010001
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTJ_AHB_DEN_R
            MOV     R1, #2_00000011
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTA_AHB_DEN_R
            MOV     R1, #2_11110000
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTQ_AHB_DEN_R
            MOV     R1, #2_00001111
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTB_AHB_DEN_R
            MOV     R1, #2_00110000
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTP_AHB_DEN_R
            MOV     R1, #2_00100000
            STR     R1, [R0]

; 7. Habilitar resistor de pull-up interno nos botoes
            LDR     R0, =GPIO_PORTJ_AHB_PUR_R
            MOV     R1, #2_00000011
            STR     R1, [R0]

; 8. Configurar interrupcao do Port J em borda de descida
            MOV     R1, #0x00
            LDR     R0, =GPIO_PORTJ_AHB_IS_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTJ_AHB_IBE_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTJ_AHB_IEV_R
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTJ_AHB_ICR_R
            MOV     R1, #2_00000011
            STR     R1, [R0]

            LDR     R0, =GPIO_PORTJ_AHB_IM_R
            MOV     R1, #2_00000011
            STR     R1, [R0]

            LDR     R0, =NVIC_EN1_R
            LDR     R1, [R0]
            ORR     R1, R1, #NVIC_EN1_GPIOJ
            STR     R1, [R0]

; 9. Inicializar as saidas desligadas
            MOV     R1, #0x00
            LDR     R0, =GPIO_PORTF_AHB_DATA_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTA_AHB_DATA_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTQ_AHB_DATA_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTB_AHB_DATA_R
            STR     R1, [R0]
            LDR     R0, =GPIO_PORTP_AHB_DATA_R
            STR     R1, [R0]

            BX      LR

; -------------------------------------------------------------------------------
; Funcao PortF_Output
; Parametro de entrada: R0 --> valor para PF4 e PF0
; Parametro de saida: Nao tem
PortF_Output
        LDR     R1, =GPIO_PORTF_AHB_DATA_R
        LDR     R2, [R1]
        BIC     R2, R2, #2_00010001
        ORR     R0, R0, R2
        STR     R0, [R1]
        BX      LR

; -------------------------------------------------------------------------------
; Funcao PortJ_Input
; Parametro de entrada: Nao tem
; Parametro de saida: R0 --> o valor da leitura
PortJ_Input
        LDR     R1, =GPIO_PORTJ_AHB_DATA_R
        LDR     R0, [R1]
        BX      LR

; -------------------------------------------------------------------------------
; Funcao PortA_Output
; Parametro de entrada: R0 --> valor para os pinos PA7 a PA4
; Parametro de saida: Nao tem
PortA_Output
        LDR     R1, =GPIO_PORTA_AHB_DATA_R
        LDR     R2, [R1]
        BIC     R2, R2, #2_11110000
        ORR     R0, R0, R2
        STR     R0, [R1]
        BX      LR

; -------------------------------------------------------------------------------
; Funcao PortQ_Output
; Parametro de entrada: R0 --> valor para os pinos PQ3 a PQ0
; Parametro de saida: Nao tem
PortQ_Output
        LDR     R1, =GPIO_PORTQ_AHB_DATA_R
        LDR     R2, [R1]
        BIC     R2, R2, #2_00001111
        ORR     R0, R0, R2
        STR     R0, [R1]
        BX      LR

; -------------------------------------------------------------------------------
; Funcao PortB_Output
; Parametro de entrada: R0 --> valor para PB5 e PB4
; Parametro de saida: Nao tem
PortB_Output
        LDR     R1, =GPIO_PORTB_AHB_DATA_R
        STR     R0, [R1]
        BX      LR

; -------------------------------------------------------------------------------
; Funcao PortP_Output
; Parametro de entrada: R0 --> valor para PP5
; Parametro de saida: Nao tem
PortP_Output
        LDR     R1, =GPIO_PORTP_AHB_DATA_R
        STR     R0, [R1]
        BX      LR

; -------------------------------------------------------------------------------
; Funcao de Atraso de 1 milissegundo
Delay_1ms
        LDR     R0, =5400
Laco_Delay
        SUBS    R0, R0, #1
        BNE     Laco_Delay
        BX      LR

; -------------------------------------------------------------------------------
; Rotina de tratamento de interrupcao do GPIO Port J
; PJ0 incrementa o setpoint e PJ1 decrementa o setpoint
GPIOPortJ_Handler
        PUSH    {R0-R3, LR}

        LDR     R0, =GPIO_PORTJ_AHB_MIS_R
        LDR     R1, [R0]
        ANDS    R1, R1, #2_00000011
        BEQ     Fim_Handler_J

        TST     R1, #2_00000001
        BEQ     Verifica_SW2

        LDR     R0, =Setpoint
        LDRB    R2, [R0]
        CMP     R2, #99
        BHS     Verifica_SW2
        ADDS    R2, R2, #1
        STRB    R2, [R0]

Verifica_SW2
        TST     R1, #2_00000010
        BEQ     Limpa_Interrupcao_J

        LDR     R0, =Setpoint
        LDRB    R2, [R0]
        CMP     R2, #10
        BLS     Limpa_Interrupcao_J
        SUBS    R2, R2, #1
        STRB    R2, [R0]

Limpa_Interrupcao_J
        LDR     R0, =GPIO_PORTJ_AHB_ICR_R
        STR     R1, [R0]

Fim_Handler_J
        POP     {R0-R3, LR}
        BX      LR

        ALIGN
        END
