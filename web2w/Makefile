all:
	/bin/ctangle web2w
	flex -o web.lex.c web.l
	bison --warnings=none -d -v pascal.y
	gcc -o web2w web2w.c web.lex.c pascal.tab.c
	sed 's/\bvoid\b/empty/g' mf.web >mf-web2w.web
	./web2w -o mf.w mf-web2w.web
