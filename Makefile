all:
	$(MAKE) -C demo
	$(MAKE) -C pacman

clean:
	$(MAKE) -C demo   clean
	$(MAKE) -C pacman clean
