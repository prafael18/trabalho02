PROGRAM = segue-parede
OBJECT_ONE = segue-parede

all: $(PROGRAM)
	mksd.sh --so $(OS) --user $(PROGRAM)
$(PROGRAM): $(OBJECT_ONE).o
	arm-eabi-ld $(OBJECT_ONE).o -o $(OBJECT_ONE) -Ttext=0x77802000
$(OBJECT_ONE).o:
	arm-eabi-as $(OBJECT_ONE).s -o $(OBJECT_ONE).o
	arm-eabi-gcc $(OBJECT_ONE).c -S -o $(OBJECT_ONE).s

run:
	armsim_player --rom=$(DUMBOOT) --sd=disk.img

clean:
	rm -rf $(OBJECT_ONE).o $(PROGRAM) disk.img
player:
	player $(PLAYER_WORLDS)/simple.cfg

debug:
	arm-eabi-gcc $(OBJECT_ONE).c -g -S -o $(OBJECT_ONE).s
	arm-eabi-as $(OBJECT_ONE).s -g -o $(OBJECT_ONE).o
	arm-eabi-ld $(OBJECT_ONE).o -g -o $(OBJECT_ONE) -Ttext=0x77802000
	mksd.sh --so $(OS) --user $(PROGRAM)
	$(ARMSIM) --rom=$(DUMBOOT) --sd=disk.img -g
run_gdb:
	$(GDB) $(PROGRAM)


#/home/mc404/simuladorfromspecg/simulador/simulador_player/bin/dumboot.bin
# /home/mc404/simuladorfromspecg/simulador/simulador_player/bin/knrl
