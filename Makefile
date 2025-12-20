all: release

system:
	./scripts/image

release:
	./scripts/image release

image:
	./scripts/image mkimage

noobs:
	./scripts/image noobs

clean:
	./scripts/makefile_helper --clean

distclean:
	./scripts/makefile_helper --distclean

src-pkg:
	tar cvJf sources.tar.xz sources
