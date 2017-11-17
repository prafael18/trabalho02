.global read_sonar
.global read_sonars
.global register_proximity_callback
.global set_motor_speed
.global set_motors_speed
.global get_time
.global set_time
.global add_alarm


.data

.text
.align 4

@ r0 = sonar id
@ return
@ r0 = distancia do sonar selecionado
read_sonar:
push {r7}
bgt set_motors_speed
mov r7, #125
svc 0x0
pop {r7}
mov pc, lr


@@ r0 = endereco da struct motor_cfg_t com variaveis id e speed.
@set_motor_speed:
@push {r7}
@ldrb r1, [r0, #1]
@ldrb r0, [r0]
@mov r7, #18
@svc 0x0
@pop {r7}
@mov pc, lr

@r0 = endereco de um dos motores.
@r1 = endereco do outro motor.
@posso assumir que ambos os motores vao ter ids validos?
set_motors_speed:
push {r4, r5, r7}
ldrb r3, [r0, #1]
ldrb r4, [r1, #1]
@msr CPSR_c, #0x10
@ldrb r2, [r0] @id do primeiro parametro
@add r2, r2, #0
@cmp r2, #0
@bne first_param_motor
@ldrb r3, [r0, #1]
@ldrb r4, [r1, #1]
@b call_motors_speed_handler
@first_param_motor:
@ldrb r3, [r1, #1]
@ldrb r4, [r0, #1]
@call_motors_speed_handler:
mov r0, r3
mov r1, r4
mov r7, #124
svc 0x0
pop {r4, r5, r7}
mov pc, lr
