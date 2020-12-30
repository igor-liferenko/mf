@x
@h
@y
#include <sys/wait.h>
@h
@z

@x
  print_str("gf");gf_ext=make_string();selector=old_setting;
@y
  print_str("pk");gf_ext=make_string();selector=old_setting;
@z

@x
b_close(&gf_file);
@y
char tmp[30];
assert(snprintf(tmp, sizeof tmp, "/proc/self/fd/%d", fileno(gf_file.f)) < sizeof tmp);
char fname[500] = { };
assert(readlink(tmp, fname, sizeof fname) != -1 && fname[sizeof fname - 1] == '\0');
b_close(&gf_file);
pid_t gftopk = fork();
assert(gftopk != -1);
if (gftopk == 0) {
  signal(SIGINT, SIG_IGN);
  execlp("gftopk", "gftopk", fname, (char *) NULL);
  exit(1);
}
int wstatus; waitpid(gftopk, &wstatus, 0); assert(wstatus == 0);
@z

@x
@d str_468 ".gf"
@y
@d str_468 ".pk"
@z
