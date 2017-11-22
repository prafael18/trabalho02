.org 0x0
.section .iv,"a"
_start:
interrupt_vector:
    b RESET_HANDLER
.org 0x08
    b SVC_HANDLER
.org 0x18
    b IRQ_HANDLER

.data
  CONTADOR: .skip 4
  @com um loop de 0x3000 no delay_time e 100 no TIME_SZ, contador incrementa 3 unidades
  @.set TIME_SZ, 600
  .set TIME_SZ, 100
  svc_handler_array: .skip 4*9

    CALLBACKS: .skip 4
    proximity_callback_array: .skip 4*8
    @poderia tentar usar halfword para o threshold
    proximity_threshold_array: .skip 2*8
    proximity_sonar_id_array: .skip 8

    ALARMS: .skip 4
    alarm_array: .skip 4*8
    stop_time_alarm_array: .skip 4*8

    sudo_branch_addr: .skip 4

    .skip 1024
    IRQ_STACK:
    .skip 2048
    SVC_STACK:
    .skip 4096
    USR_STACK:

.text
.align 4

RESET_HANDLER:
  @Inicializa o tempo como 0.
  ldr r0, =CONTADOR
  mov r1, #0
  str r1, [r0]

  @Faz o registrador que aponta para a tabela de interrupções apontar para a tabela interrupt_vector
  ldr r0, =interrupt_vector
  mcr p15, 0, r0, c12, c0, 0


  @Inicializa os contadores de callbacks e alarmes
  .set MAX_CALLBACKS, 8
  .set MAX_ALARMS, 8

  ldr r0, =ALARMS
  mov r1, #0
  str r1, [r0]
  ldr r0, =CALLBACKS
  str r1, [r0]

  @Inicializa vetor de ponteiros para handlers das chamadas SVC
  ldr r0, =svc_handler_array
  ldr r1, =read_sonar
  str r1, [r0]
  ldr r1, =register_proximity_callback
  str r1, [r0, #4]
  ldr r1, =set_motor_speed
  str r1, [r0, #8]
  ldr r1, =set_motors_speed
  str r1, [r0, #12]
  ldr r1, =get_time
  str r1, [r0, #16]
  ldr r1, =set_time
  str r1, [r0, #20]
  ldr r1, =set_alarm
  str r1, [r0, #24]
  ldr r1, =sudo
  str r1, [r0, #28]
  ldr r1, =toggle_usr_irq
  str r1, [r0, #32]

  @ Ajustar a pilha do modo IRQ.
  @ Você deve iniciar a pilha do modo IRQ aqui. Veja abaixo como usar a instrução MSR para chavear de modo.
  @ ...
  @instrucao msr - deshabilita interrupcoes e muda para o modo IRQ
  @Set processor mode control masks
  .set USR_MODE, 0x10
  .set IRQ_MODE, 0x12
  .set SVC_MODE, 0x13
  .set NO_INT, 0xc0   @desabilita interrupcoes
  .set NO_FIQ, 0x40   @desabilita FIQ

  @Offset for processor mode stacks
  @.set IRQ_STACK, 0x77706000 @aloca 256 byts para a pilha do modo IRQ
  @.set SVC_STACK, 0x77705e00
  @.set USR_STACK, 0x77704000

  mov r2, #NO_INT|IRQ_MODE
  msr CPSR_c, r2
  ldr sp, =IRQ_STACK

  mov r2, #NO_INT|SVC_MODE
  msr CPSR_c, r2
  ldr sp, =SVC_STACK

  mov r2, #SVC_MODE
  msr CPSR_c, r2

  @Constantes do GPT
  .set GPT_BASE, 0x53FA0000
  .set GPT_0CR1, 0x10
  .set GPT_PR, 0x4
  .set GPT_IR, 0xc
  .set GPT_SR, 0x8
  .set GPT_CTRL, 0x0

  @Configura o clock_src para perfi'erico
  ldr r0, =0x00000041
  ldr r1, =GPT_BASE
  str r0, [r1, #GPT_CTRL]

  @Zera o prescaler
  mov r0, #0
  str r0, [r1, #GPT_PR]

  @Valor que desejo contar em 0CR_1. Gera interrupcao do tipo Output Compare Channel 1
  mov r0, #TIME_SZ
  str r0, [r1, #GPT_0CR1]

  @Grava 1 no registrador GPT_IR, sinalizando que devemos escutar por interrupcoes do tipo Output Compare Channel 1
  mov r0, #1
  str r0, [r1, #GPT_IR]

  SET_TZIC:
      @ Constantes para os enderecos do TZIC
      .set TZIC_BASE,             0x0FFFC000
      .set TZIC_INTCTRL,          0x0
      .set TZIC_INTSEC1,          0x84
      .set TZIC_ENSET1,           0x104
      .set TZIC_PRIOMASK,         0xC
      .set TZIC_PRIORITY9,        0x424

      @ Liga o controlador de interrupcoes
      @ R1 <= TZIC_BASE

      ldr	r1, =TZIC_BASE

      @ Configura interrupcao 39 do GPT como nao segura
      mov	r0, #(1 << 7)
      str	r0, [r1, #TZIC_INTSEC1]

      @ Habilita interrupcao 39 (GPT)
      @ reg1 bit 7 (gpt)

      mov	r0, #(1 << 7)
      str	r0, [r1, #TZIC_ENSET1]

      @ Configure interrupt39 priority as 1
      @ reg9, byte 3

      ldr r0, [r1, #TZIC_PRIORITY9]
      bic r0, r0, #0xFF000000
      mov r2, #1
      orr r0, r0, r2, lsl #24
      str r0, [r1, #TZIC_PRIORITY9]

      @ Configure PRIOMASK as 0
      eor r0, r0, r0
      str r0, [r1, #TZIC_PRIOMASK]

      @ Habilita o controlador de interrupcoes
      mov	r0, #1
      str	r0, [r1, #TZIC_INTCTRL]


      .set GPIO_DR, 0x53f84000
      .set GPIO_GDIR, 0x53f84004
      .set GPIO_PSR, 0x53f84008

      @Configura o GDIR com as entradas e saidas
      ldr r1, =GPIO_GDIR
      ldr r0, =0xfffc003e
      str r0, [r1]

      @instrucao msr - habilita interrupcoes
      @msr  CPSR_c, #0x13       @ SUPERVISOR mode, IRQ/FIQ enabled

      label1:
      msr CPSR_c, #USR_MODE|NO_FIQ
      @.set USR_STACK, 0x778145c0
      ldr sp, =USR_STACK
      .set LOCO_ADDRESS, 0x77812000
      ldr pc, =LOCO_ADDRESS

      @b _main

@Incrementa e depois verifica ou verifica e depois incrementa
IRQ_HANDLER:
    @ Preciso desabilitar interrupcoes IRQ e FIQ ou elas ja vem desabilitadas por default.
    sub lr, lr, #4
    push {r0-r12, lr}

    @desabilita interrupcoes do mesmo tipo no modo IRQ
    msr CPSR_c, #IRQ_MODE|NO_INT

    mov r0, #1
    ldr r1, =GPT_BASE
    str r0, [r1, #GPT_SR]

    @ldr r0, =CONTADOR
    @ldr r1, [r0]

    @qual callback devo priorizar, tempo ou distancia??
    ldr r4, =proximity_sonar_id_array
    ldr r5, =proximity_threshold_array
    ldr r6, =proximity_callback_array
    ldr r7, =CALLBACKS
    ldr r7, [r7]
    mov r8, #0
    callback_loop:
      cmp r8, r7
      beq end_callback_loop
      ldrb r0, [r4, r8] @sonar_id
      bl read_sonar
      lsl r8, #1
      ldrh r1, [r5, r8] @threshold
      lsr r8, #1
      cmp r0, r1
      blt exceeded_threshold
      add r8, r8, #1
      b callback_loop
    exceeded_threshold:
      mov r0, r7 @move o numero de elementos no vetor para r0
      mov r1, r8 @elemento do vetor que deve ser removido
      mov r2, #1 @tamanho de cada elemento a ser removido
      mov r3, r4 @endereco do vetor
      bl remove_array_element
      mov r0, r7
      mov r1, r8
      mov r2, #2
      mov r3, r5
      bl remove_array_element
      mov r0, r7
      mov r1, r8
      mov r2, #4
      mov r3, r6
      bl remove_array_element
      ldr r0, =CALLBACKS
      ldr r1, [r0]
      sub r1, r1, #1 @decrementa o numero de callbacks
      str r1, [r0]
      lsl r8, #2
      ldr r2, [r6, r8]
      ldr r0, =sudo_branch_addr
      ldr r1, =end_callback_loop
      str r1, [r0]
      msr CPSR_c, #USR_MODE|NO_INT
      blx r2
      mov r7, #23
      svc 0x0
    end_callback_loop:

    @r1 = tempo do sistema
    @TODO: Devo priorizar os alarmes que foram setados antes
    @ou posso assumir que nao haverao alarmes para o mesmo tempo
    ldr r0, =CONTADOR
    ldr r0, [r0]
    ldr r4, =alarm_array
    ldr r5, =stop_time_alarm_array
    ldr r6, =ALARMS
    ldr r6, [r6]
    mov r7, #0
    alarm_loop:
      cmp r7, r6
      beq end_irq_handler
      lsl r7, #2
      ldr r8, [r5, r7]
      lsr r7, #2
      cmp r0, r8
      beq found_alarm
      add r7, r7, #1
      b alarm_loop
    found_alarm:
      mov r0, r6 @move o numero de elementos no vetor para r0
      mov r1, r7 @elemento do vetor que deve ser removido
      mov r2, #4 @tamanho de cada elemento a ser removido
      mov r3, r4 @endereco do vetor
      bl remove_array_element
      mov r0, r6 @move o numero de elementos no vetor para r0
      mov r1, r7 @elemento do vetor que deve ser removido
      mov r2, #4 @tamanho de cada elemento a ser removido
      mov r3, r5 @endereco do vetor
      bl remove_array_element
      ldr r0, =ALARMS
      ldr r1, [r0]
      sub r1, r1, #1 @decrementa o numero de alarmes
      str r1, [r0]
      ldr r0, =sudo_branch_addr
      ldr r1, =end_irq_handler
      str r1, [r0]
      msr CPSR_c, #USR_MODE|NO_INT
      lsl r7, #2
      ldr r0, [r4, r7]
      blx r0
      mov r7, #23
      svc 0x0
    end_irq_handler:
      ldr r0, =CONTADOR
      ldr r1, [r0]
      add r1, r1, #1
      str r1, [r0]

      pop {r0-r12, lr}
      movs pc, lr

SVC_HANDLER:
  @sub lr, lr, #4
  push {r4-r12, lr}

  msr CPSR_c, #SVC_MODE|NO_INT

  ldr r4, =svc_handler_array
  sub r7, r7, #16
  lsl r7, #2
  ldr r4, [r4, r7]
  blx r4
  pop {r4-r12, lr}
  movs pc, lr

@r0 = 0 se quer desabilitar e 1 se quer habilitar interrupcoes irq
toggle_usr_irq:
  mrs r1, SPSR
  cmp r0, #0
  b disable_usr_irq
  msr SPSR_c, #USR_MODE
  b end_toggle_usr_irq
  disable_usr_irq:
  msr SPSR_c, #USR_MODE|NO_INT
  end_toggle_usr_irq:
  mrs r0, SPSR
  mov pc, lr

sudo:
  msr CPSR_c, #IRQ_MODE|NO_INT
  mrs r0, SPSR
  mrs r1, CPSR
  ldr r0, =sudo_branch_addr
  ldr r0, [r0]
  mov pc, r0

@ r0 = identificador do sonar
@ retorno:
@ r0 = valor obtido na leitura dos sonares; -1 caso
@ identificador seja invalido
read_sonar:
  push {r4-r7, lr}
  mov r4, r0
  cmp r0, #15
  bhi error_read_sonar
    ldr r5, =GPIO_DR
    ldr r6, [r5]
    @ldr r0, =0x3c
    ldr r0, =0x3fffd
    @ldr r1, =0x3ffc0
    @orr r0, r0, r1
    @VERIFICAR O GPIO_PSR
    bic r6, r6, r0 @limpa o sonar_mux e limpa o sonaar_data
    lsl r4, #2
    orr r6, r6, r4 @seta o sonar_mux
    str r6, [r5]
    bic r6, r6, #0x2 @zera o trigger
    str r6, [r5]
    bl delay_time
    add r6, r6, #0x2 @seta o trigger
    str r6, [r5]
    bl delay_time
    bic r6, r6, #0x2 @zera o trigger
    str r6, [r5]
    @bl delay_time
    ldr r6, [r5]
    and r7, r6, #0x1  @coloca em r7 a flag
    cmp r7, #1
    beq finish_reading
    flag_loop:    @loop infinito ate a flag ser setada
      bl delay_time
      ldr r6, [r5]
      and r7, r6, #0x1
      cmp r7, #1
      bne flag_loop
  finish_reading:

    ldr r3, =GPIO_PSR
    ldr r4, [r3]
    ldr r3, =0x3ffc0
    and r4, r4, r3
    lsr r4, #6
    @armazena em r4 o resultado da leitura

    ldr r0, [r5]    @carrega o Data Register
    ldr r2, =0x3ffc0
    and r1, r0, r2
    lsr r1, #6
    mov r0, r1

    b end_read_sonar
  error_read_sonar:
    mov r0, #-1
  end_read_sonar:
    pop {r4-r7, lr}
    mov pc, lr

@ r0 = sensor_id que deve ser monitorado
@ r1 = limiar de distancia onde deve-se chamar a funcao
@ r2 = endereco da funcao que deve ser chamada quando alcanca o threshold
@ retorno:
@ r0 = -1 caso o numero de CALLBACKS seja excedido.
@ -2 caso identificador do sonar seja invalido. 0 caso ok.
register_proximity_callback:
  push {r4-r8}
  mov r4, r0
  mov r5, r1
  mov r6, r2
  ldr r0, =CALLBACKS
  ldr r1, [r0]
  cmp r1, #MAX_CALLBACKS
  beq error_max_callbacks
  cmp r4, #15
  bhi error_invalid_sonar_id
    ldr r0, =proximity_sonar_id_array
    strb r4, [r0, r1]
    ldr r0, =proximity_threshold_array
    lsl r1, #1
    strh r5, [r0, r1]
    ldr r0, =proximity_callback_array
    lsl r1, #1
    str r6, [r0, r1]
    lsr r1, #2
    ldr r0, =CALLBACKS
    add r1, r1, #1
    str r1, [r0]
    mov r0, #0
    b end_register_proximity_callback
  error_max_callbacks:
    mov r0, #-1
    b end_register_proximity_callback
  error_invalid_sonar_id:
    mov r0, #-2
  end_register_proximity_callback:
    pop {r4-r8}
    mov pc, lr

@ r0 = id do motor, 0 ou 1
@ r1 = velocidade do motor
@ retorno:
@ r0 = -1 caso identificador seja invalido, -2 caso velocidade seja invalida e 0 caso ok
@ Talvez precise em algum momento setar o bit de motor write para 1.
set_motor_speed:
  push {r4, r5, lr}
  mov r4, r0
  mov r5, r1
  bl validate_motor_id
  cmp r0, #-1
  beq end_motor_speed
  mov r0, r5
  bl validate_speed
  cmp r0, #-2
  beq end_motor_speed
  ldr r2, =GPIO_DR
  ldr r3, [r2]
  cmp r4, #1
  beq set_motor1
  set_motor0:
    bic r3, r3, #0x01fc0000
    lsl r1, #19
    @add r1, r1, #0x40000
    b publish_motor_speed
  set_motor1:
    bic r3, r3, #0xfe000000
    lsl r1, #26
    @add r1, r1, #0x2000000
  publish_motor_speed:
    orr r3, r3, r1
    str r3, [r2]
    mov r0, #0
  end_motor_speed:
    pop {r4, r5, lr}
    mov pc, lr

@ r0 = velocidade do motor0
@ r1 = velocidade do motor1
@ retorno:
@ r0 = 0 caso ok. -1 caso velocidade do motor 0
@ seja invalida e -2 caso a do motor1 seja invalida
set_motors_speed:
  push {r4, r5, lr}
  mov r4, r0
  mov r5, r1
  bl validate_speed
  cmp r0, #-2
  beq end_invalid_motor0
  mov r0, r5
  bl validate_speed
  cmp r0, #-2
  beq end_motors_speed
    ldr r2, =GPIO_DR
    ldr r3, [r2]
    ldr r0, =0xfffc0000
    bic r3, r3, r0
    lsl r4, #19
    add r4, r4, r5, lsl #26
    orr r3, r3, r4
    str r3, [r2]
    mov r0, #0
    b end_motors_speed
  end_invalid_motor0:
    mov r0, #-1
  end_motors_speed:
    pop {r4, r5, lr}
    mov pc, lr

@ retorno:
@ r0 = tempo do sistema.
get_time:
  ldr r1, =CONTADOR
  ldr r0, [r1]
  mov pc, lr
@ r0 = valor do tempo de sistema.
set_time:
  ldr r1, =CONTADOR
  str r0, [r1]
  mov pc, lr

@ r0 = ponteiro para a funcao que deve ser chamada.
@ r1 = tempo em que a funcao deve ser chamada.
set_alarm:
  push {r4-r6, lr}
  mov r4, r0
  mov r5, r1
  ldr r0, =ALARMS @ r0=endereco do contador de alarmes
  ldr r1, [r0] @numero de alarmes ja setados
  ldr r2, =MAX_ALARMS
  cmp r1, r2
  beq end_max_alarms_error
  ldr r2, =CONTADOR
  ldr r3, [r2]
  sub r3, r3, #1
  cmp r5, r3
  blt end_time_error
    store_alarm:
    ldr r2, =alarm_array
    ldr r3, =stop_time_alarm_array
    lsl r1, #2 @deslocamento
    str r4, [r2, r1] @armazena o ponteiro para a funcao
    str r5, [r3, r1] @armazena o tempo de parada do alarme
    lsr r1, #2
    add r1, r1, #1
    str r1, [r0] @atualiza o contador de alarmes
    mov r0, #0
    b end_set_alarm
  end_max_alarms_error:
    mov r0, #-1
    b end_set_alarm
  end_time_error:
    mov r0, #-2
  end_set_alarm:
  pop {r4-r6, lr}
  mov pc, lr


@ r0 = id do motor que deseja-se verificar
@ retorno:
@ r0 = id do motor valido ou -1 caso id seja invalido
validate_motor_id:
  cmp r0, #1
  beq end_motor_validation
  cmp r0, #0
  beq end_motor_validation
  mov r0, #-1
  end_motor_validation:
  mov pc, lr

@Funcao que espera passar uma unidade de tempo.
delay_time:
  mov r0, #0
  ldr r1, =CONTADOR
  ldr r2, [r1]
  time_loop:
    cmp r0, #0x4000
    beq end_time_loop
    add r0, r0, #1
    b time_loop
  end_time_loop:

  ldr r2, [r1]

  mov pc, lr

validate_speed:
  cmp r0, #63
  bls end_validate_speed
  mov r0, #-2
  end_validate_speed:
  mov pc, lr

@ r0 = numero de elementos no vetor
@ r1 = elemento do vetor que deve ser removido
@ r2 = tamanho do elemento a ser removido
@ r3 = endereco do vetor
remove_array_element:
  push {r4, r5}
  sub r0, r0, #1
  loop_remove_element:
    cmp r1, r0
    beq end_remove_element
    add r1, r1, #1
    cmp r2, #2
    beq load_two_bytes
    cmp r2, #4
    beq load_four_bytes
      ldrb r4, [r3, r1]
      sub r5, r1, #1
      strb r4, [r3, r5]
      b loop_remove_element
    load_two_bytes:
      lsl r1, #1
      ldrh r4, [r3, r1]
      sub r5, r1, #2
      strh r4, [r3, r5]
      lsr r1, #1
      b loop_remove_element
    load_four_bytes:
      lsl r1, #2
      ldr r4, [r3, r1]
      sub r5, r1, #4
      str r4, [r3, r5]
      lsr r1, #2
      b loop_remove_element
  end_remove_element:
    pop {r4, r5}
    mov pc, lr
