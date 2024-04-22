PROJ = demo

all: $(PROJ).P
$(PROJ).P: $(PROJ).asm ../zx81.inc ../model1k_lowres.inc ../check_size.pl
	z88dk-z80asm -l -b -m -o$(PROJ).P $(PROJ).asm
	perl ../check_size.pl $@

clean:
	$(RM) *.o *.P *.map *.lis
