all: ctangle
	./ctangle web2w web2w-mf >/dev/null
	patch web.l -o web-mf.l <web-mf.patch
	flex -o web.lex.c web-mf.l
	patch pascal.y -o pascal-mf.y <pascal-mf.patch
	bison --warnings=none -d -v pascal-mf.y
	gcc -o web2w web2w.c web.lex.c pascal-mf.tab.c
	patch mf.web -o mf-web2w.web <mf-web2w.patch
	sed -i 's/\bvoid\b/empty/g' mf-web2w.web
	./web2w -o mf.w mf-web2w.web

ctangle:
	ctangle -bhp common.w
	gcc -w -c common.c
	ctangle -bhp ctangle.w
	gcc -w -c ctangle.c
	gcc -w -o ctangle ctangle.o common.o
