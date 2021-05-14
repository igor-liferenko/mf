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
char fname[500] = {0};
assert(readlink(tmp, fname, sizeof fname) != -1 && fname[sizeof fname - 1] == 0);
b_close(&gf_file);
pid_t gftodvi_pid = fork();
assert(gftodvi_pid != -1);
if (gftodvi_pid == 0) {
  signal(SIGINT, SIG_IGN);
  putenv("TFMFONTS=/home/user/tex/TeXfonts"); /* same as in bin/dvipdfmx */
  execlp("gftodvi", "gftodvi", fname, (char *) NULL);
  exit(1);
}
int gftodvi; waitpid(gftodvi_pid, &gftodvi, 0); assert(gftodvi == 0);
unlink(fname);
{ char *p = strrchr(fname, '.'); *++p = 'd'; *++p = 'v'; *++p = 'i'; *++p = '\0'; }
pid_t dvipdfm_pid = fork();
assert(dvipdfm_pid != -1);
if (dvipdfm_pid == 0) {
  signal(SIGINT, SIG_IGN);
  putenv("T1FONTS=/none");
  execlp("dvipdfmx", "dvipdfmx", "-q", "-p", "a4", "-x", "22.45mm", "-y", "34.2mm", fname, (char *) NULL);
  exit(1);
}
int dvipdfm; waitpid(dvipdfm_pid, &dvipdfm, 0); assert(dvipdfm == 0);
@z
