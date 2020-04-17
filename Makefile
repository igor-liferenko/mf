mf: libmf.a
	make -C window wl
	gcc -Wimplicit -Wreturn-type -g -O2 -o mf mf-mfextra.o libmf.a lib/lib.a -lkpathsea window/libwindow.a
	mv mf /usr/local/bin/

libmf.a:
	make -C lib
	make -C web2c
	tie -c mf-final.ch web2w/mf.web mf.ch mf-binpool.ch
	tangle web2w/mf mf-final
	web2c/convert mf
	gcc -DHAVE_CONFIG_H -I. -I./w2c -Wimplicit -Wreturn-type -g -O2 -c -o mf-mfextra.o mfextra.c
	gcc -DHAVE_CONFIG_H -I. -I./w2c -Wimplicit -Wreturn-type -g -O2 -c -o mfini.o mfini.c
	gcc -DHAVE_CONFIG_H -I. -I./w2c -Wimplicit -Wreturn-type -g -O2 -c -o mf0.o mf0.c
	web2c/makecpool mf >mf-pool.c || rm -f mf-pool.c
	gcc -DHAVE_CONFIG_H -I. -I./w2c -Wimplicit -Wreturn-type -g -O2 -c -o mf-pool.o mf-pool.c
	rm -f libmf.a
	ar cruU libmf.a mfini.o mf0.o mf-pool.o
	ranlib libmf.a

view:
	@make --no-print-directory -C window $@
	@tex mf-wl >/dev/null
	@echo use \"dvi mf-wl\" to view the document

print:
	@make --no-print-directory -C window $@
	@tex mf-wl >/dev/null
	@echo use \"prt mf-wl\" to print the document
