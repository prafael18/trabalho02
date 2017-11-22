	.arch armv5te
	.fpu softvfp
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 1
	.eabi_attribute 30, 6
	.eabi_attribute 18, 4
	.file	"segue-parede.c"
	.text
	.align	2
	.global	_start
	.type	_start, %function
_start:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	mov	r3, #0
	strb	r3, [fp, #-8]
	mov	r3, #1
	strb	r3, [fp, #-12]
	sub	r2, fp, #8
	sub	r3, fp, #12
	mov	r0, r2
	mov	r1, r3
	bl	busca_parede
	sub	r2, fp, #8
	sub	r3, fp, #12
	mov	r0, r2
	mov	r1, r3
	bl	segue_parede
	mov	r3, #0
	mov	r0, r3
	sub	sp, fp, #4
	ldmfd	sp!, {fp, pc}
	.size	_start, .-_start
	.align	2
	.global	turn_right
	.type	turn_right, %function
turn_right:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	mov	r3, r0
	strb	r3, [fp, #-21]
	mov	r3, #0
	str	r3, [fp, #-8]
	mov	r3, #0
	strb	r3, [fp, #-12]
	mov	r3, #1
	strb	r3, [fp, #-16]
	ldrb	r3, [fp, #-21]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L4
	mov	r3, #0
	strb	r3, [fp, #-11]
	mov	r3, #15
	strb	r3, [fp, #-15]
	b	.L6
.L4:
	mov	r3, #5
	strb	r3, [fp, #-11]
	mov	r3, #10
	strb	r3, [fp, #-15]
	b	.L6
.L7:
	sub	r2, fp, #12
	sub	r3, fp, #16
	mov	r0, r2
	mov	r1, r3
	bl	set_motors_speed
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L6:
	ldr	r3, [fp, #-8]
	cmp	r3, #9
	ble	.L7
	sub	sp, fp, #4
	ldmfd	sp!, {fp, pc}
	.size	turn_right, .-turn_right
	.align	2
	.global	turn_left
	.type	turn_left, %function
turn_left:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	mov	r3, r0
	strb	r3, [fp, #-21]
	mov	r3, #0
	str	r3, [fp, #-8]
	mov	r3, #0
	strb	r3, [fp, #-12]
	mov	r3, #1
	strb	r3, [fp, #-16]
	ldrb	r3, [fp, #-21]	@ zero_extendqisi2
	cmp	r3, #0
	beq	.L10
	mov	r3, #15
	strb	r3, [fp, #-11]
	mov	r3, #0
	strb	r3, [fp, #-15]
	b	.L12
.L10:
	mov	r3, #10
	strb	r3, [fp, #-11]
	mov	r3, #5
	strb	r3, [fp, #-15]
	b	.L12
.L13:
	sub	r2, fp, #12
	sub	r3, fp, #16
	mov	r0, r2
	mov	r1, r3
	bl	set_motors_speed
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L12:
	ldr	r3, [fp, #-8]
	cmp	r3, #9
	ble	.L13
	sub	sp, fp, #4
	ldmfd	sp!, {fp, pc}
	.size	turn_left, .-turn_left
	.align	2
	.global	segue_parede
	.type	segue_parede, %function
segue_parede:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	str	r0, [fp, #-24]
	str	r1, [fp, #-28]
	ldr	r3, [fp, #-24]
	mov	r2, #10
	strb	r2, [r3, #1]
	ldr	r3, [fp, #-28]
	mov	r2, #10
	strb	r2, [r3, #1]
	ldr	r0, [fp, #-24]
	ldr	r1, [fp, #-28]
	bl	set_motors_speed
.L21:
	mov	r0, #4
	bl	read_sonar
	mov	r3, r0
	strh	r3, [fp, #-8]	@ movhi
	ldrh	r2, [fp, #-8]
	ldr	r3, .L23
	cmp	r2, r3
	bhi	.L16
	mov	r0, #1
	bl	turn_right
	bl	write_sharp_turn_right
	b	.L17
.L16:
	mov	r0, #0
	bl	read_sonar
	mov	r3, r0
	strh	r3, [fp, #-12]	@ movhi
	mov	r0, #15
	bl	read_sonar
	mov	r3, r0
	strh	r3, [fp, #-10]	@ movhi
	ldrh	r2, [fp, #-12]
	ldrh	r3, [fp, #-10]
	mov	r0, r2
	mov	r1, r3
	bl	write_sonar_dist
	ldrh	r3, [fp, #-12]
	cmp	r3, #400
	bhi	.L18
	ldrh	r3, [fp, #-10]
	cmp	r3, #400
	bhi	.L18
	bl	write_slow_turn_right
	mov	r0, #0
	bl	turn_right
	b	.L17
.L18:
	ldrh	r2, [fp, #-12]
	ldr	r3, .L23+4
	cmp	r2, r3
	bls	.L19
	ldrh	r2, [fp, #-10]
	ldr	r3, .L23+4
	cmp	r2, r3
	bls	.L19
	mov	r0, #1
	bl	turn_left
	bl	write_sharp_turn_left
	b	.L17
.L19:
	ldrh	r2, [fp, #-12]
	ldr	r3, .L23+8
	cmp	r2, r3
	bls	.L20
	ldrh	r2, [fp, #-10]
	ldr	r3, .L23+8
	cmp	r2, r3
	bls	.L20
	bl	write_slow_turn_left
	mov	r0, #0
	bl	turn_left
	b	.L17
.L20:
	ldr	r3, [fp, #-24]
	mov	r2, #20
	strb	r2, [r3, #1]
	ldr	r3, [fp, #-28]
	mov	r2, #20
	strb	r2, [r3, #1]
.L17:
	ldr	r0, [fp, #-24]
	ldr	r1, [fp, #-28]
	bl	set_motors_speed
	b	.L21
.L24:
	.align	2
.L23:
	.word	799
	.word	899
	.word	649
	.size	segue_parede, .-segue_parede
	.align	2
	.global	busca_parede
	.type	busca_parede, %function
busca_parede:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #8
	str	r0, [fp, #-8]
	str	r1, [fp, #-12]
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-12]
	bl	busca_obstaculo
	ldr	r0, [fp, #-8]
	ldr	r1, [fp, #-12]
	bl	align_left
	sub	sp, fp, #4
	ldmfd	sp!, {fp, pc}
	.size	busca_parede, .-busca_parede
	.align	2
	.global	align_left
	.type	align_left, %function
align_left:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
.L28:
	mov	r0, #1
	bl	read_sonar
	mov	r3, r0
	strh	r3, [fp, #-8]	@ movhi
	mov	r0, #14
	bl	read_sonar
	mov	r3, r0
	strh	r3, [fp, #-6]	@ movhi
	ldrsh	r2, [fp, #-8]
	ldrsh	r3, [fp, #-6]
	rsb	r3, r3, r2
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-16]
	mov	r2, #4
	strb	r2, [r3, #1]
	ldr	r3, [fp, #-20]
	mov	r2, #10
	strb	r2, [r3, #1]
	ldr	r0, [fp, #-16]
	ldr	r1, [fp, #-20]
	bl	set_motors_speed
	ldr	r3, [fp, #-12]
	cmn	r3, #30
	blt	.L28
	ldrsh	r3, [fp, #-8]
	cmp	r3, #2000
	bgt	.L28
	ldrsh	r3, [fp, #-6]
	cmp	r3, #2000
	bgt	.L28
	ldr	r3, [fp, #-16]
	mov	r2, #0
	strb	r2, [r3, #1]
	ldr	r3, [fp, #-20]
	mov	r2, #0
	strb	r2, [r3, #1]
	ldr	r0, [fp, #-16]
	ldr	r1, [fp, #-20]
	bl	set_motors_speed
	sub	sp, fp, #4
	ldmfd	sp!, {fp, pc}
	.size	align_left, .-align_left
	.align	2
	.global	busca_obstaculo
	.type	busca_obstaculo, %function
busca_obstaculo:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	str	r0, [fp, #-16]
	str	r1, [fp, #-20]
	ldr	r3, [fp, #-16]
	mov	r2, #30
	strb	r2, [r3, #1]
	ldr	r3, [fp, #-20]
	mov	r2, #30
	strb	r2, [r3, #1]
	ldr	r0, [fp, #-16]
	ldr	r1, [fp, #-20]
	bl	set_motors_speed
.L32:
	mov	r0, #3
	bl	read_sonar
	mov	r3, r0
	strh	r3, [fp, #-8]	@ movhi
	mov	r0, #5
	bl	read_sonar
	mov	r3, r0
	strh	r3, [fp, #-6]	@ movhi
	ldrh	r3, [fp, #-8]
	cmp	r3, #1200
	bls	.L31
	ldrh	r3, [fp, #-6]
	cmp	r3, #1200
	bhi	.L32
.L31:
	ldr	r3, [fp, #-16]
	mov	r2, #0
	strb	r2, [r3, #1]
	ldr	r3, [fp, #-20]
	mov	r2, #0
	strb	r2, [r3, #1]
	ldr	r0, [fp, #-16]
	ldr	r1, [fp, #-20]
	bl	set_motors_speed
	sub	sp, fp, #4
	ldmfd	sp!, {fp, pc}
	.size	busca_obstaculo, .-busca_obstaculo
	.ident	"GCC: (GNU) 4.4.3"
	.section	.note.GNU-stack,"",%progbits
