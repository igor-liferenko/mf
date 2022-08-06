@x
@h
@y
#include <limits.h>
#include <sys/wait.h>
#include <unistd.h>
@h
@z

@x
b_close(&gf_file);
@y
char fname[PATH_MAX];
sprintf(fname, "/proc/self/fd/%d", fileno(gf_file.f));
assert(realpath(strdup(fname), fname));
b_close(&gf_file);
if (history <= warning_issued) {
  pid_t gftopk_pid = fork();
  assert(gftopk_pid != -1);
  if (gftopk_pid == 0) {
    signal(SIGINT, SIG_IGN);
    execlp("gftopk", "gftopk", fname, (char *) NULL);
    _exit(1);
  }
  int gftopk; waitpid(gftopk_pid, &gftopk, 0); assert(gftopk == 0);
}
@z
