init:
    set sp, ini_pilha      @Inicializa a pilha
    set r4, 0x1            @Inicia a multiplicacao com 1
    out 0x40, r4           @Imprime o 1 nos leds
mainloop:
    call read              @Le a entrada do teclado
    mov r5, r1             @Salva o @ ou # num registrador para comparacao depois

    push r4                @Coloca o valor corrente da multiplicacao na pilha
    push r0                @Coloca a nova entrada na pilha
    call multiplica        @Executa a multiplicacao dos dois
    add sp, 0x8            @Retira os parametros da multiplicacao da pilha

    mov r4, r0             @Move o resultado da multiplicacao para o registrador do valor corrente
    out 0x40, r4           @Imprime o novo valor nos leds

    cmp r5, 0xa            @Checa se o usuario digitou * ou #
    jnz end                @Termina o programa no caso de #

    jmp mainloop           @Reinicia o programa no caso de *
end:
    hlt

read:
    set r1, 0x1            @Inicia r1 com 1 (V)
    set r2, 0x0            @Inicia r2 como contador em 0
readloop:
    inb r0, 0x81           @Le a entrada de estado do teclado
    tst r0, r1             @Testa se ela eh verdadeira
    jz readloop            @Continua lendo o estado se nao for
    in r0, 0x80            @Le a entrada de dados se for
    push r0                @Coloca o dado lido na pilha
    add r2, 0x1            @Incrementa o contador
    cmp r2, 0x3            @Checa se ja leu 3 entradas
    jnz readloop           @Se nao, continua lendo

    pop r1                 @Se sim, desenpilha o * ou #
    pop r2                 @Desempilha o digito menos significativo
    pop r0                 @Desempilha o digito mais significativo
    shl r0, 0x4            @Move o digito mais significativo uma casa hexadecimal para a esquerda
    add r0, r2             @Junta os dois digitos

    ret

multiplica:
    ld r1, [sp+4]          @Recupera o primeiro parametro
    ld r2, [sp+8]          @Recupera o segundo parametro

    cmp r1, r2             @Testa qual parametro é menor e coloca ele em r2
    jnc multinit
    mov r0, r1
    mov r1, r2
    mov r2, r0
multinit:
    set r0, 0x0            @Reseta r1 com 0
    set r3, 0x1            @Inicia r3 com 1
multshift:
    tst r2, r3             @Testa se r2 eh par
    jz multeven
    add r0, r1             @Se r2 for impar, soma r1 em r0
multeven:
    cmp r2, r3             @Testa se r2 eh 1
    jle multend            @Se sim, termina a multiplicacao
    shr r2, 0x1            @Se nao, desloca r2 para a direita
    shl r1, 0x1            @E r1 para a esquerda
    jmp multshift          @Volta a somar dependendo da paridade
multend:
    ret

fim_pilha:
    .skip 0x300            @Reserva espaço para a pilha
ini_pilha:
