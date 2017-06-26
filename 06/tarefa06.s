.org 0x2000

string:                    @Aloca espaço para a string de entrada
    .skip 256
size:                      @Variavel com o tamanho da string
    .skip 1

init:
    set sp, ini_pilha      @Inicializa a pilha

    set r0, 0x0            @Syscall de leitura do console
    set r1, string
    set r2, 0x256
    set r7, 0x3
    sys 0x55

    stb size, r0           @Salva o retorno da syscall

    call caps              @Capitaliza as letras da string

    set r0, 1              @Syscall de escrita no console
    set r1, string
    ldb r2, size
    set r7, 4
    sys 0x55

    set r0, 0              @Syscall exit(0)
    set r7, 1
    sys 0x55

caps:
    set r10, 0             @Inicializa o registrador com quantos chars foram alterados
    ldb r2, size           @Carrega quantos chars devem ser lidos
    set r0, string         @r0 vai ser o apontador que vai percorrer a string
    set r3, 0xDF           @Mascara que troca o bit de minuscula para maiuscula em ASCII
caps_loop:
    ldb r1, [r0]           @Carrega um char da string
    sub r1, 0x61           @Subtrai 'a' em ASCII
    jl caps_test           @Testa se o char esta abaixo de 'a'
    sub r1, 0x19           @Subtrai o que falta para 'z' em ASCII
    jg caps_test           @Testa se o char esta a cima de 'z'
    add r1, 0x7A           @Caso nao tenha desviado, o char eh uma letra minuscula
    and r1, r3             @Volta ao seu valor original e aplica a mascara
    stb [r0], r1           @Salva de volta na string
    add r10, 0x1           @Incrementa o contador de chars alterados
caps_test:
    sub r2, 0x1            @Diminui um char lido
    jz caps_end            @Testa se ainda ha chars para ler
    add r0, 0x1            @Avanca o apontador na string
    jmp caps_loop          @Volta a ler mais chars
caps_end:
    ret

fim_pilha:
    .skip 0x300            @Reserva espaço para a pilha
ini_pilha:
