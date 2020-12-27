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
  execl("/bin/gftopk", "gftopk", fname, (char *) NULL);
  exit(1);
}
int exit_status; waitpid(gftopk, &exit_status, 0); assert(exit_status == 0);
@z
