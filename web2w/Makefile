all: ctangle
	./ctangle -bhp web2w web2w-mf
	patch web.l -o web-mf.l <web-mf.patch
	flex -o web.lex.c web-mf.l
	patch pascal.y -o pascal-mf.y <pascal-mf.patch
	bison --warnings=none -d -v pascal-mf.y
	gcc -o web2w web2w.c web.lex.c pascal-mf.tab.c
	patch mf.web -o mf-web2w.web <mf-web2w.patch
	sed -i 's/\bvoid\b/empty/g' mf-web2w.web
	./web2w -o mf.w mf-web2w.web
	#patch mf.w cmf.patch

ctangle:
	/var/local/bin/ctangle -bhp common.w /home/user/cweb-git/utf8/comm-show.ch
	gcc -w -c common.c
	/var/local/bin/ctangle -bhp ctangle.w /home/user/cweb-git/utf8/ctang-show.ch
	gcc -w -c ctangle.c
	gcc -w -o ctangle ctangle.o common.o
	/var/local/bin/ctangle -bhp cweave.w /home/user/cweb-git/utf8/cweav-show.ch
	gcc -w -c cweave.c
	gcc -w -o cweave cweave.o common.o
