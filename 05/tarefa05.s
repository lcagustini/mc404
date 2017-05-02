.org 0x10*0x4
.word int_teclado
.org 0x1000

contador:
    .skip 1
intervalo:
    .word 0x400000
vetor_7seg:
    .byte 0x7e,0x30,0x6d,0x79,0x33,0x5b,0x5f,0x70,0x7f,0x7b,0x4f,0x4f

int_teclado:
    push r0
    inb r0, 0x80
    stb contador, r0
    pop r0
    iret

init:
    set sp, ini_pilha      @Inicializa a pilha
    sti
    set r0, 0xf
    stb contador, r0
    set r0, 0x0
    call mostra
read:
    ldb r0, contador
    cmp r0, 0xf
    jz read
    call decrementa
reset:
    set r0, 0xf
    stb contador, r0
    jmp read

mostra:
    push r0
    push r1
    set r1, vetor_7seg
    add r1, r0
    ldb r0, [r1]
    outb 0x20, r0
    pop r1
    pop r0
    ret

decrementa:
    cmp r0, 0x0
    jz dec_end
    call mostra
dec_init:
    ld r1, intervalo
    cmp r0, 0x0
    jle dec_end
dec_loop:
    sub r1, 0x1
    jnz dec_loop

    sub r0, 0x1
    call mostra
    jmp dec_init
dec_end:
    ret

fim_pilha:
    .skip 0x300            @Reserva espaço para a pilha
ini_pilha:
