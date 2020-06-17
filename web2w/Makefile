all:
	/usr/bin/ctangle -bhp web2w web2w-mf
	patch web.l -o web-mf.l <web-mf.patch
	flex -o web.lex.c web-mf.l
	patch pascal.y -o pascal-mf.y <pascal-mf.patch
	bison --warnings=none -d -v pascal-mf.y
	gcc -o web2w web2w.c web.lex.c pascal-mf.tab.c
	patch mf.web -o mf-web2w.web <mf-web2w.patch
	sed -i 's/\bvoid\b/empty/g' mf-web2w.web
	./web2w -o mf.w mf-web2w.web
