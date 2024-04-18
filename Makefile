all:
	$(MAKE) -C demo
	$(MAKE) -C pacman
	$(MAKE) -C bomber

clean:
	$(MAKE) -C demo   clean
	$(MAKE) -C pacman clean
	$(MAKE) -C bomber clean
