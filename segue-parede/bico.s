  .global read_sonar
  .global read_sonars
  .global register_proximity_callback
  .global set_motor_speed
  .global set_motors_speed
  .global get_time
  .global set_time
  .global add_alarm

  .global write


.data
output_buffer: .skip 32
error_message:  .asciz "Entramos em testFunction2!\n"  @coloca a string na memoria

.text
.align 4

@ r0 = sonar id
@ return
@ r0 = distancia do sonar selecionado
read_sonar:
  push {r7}
  mov r7, #16
  svc 0x0
  pop {r7}
  mov pc, lr

@ r0 = inteiro do sensor onde comeca a leitura
@ r1 = inteiro do sensor onde termina a leitura
@ r2 = ponteiro para vetor de inteiros que deve receber as distancias
read_sonars:
  push {r4-r8}
  mov r4, r0
  mov r5, r1
  mov r6, r2
  sub r8, r5, r4 @numero de sensores que devem ser lidos
  add r8, r8, #1
  mov r9, #0
  loop_read_sonars:
    cmp r9, r8
    beq end_read_sonars
    add r0, r4, r9
    mov r7, #16
    svc 0x0
    mov r1, r9, lsl #2
    str r0, [r6, r1]
    add r9, r9, #1
    b loop_read_sonars
  end_read_sonars:
  pop {r4-r8}
  mov pc, lr

@r0 = sensor_id que deve ser monitorado
@ r1 = distancia limite onde deve-se chamar a funcao
@ r2 = endereco da funcao que deve ser chamada quando alcanca o threshold
register_proximity_callback:
  push {r7}
  mov r7, #17
  svc 0x0
  pop {r7}
  mov pc, lr

@ r0 = endereco da struct motor_cfg_t com variaveis id e speed.
set_motor_speed:
  push {r7}
  ldrb r1, [r0, #1]
  ldrb r0, [r0]
  mov r7, #18
  svc 0x0
  pop {r7}
  mov pc, lr

 @r0 = endereco de um dos motores.
 @r1 = endereco do outro motor.
 @posso assumir que ambos os motores vao ter ids validos?
set_motors_speed:
  push {r4, r5, r7}
  ldrb r2, [r0] @id do primeiro parametro
  cmp r2, #0
  bne first_param_motor1
  ldrb r3, [r0, #1]
  ldrb r4, [r1, #1]
  b call_motors_speed_handler
  first_param_motor1:
  ldrb r3, [r1, #1]
  ldrb r4, [r0, #1]
  call_motors_speed_handler:
  mov r0, r3
  mov r1, r4
  mov r7, #19
  svc 0x0
  pop {r4, r7}
  mov pc, lr

@ r0 = endereco da variavel que deve armazenar o tempo
@ r1 = valor da variavel tempo
get_time:
  push {r4, r7, lr}
  mov r4, r0    @endereco da variavel que guarda o tempo do sistema
  mov r7, #20
  svc 0x0
  str r0, [r4]
  pop {r4, r7, lr}
  mov pc, lr

@ r0 = tempo do sistema que deseja-se setar.
set_time:
  push {r7, lr}
  mov r7, #21
  svc 0x0
  pop {r7, lr}
  mov pc, lr

@E se colocarem mais de um alarme no mesmo tempo????
@ r0 = ponteiro para a funcao que deve ser chamada.
@ r1 = tempo em que a funcao deve ser chamada.
add_alarm:
  push {r7, lr}
  mov r7, #22
  svc 0x0
  pop {r7, lr}
  mov pc, lr

@ Escreve uma sequencia de bytes na saida padrao.
@ parametros:
@  r0: endereco do buffer de memoria que contem a sequencia de bytes.
@  r1: numero de bytes a serem escritos
write:
    push {r4-r7, lr}
    @mov r4, r0
    @mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    ldr r1, =error_message       @ endereco do buffer
    mov r2, #27        @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r4-r7, lr}
    mov pc, lr

@ r0 = id do motor que deseja-se verificar
@ retorno:
@ r0 = id do motor valido ou -1 caso id seja invalido
@validate_id:
@  cmp r0, #1
@  beq end_validation
@  cmp r0, #0
@  beq end_validation
@  mov r0, #-1
@  end_validation:
@  mov pc, lr
