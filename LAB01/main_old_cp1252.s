; main.s
; Desenvolvido para a placa EK-TM4C1294XL
; Prof. Guilherme Peron
; Rev1: 10/03/2018
; Rev2: 10/04/2019
; Este programa espera o usuário apertar a chave USR_SW1 e/ou a chave USR_SW2.
; Caso o usuário pressione a chave USR_SW1, acenderá o LED3 (PF4). Caso o usuário pressione 
; a chave USR_SW2, acenderá o LED4 (PF0). Caso as duas chaves sejam pressionadas, os dois 
; LEDs acendem.

; -------------------------------------------------------------------------------
        THUMB                        ; Instruções do tipo Thumb-2
; -------------------------------------------------------------------------------
; Declarações EQU - Defines
;<NOME>         EQU <VALOR>
; ========================


; -------------------------------------------------------------------------------
; Área de Dados - Declarações de variáveis
		AREA  DATA, ALIGN=2
		; Se alguma variável for chamada em outro arquivo
		;EXPORT  <var> [DATA,SIZE=<tam>]   ; Permite chamar a variável <var> a 
		                                   ; partir de outro arquivo
;<var>	SPACE <tam>                        ; Declara uma variável de nome <var>
                                           ; de <tam> bytes a partir da primeira 
                                           ; posição da RAM		

; -------------------------------------------------------------------------------
; Área de Código - Tudo abaixo da diretiva a seguir será armazenado na memória de 
;                  código
        AREA    |.text|, CODE, READONLY, ALIGN=2

		; Se alguma função do arquivo for chamada em outro arquivo	
        EXPORT Start                ; Permite chamar a função Start a partir de 
			                        ; outro arquivo. No caso startup.s
									
		; Se chamar alguma função externa	
        ;IMPORT <func>              ; Permite chamar dentro deste arquivo uma 
									; função <func>
        IMPORT GPIO_Init
        IMPORT PortJ_Input
        IMPORT PortA_Output
        IMPORT PortQ_Output
        IMPORT PortB_Output
        IMPORT Delay_1ms


; Tabela EXATA para a Placa PAT DAELN
Tabela_PortA DCB 0x30, 0x00, 0x50, 0x40, 0x60, 0x60, 0x70, 0x00, 0x70, 0x60
Tabela_PortQ DCB 0x0F, 0x06, 0x0B, 0x0F, 0x06, 0x0D, 0x0D, 0x07, 0x0F, 0x0F

; -------------------------------------------------------------------------------

        AREA    |.text|, CODE, READONLY, ALIGN=2
        EXPORT  Start

Start           
        BL GPIO_Init             ; Inicializa todas as portas

MainLoop
        ; ==========================================================
        ; TESTE DO DS1 (DEZENA) -> Vamos mostrar o número '8'
        ; '8' precisa de todos os segmentos ligados: PA = 0x70, PQ = 0x0F
        ; ==========================================================
        MOV R0, #0x70            
        BL PortA_Output          
        MOV R0, #0x0F            
        BL PortQ_Output          
        
        MOV R0, #2_00010000      ; Liga o pino PB4 (Ativa DS1)
        BL PortB_Output
        BL Delay_1ms             ; Espera 1ms
        MOV R0, #0               ; Apaga tudo
        BL PortB_Output
        BL Delay_1ms



        ; ==========================================================
        ; TESTE DO DS2 (UNIDADE) -> Vamos mostrar o número '2'
        ; '2' usa os segmentos a,b,d,e,g: PA = 0x50, PQ = 0x0B
        ; ==========================================================
        MOV R0, #0x50            
        BL PortA_Output          
        MOV R0, #0x0B            
        BL PortQ_Output          
        
        MOV R0, #2_00100000      ; Liga o pino PB5 (Ativa DS2)
        BL PortB_Output
        BL Delay_1ms             ; Espera 1ms
        MOV R0, #0               ; Apaga tudo
        BL PortB_Output
        BL Delay_1ms

        B MainLoop               ; Repete infinito

        END
