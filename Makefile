all:
	$(MAKE) -C demo_lowres
	$(MAKE) -C demo_hires
	$(MAKE) -C pacman
	$(MAKE) -C bomber

clean:
	$(MAKE) -C demo_lowres clean
	$(MAKE) -C demo_hires  clean
	$(MAKE) -C pacman      clean
	$(MAKE) -C bomber      clean
