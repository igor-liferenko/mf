@x
int wstatus; waitpid(gftopk, &wstatus, 0); assert(wstatus == 0);
@y
int wstatus; waitpid(gftopk, &wstatus, 0); assert(wstatus == 0);
pid_t gftodvi = fork();
assert(gftodvi != -1);
if (gftodvi == 0) {
  signal(SIGINT, SIG_IGN);
  execl("/bin/gftodvi", "gftodvi", fname, (char *) NULL);
  exit(1);
}
waitpid(gftodvi, &wstatus, 0); assert(wstatus == 0);
unlink(fname);
pid_t dvipdfm = fork();
assert(dvipdfm != -1);
if (dvipdfm == 0) {
  signal(SIGINT, SIG_IGN);
  execl("/bin/dvipdfm", "dvipdfm", fname, (char *) NULL);
  exit(1);
}
waitpid(dvipdfm, &wstatus, 0); assert(wstatus == 0);
@z
