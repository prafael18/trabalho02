 .global read_sonar
.global set_motors_speed
.global write_slow_turn_right
.global write_sharp_turn_right
.global write_slow_turn_left
.global write_sharp_turn_left
.global write_sonar_dist

.data
  slow_left: .asciz "Slow turn left\n"
  sharp_left: .asciz "Sharp turn left\n"
  slow_right: .asciz "Slow turn right\n"
  sharp_right: .asciz "Sharp turn right\n"
  sonar_zero: .asciz "sonar0 = "
  sonar_quinze: .asciz "sonar15 = "
  output_buffer: .skip 8

.text
.align 4

@ r0 = sonar id
@ return
@ r0 = distancia do sonar selecionado
read_sonar:
push {r7, lr}
mov r7, #125
svc 0x0
pop {r7, lr}
mov pc, lr

@r0 = endereco de um dos motores.
@r1 = endereco do outro motor.
@posso assumir que ambos os motores vao ter ids validos?
set_motors_speed:
push {r4, r5, r7, lr}
ldrb r3, [r0, #1]
ldrb r4, [r1, #1]
ldrb r2, [r0] @id do primeiro parametro
add r2, r2, #0
cmp r2, #0
bne first_param_motor
ldrb r3, [r0, #1]
ldrb r4, [r1, #1]
b call_motors_speed_handler
first_param_motor:
ldrb r3, [r1, #1]
ldrb r4, [r0, #1]
call_motors_speed_handler:
mov r0, r3
mov r1, r4
mov r7, #124
svc 0x0
pop {r4, r5, r7, lr}
mov pc, lr


@ Escreve uma sequencia de bytes na saida padrao.
@ parametros:
@  r0: endereco do buffer de memoria que contem a sequencia de bytes.
@  r1: numero de bytes a serem escritos
write_slow_turn_right:
    push {r4-r7, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    ldr r1, =slow_right      @ endereco do buffer
    mov r2, #16        @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r4-r7, lr}
    mov pc, lr

write_slow_turn_left:
    push {r4-r7, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    ldr r1, =slow_left        @ endereco do buffer
    mov r2, #15        @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r4-r7, lr}
    mov pc, lr

write_sharp_turn_right:
    push {r4-r7, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    ldr r1, =sharp_right       @ endereco do buffer
    mov r2, #17       @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r4-r7, lr}
    mov pc, lr

write_sharp_turn_left:
    push {r4-r7, lr}
    mov r4, r0
    mov r5, r1
    mov r0, #1         @ stdout file descriptor = 1
    ldr r1, =sharp_left       @ endereco do buffer
    mov r2, #16       @ tamanho do buffer.
    mov r7, #4         @ write
    svc 0x0
    pop {r4-r7, lr}
    mov pc, lr

@ r0 = sonar0 dist
write_sonar_dist:
  push {r4-r7, lr}
  mov r4, r0
  mov r5, r1
  mov r0, r4
  mov r1, #0
  ldr r2, =output_buffer
  loop_write_sonar:
  cmp r1, #3
  beq end_loop_write_sonar
  and r3, r0, #0xf
  cmp r3, #9
  bhi is_letter
  add r3, r3, #48
  b converted_char
  is_letter:
  add r3, r3, #55
  converted_char:
  mov r6, #2
  sub r6, r6, r1
  strb r3, [r2, r6]
  add r1, r1, #1
  lsr r0, #4
  b loop_write_sonar
  end_loop_write_sonar:
    mov r0, #' '
    str r0, [r2, #3]
    mov r0, r5
    mov r1, #4
    ldr r2, =output_buffer
    loop_write_sonar_2:
    cmp r1, #7
    beq end_loop_write_sonar_2
    and r3, r0, #0xf
    cmp r3, #9
    bhi is_letter_2
    add r3, r3, #48
    b converted_char_2
    is_letter_2:
    add r3, r3, #55
    converted_char_2:
    mov r6, #10
    sub r6, r6, r1
    strb r3, [r2, r6]
    add r1, r1, #1
    lsr r0, #4
    b loop_write_sonar_2
  end_loop_write_sonar_2:
  ldr r0, =output_buffer
  mov r1, #'\n'
  strb r1, [r0, #7]
  mov r0, #1         @ stdout file descriptor = 1
  ldr r1, =output_buffer       @ endereco do buffer
  mov r2, #13      @ tamanho do buffer.
  mov r7, #4         @ write
  svc 0x0
  pop {r4-r7, lr}
  mov pc, lr
