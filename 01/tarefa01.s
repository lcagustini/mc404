init .equ 0x1000

start:
    set r0, init  @r0 sera usado como apontador para a posiçao para qual se está copiando
    set r1, 0x20  @r1 sera usado como apontador para a posiçao sendo copiada
    add r1, r0
    set r3, 0x0   @r3 sera usado como contador de quantos caracteres foram copiados
loop:
    ldb r2, [r0]  @O primeiro caracter da sequencia e carregado em r2
    stb [r1], r2  @E entao e salvo em outra posicao de memoria mais adiante
    add r0, 0x1   @Avança os apontadores para a proxima posicao
    add r1, 0x1
    add r3, 0x1   @Incrementa o contador
    cmp r2, 0x0   @Testa se o caracter copiado e 0
    jnz loop      @Se nao for, continua copiando os caracteres

    set r0, init  @Ajusta os apontadores e contadores para iniciar a copia de volta
    add r3, 0x1
    sub r1, 0x2
invert:
    ldb r2, [r1]  @Carrega o ultimo caracter em r2
    stb [r0], r2  @Salva r2 como primeiro caracter
    sub r3, 0x1   @Atualiza os apontadores e o contador
    sub r1, 0x1
    add r0, 0x1
    cmp r3, 0x0   @Checa se ainda existem caracteres para serem copiados
    jnz invert    @Se sim, continua a copia
    hlt           @Termina o programa se tudo já tiver sido copiado
