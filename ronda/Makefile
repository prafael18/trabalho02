# ----------------------------------------
# Disciplina: MC404 - 1o semestre de 2015
# Professor: Edson Borin
#
# DescriÃ§Ã£o: Makefile para o segundo trabalho
# ----------------------------------------

# ----------------------------------
# SOUL object files -- Add your SOUL object files here
SOUL_OBJS=soul.o

# FLAGS=-g
# ----------------------------------
# Compiling/Assembling/Linking Tools and flags
PLAYER_WORLDS = /home/mc404/Documentos/mc404/trabalho02/worlds_mc404

AS=arm-eabi-as
AS_FLAGS=-g

CC=arm-eabi-gcc
CC_FLAGS=-g

LD=arm-eabi-ld
LD_FLAGS=-g

RUN_FLAGS=-g

FLAGS =

USER_PRG=ronda.o

# ----------------------------------
# Default rule
all: disk.img

# ----------------------------------
# Generic Rules
# %.s: %.c
ronda.s:ronda.c
	arm-eabi-gcc ronda.c -g -S -o ronda.s
# 	$(CC) $< -g -S -o $@

%.o: %.s
	$(AS) -g $< -o $@

# ----------------------------------
# Specific Rules
SOUL.x: $(SOUL_OBJS)
	$(LD) $^ -o $@ $(FLAGS) --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0

LOCO.x: $(USER_PRG) bico.o
	$(LD) $^ -o $@ $(FLAGS) -Ttext=0x77812000

disk.img: SOUL.x LOCO.x
	mksd.sh --so SOUL.x --user LOCO.x

clean:
	rm -f SOUL.x LOCO.x disk.img *.o ronda.s

run:
	armsim_player --rom=$(DUMBOOT) --sd=disk.img $(FLAGS)

player:
	player $(PLAYER_WORLDS)/ronda.cfg

debug_loco:
	$(GDB) LOCO.x

debug_soul:
	$(GDB) SOUL.x
