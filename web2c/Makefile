all:
	gcc -DHAVE_CONFIG_H -I. -I../w2c -I.. -Wimplicit -Wreturn-type -g -O2 -c -o kps.o kps.c
	rm -f libweb2c.a
	ar cruU libweb2c.a kps.o
	ranlib libweb2c.a
	gcc -DHAVE_CONFIG_H -I. -I.. -I../w2c -Wimplicit -Wreturn-type -g -O2 -c -o web2c-parser.o web2c-parser.c
	gcc -DHAVE_CONFIG_H -I. -I.. -I../w2c -Wimplicit -Wreturn-type -g -O2 -c -o web2c-lexer.o web2c-lexer.c
	gcc -DHAVE_CONFIG_H -I. -I.. -I../w2c -Wimplicit -Wreturn-type -g -O2 -c -o main.o main.c
	gcc -Wimplicit -Wreturn-type -g -O2 -o web2c web2c-parser.o web2c-lexer.o main.o -L. -lweb2c
	gcc -DHAVE_CONFIG_H -I. -I.. -I../w2c -Wimplicit -Wreturn-type -g -O2 -c -o fixwrites.o fixwrites.c
	gcc -Wimplicit -Wreturn-type -g -O2 -o fixwrites fixwrites.o -L. -lweb2c
	gcc -DHAVE_CONFIG_H -I. -I.. -I../w2c -Wimplicit -Wreturn-type -g -O2 -c -o splitup.o splitup.c
	gcc -Wimplicit -Wreturn-type -g -O2 -o splitup splitup.o -L. -lweb2c
	gcc -DHAVE_CONFIG_H -I. -I./kpathsea -I./../.. -Wimplicit -Wreturn-type -g -O2 -c -o makecpool.o makecpool.c
	gcc -Wimplicit -Wreturn-type -g -O2 -o makecpool makecpool.o
