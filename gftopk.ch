@x
@h
@y
#include <sys/wait.h>
@h
@z

@x
b_close(&gf_file);
@y
char tmp[30];
assert(snprintf(tmp, sizeof tmp, "/proc/self/fd/%d", fileno(gf_file.f)) < sizeof tmp);
char fname[500] = { };
assert(readlink(tmp, fname, sizeof fname) != -1 && fname[sizeof fname - 1] == '\0');
b_close(&gf_file);
pid_t gftopk_pid = fork();
assert(gftopk_pid != -1);
if (gftopk_pid == 0) {
  signal(SIGINT, SIG_IGN);
  execlp("gftopk", "gftopk", fname, (char *) NULL);
  exit(1);
}
int gftopk; waitpid(gftopk_pid, &gftopk, 0); assert(gftopk == 0);
@z
