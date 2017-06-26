    .global _start           @ ligador precisa do símbolo _start
    .text

@ flag para habilitar/desabilitar interrupções externas no registrador de status
    .equ IRQ, 0x80
    .equ FIQ, 0x40

@ modos de execução no registrador de status (com interrupções desabilitadas)
    .equ FIQ_MODE, 0x11+FIQ+IRQ
    .equ IRQ_MODE, 0x12+FIQ+IRQ
    .equ USER_MODE, 0x10

@ endereços dos dispositivos
    .equ TECD, 0x90000       @Dados do teclado
    .equ TECE, 0x91000       @Estado do teclado
    .equ SEG1, 0x92000       @Display 1 de 7 segmentos
    .equ SEG2, 0x93000       @Display 2 de 7 segmentos
    .equ BUT,  0x94000       @Estado do botão
    .equ TEMP, 0x95000
    .equ LED,  0x96000       @Saida dos leds
    .equ SLID, 0x97000       @Slider de velocidade

@ vetor de interrupções
    .org 0x6*0x4
    b timer                  @Interrupção IRQ para o timer
    .org   0x7*0x4
    ldr r9, =SLID            @Carrega o valor do slider
    ldr r9, [r9]
    ldr r8, =velocidade      @Salva o valor do slider na variavel velocidade
    str r9, [r8]

    ldr r9, =BUT             @Carrega o estado do botão
    ldr r9, [r9]
    ldr r8, =button_val      @Salva isso na variavel button_val
    str r9, [r8]

    ldr r10, =input_flag     @Carrega a variavel input_flag
    ldr r9, [r10]
    cmp r9, #1               @Caso a flag indique que o teclado pode receber entrada
    ldreq r8, =teclado_val
    moveq r10, #TECD         @Le a entrada do teclado
    ldreq r9, [r10]          @E salva o valor na variavel teclado_val
    streq r9, [r8]

    movs pc, lr

    .org 0x800
@Alocação de todas as variaveis
    .data
teclado_val:
    .word -1
button_val:
    .word 0
input_flag:
    .word 0
fase:
    .word 1
tempo:
    .word 0
velocidade:
    .word 1

    .bss
vetor_random:
    .space 12*4

    .text
@Atualiza o tempo a partir da interrupção do timer
timer:
    push {r0, r1}            @Preserva os valores dos registradores usados
    ldr r1, =tempo
    ldr r0, [r1]             @Incrementa o valor do tempo
    add r0, #1
    str r0, [r1]             @E salva de volta na variavel
    pop {r0, r1}             @Retorna o valor dos registradores
    movs pc, lr

@Espera r1 segundos e retorna
wait:
    push {r0, r7}
    ldr r7, =tempo
    mov r0, #0
    str r0, [r7]
wait_loop:
    ldr r0, [r7]
    cmp r0, r1
    blt wait_loop

    pop {r0, r7}
    mov pc, lr

@Inicio do programa
_start:
    mov sp, #0x400           @Seta a pilha do modo supervisor

    mov r0, #IRQ_MODE        @Coloca o processador no modo IRQ
    msr cpsr, r0
    mov sp, #0x200           @Seta a pilha do modo IRQ

    mov r0, #USER_MODE       @Coloca processador no modo usuário
    bic r0, r0, #(IRQ)       @Habilita interrupcoes IRQ
    bic r0, r0, #(FIQ)       @e interrupcoes FIQ

    msr cpsr, r0
    mov sp, #0x80000         @Seta pilha do usuário

@Loop enquanto o programa esta desligado
desligado:
    ldr r2, =button_val
    ldr r1, [r2]
    cmp r1, #0
    beq desligado

    ldr r9, =velocidade      @Atualiza a velocidade do jogo
    ldr r9, [r9]
    mov r12, #110            @Calcula o tempo de resposta a partir da velocidade
    mov r2, #10
    mul r9, r2
    sub r12, r9
    ldr r1, =fase            @Multiplica o valor calculado pela fase
    ldr r1, [r1]
    mul r9, r12, r1          @r9 guarda o tempo de resposta dessa rodada

