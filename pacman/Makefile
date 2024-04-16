all: pacman.P
pacman.P: pacman.asm ../zx81.inc ../sysvars1k_lowres.inc ../check_size.pl
	z88dk-z80asm -l -b -m -opacman.P pacman.asm
	perl ../check_size.pl $@

clean:
	$(RM) *.o *.P *.map *.lis
