build:
	arm-none-eabi-as -o tarefa.o *.s
	arm-none-eabi-gcc -o random.o -c random.c
	arm-none-eabi-ld -o tarefa -Tmapa.lds tarefa.o random.o