@Gerador dos numeros aleatorios
    ldr r1, =TEMP            @Inicializa o temporizador
    mov r0, #90
    str r0, [r1]
    ldr r6, =fase            @Carrega a fase atual
    ldr r6, [r6]
random:
    sub r6, #1               @Usa a fase como um contador de quantos numeros gerar
    bl getRandom             @Gera um numero aleatorio
    bl to7seg                @Converte o numero hexa num numero "decimal"

    ldr r1, =vetor_random    @Salva o numero gerado num vetor
    str r0, [r1, r6, lsl #2]

    mov r1, #0               @Seta r1=0 para mostrar o numero gerado em r0 no display
    bl display

    mov r1, #30              @Calcula o tempo que o numero deve ficar no display
    ldr r7, =velocidade
    ldr r7, [r7]
    lsl r7, #1
    sub r1, r7
    bl wait                  @E espera esse tempo

    mov r1, #-2              @Seta r1=-2 para apagar o display
    bl display

    mov r1, #20              @Calcula o tempo desligado do display
    sub r1, r7
    bl wait                  @Espera esse tempo

    cmp r6, #0               @Caso precise gerar mais numeros
    bne random               @Volta e gera mais numeros

@Loops principais de entrada
    ldr r6, =fase            @Carrega em r6 a fase atual como contador de entradas
    ldr r6, [r6]
    mov r0, #4               @Liga o led verde para indicar o inicio do jogo
    ldr r3, =LED
    str r0, [r3]
loops:
    ldr r7, =input_flag      @Indica para o teclado para receber entradas
    mov r0, #1
    str r0, [r7]
    ldr r2, =teclado_val     @Carrega em r2 o endereço de leitura do valor do teclado
    mov r1, #-1              @E tambem reseta ele
    str r1, [r2]
    ldr r3, =tempo           @Reseta o tempo atual
    mov r0, #0
    str r0, [r3]
loop1:
    bl doLoop                @Recebe o primeiro digito
    beq loop1

    lsl r1, #4               @Move o valor lido para a casa mais significativa
    mov r0, r1
    mov r1, #-1              @r1=-1 indica para o display mostrar só a casa mais significativa
    bl display               @Mostra o numero entrado no display

    mov r1, #-1              @Reseta o valor lido no teclado
    str r1, [r2]
loop2:
    bl doLoop                @Recebe o segundo digito
    beq loop2

    ldr r3, =input_flag      @Impede o teclado de receber mais entrada
    mov r4, #0
    str r4, [r3]

    add r0, r1               @Junto os dois digitos lidos
    mov r1, #0               @r1=0 indica pro display mostrar tudo
    bl display

    mov r1, #-1              @Reseta o valor lido no teclado
    str r1, [r2]

    mov r1, #5               @Deixa o numero digitado na tela um pouco
    bl wait
    mov r1, #-2              @Reseta o display
    bl display

    sub r6, #1               @Conta um numero lido
    ldr r5, =vetor_random    @Carrega o numero que deveria ter sido digitado
    ldr r3, [r5, r6, lsl #2]

    cmp r0, r3               @Compara com o numero digitado
    movne r6, #-1            @Indica necessidade de reset caso enteja errado
    movne r4, #0xaa          @Mostra EE no display
    blne blink

    cmp r6, #0               @Caso tenha chego em r6=0 sem causar r6=-1, entao todos os numeros estavam corretos
    ldreq r3, =fase          @Incrementa a fase
    ldreq r4, [r3]
    addeq r4, #1
    streq r4, [r3]
    moveq r4, #0xbb          @Mostra CC no display
    bleq blink
    moveq r6, #-1            @Ativa o reset
reset:
    cmp r6, #-1              @Reseta se r6=-1
    ldreq r3, =button_val    @Reseta o botao de ligar o jogo
    moveq r4, #0
    streq r4, [r3]
    ldreq r3, =tempo         @Reseta o tempo para 0
    moveq r0, #0
    streq r0, [r3]
    ldreq r1, =TEMP          @Desliga o temporizador
    streq r0, [r1]
    ldreq r1, =LED           @Desliga os leds
    streq r0, [r1]
    beq desligado            @Desliga o jogo

    b loops                  @Continua lendo numeros caso não tenha resetado

@Realiza a entrada de digitos do jogo
doLoop:
    ldr r4, [r3]             @Atualiza o tempo atual
    cmp r4, r9               @Testa se o tempo acabou
    moveq r4, #0xaa          @Pisca EE no display
    bleq blink
    moveq r6, #-1            @r6=-1 indica necessidade de reset do jogo
    beq reset                @Reseta o jogo

    ldr r7, =LED             @Atualiza o estado do LED
    lsr r5, r9, #1           @Compara o tempo atual com metade do tempo de resposta
    cmp r5, r4
    moveq r5, #2             @Acende o led amarelo caso tenha chego na metade
    streq r5, [r7]
    lsr r5, r9, #2           @Compara o tempo atual com um quarto do tempo de resposta
    sub r4, r9, r4
    cmp r5, r4
    moveq r5, #1             @Acende o led vermelho caso esteja em 3/4 do tempo
    streq r5, [r7]

    ldr r1, [r2]             @Testa se o teclado leu algum valor
    cmp r1, #-1
    mov pc, lr

@Pisca o display com EE ou CC
blink:
    push {r0, r3, lr}        @Preserva o valor dos registradores
    mov r3, #0               @r3 é um contador de vezes piscadas
    cmp r4, #0xaa            @Caso pisque EE
    moveq r5, #3             @Somente 3 vezes
    movne r5, #5             @Caso nao, pisca 5 vezes
blink_loop:
    mov r1, #0               @Mostra r4 no display
    mov r0, r4
    bl display

    mov r1, #5               @Espera um tempo
    bl wait

    mov r1, #-2              @Apaga o display
    bl display

    mov r1, #5               @Espera de novo
    bl wait

    add r3, #1               @Conta uma piscada e testa se precisa piscar mais
    cmp r3, r5
    blt blink_loop

    pop {r0, r3, lr}         @Retorna os valores dos registradores
    mov pc, lr

@Converte hex em "decimal" entendivel pelo display
to7seg:
    mov r1, #0               @Contador de dezenas
to7seg_loop:
    cmp r0, #0xa             @Se r0 não tiver mais dezenas, retorna
    blt to7seg_end
    sub r0, #0xa             @Se tiver, subtrai ela e soma a r1
    add r1, #1
    b to7seg_loop
to7seg_end:
    lsl r1, #4               @Junta as dezenas com as unidades
    add r0, r1
    mov pc, lr

    .data
@Vetor com os segmentos necessarios para mostrar cada numero/letra
vetor_7seg:
    .byte 0x7e,0x30,0x6d,0x79,0x33,0x5b,0x5f,0x70,0x7f,0x7b,0x4f,0x4e

    .text
@Mostra um ou dois digitos no display, ou o apaga
display:
    push {r3, r4, r5}        @Preserva alguns registradores
    mov r5, r0               @Copia a entrada para r5
    cmp r1, #-2              @Testa se r1=-2 para apagar o display
    moveq r4, #0
    ldreq r3, =SEG1
    streq r4, [r3]
    ldreq r3, =SEG2
    streq r4, [r3]
    beq end_display

    cmp r1, #-1              @Testa se r1=-1 para mostrar so o digito a esquerda

    mov r4, #0xF             @Mascara para separar os dois digitos
    mov r1, r5               @r1 possui o digito menos significativo
    and r1, r4
    lsr r5, #4               @r5 possui o digito mais significativo

    ldrne r4, =vetor_7seg    @Caso devesse mostrar os dois digitos
    ldrne r1, [r4, r1]       @carrega o menos significativo do vetor
    moveq r1, #0             @Caso contrario apaga o digito
    ldr r4, =SEG2            @Carrega o numero no display
    str r1, [r4]

    ldr r4, =vetor_7seg      @Carrega o digito mais significativo do vetor
    ldr r1, [r4, r5]
    ldr r4, =SEG1            @Mostra no display
    str r1, [r4]
end_display:
    pop {r3, r4, r5}         @Recupera os registradores usados
    movs pc, lr
