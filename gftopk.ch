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
int wstatus; waitpid(gftopk, &wstatus, 0); assert(wstatus == 0); /* TODO: check if child exits by
  signal wstatus will be non-zero and if yes, rm signal() from here */
@z
