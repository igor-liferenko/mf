@x
@h
@y
#include <sys/wait.h>
@h
@z

@x
b_close(&gf_file);
@y
char *fname, symlink[50];
sprintf(symlink, "/proc/self/fd/%d", fileno(gf_file.f));
assert((fname = realpath(symlink, NULL)) != NULL);
b_close(&gf_file);
pid_t gftopk_pid = fork();
assert(gftopk_pid != -1);
if (gftopk_pid == 0) {
  signal(SIGINT, SIG_IGN);
  execlp("gftopk", "gftopk", fname, (char *) NULL);
  _exit(1);
}
int gftopk; waitpid(gftopk_pid, &gftopk, 0); assert(gftopk == 0);
@z
