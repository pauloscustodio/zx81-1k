all: demo.P
demo.P: demo.asm ../zx81.inc ../sysvars1k_lowres.inc ../check_size.pl
	z88dk-z80asm -b -m -odemo.P demo.asm
	perl ../check_size.pl $@

clean:
	$(RM) *.o *.P *.map
