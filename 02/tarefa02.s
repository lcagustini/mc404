init:
    set r0, 0x0        @Inicializa o registrador da soma
    set r2, 0x108      @Inicializa o registrador com o endereco da proxima palavra do vetor
    ld r7, 0x100       @Carrega o Divisor num registrador de backup
    ld r8, 0x104       @Carrega o numero de elementos do vetor
load:
    mov r1, r7         @Copia o divisor para um registrador de trabalho
    ld r3, [r2]        @Carrega a palavra atual do vetor
    set r4, 0x0000FFFF @Inicializa a mascara
    and r4, r3         @Aplica a mascara e obtem o primeiro numero da palavra
    shr r3, 0x10       @Da shift para obter o segundo numero da palavra
divide:
    shr r4, 0x1        @Divide os numeros obtidos e o divisor por dois
    shr r3, 0x1
    shr r1, 0x1
    cmp r1, 0x1        @Caso o divisor nao seja um, continua dividindo por dois
    jnz divide
advance:
    add r2, 0x4        @Avanca para a proxima palavra do vetor

    add r0, r4         @Soma o numero dividido a soma total
    sub r8, 0x1        @Diminui a quantidade de numeros restantes para somar

    cmp r8, 0x0        @Checa se deve somar o segundo elemento da palavra
    jz back
    add r0, r3         @Faz a soma e diminui a quantidade de numeros para somar
    sub r8, 0x1
back:
    cmp r8, 0x0        @Checa se ainda existem numeros para somar
    jnz load           @Volta a somar se necessario
end:
    hlt
