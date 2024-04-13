DEPENDS = sysvars.inc Makefile assemble.pl check_size.pl

all: demo.P
demo.P: demo.asm $(DEPENDS)
	perl assemble.pl $<
	perl check_size.pl $@

clean:
	$(RM) *.P *.i *.lis *.o *.map
